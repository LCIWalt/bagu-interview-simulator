import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/util/redact.dart';

import 'claim_extractor.dart';

enum ClaimVerdictKind { supported, contradicted, unknown }

class SourceRef {
  const SourceRef({
    required this.url,
    required this.title,
    required this.authority,
    this.quote = '',
  });

  final String url;
  final String title;
  final SourceAuthority authority;
  final String quote;

  Map<String, Object?> toJson() => <String, Object?>{
    'url': url,
    'title': title,
    'authority': authority.name,
    'quote': quote,
  };

  static SourceRef fromJson(Map<String, dynamic> json) => SourceRef(
    url: json['url']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    authority: SourceAuthority.values.firstWhere(
      (SourceAuthority value) => value.name == json['authority'],
      orElse: () => SourceAuthority.c,
    ),
    quote: json['quote']?.toString() ?? '',
  );
}

class ClaimVerdict {
  const ClaimVerdict({
    required this.claim,
    required this.verdict,
    this.confidence = 0,
    this.evidence = '',
    this.sources = const <SourceRef>[],
    this.cached = false,
  });

  final String claim;
  final ClaimVerdictKind verdict;
  final double confidence;
  final String evidence;
  final List<SourceRef> sources;
  final bool cached;

  bool get contradicts => verdict == ClaimVerdictKind.contradicted;
}

/// 断言核查缓存（`fact_checks`，默认 30 天）。
class FactCheckCache {
  FactCheckCache(this._db, {this.ttl = const Duration(days: 30)});

  final AppDatabase _db;
  final Duration ttl;

  static String keyFor(String claim) => sha256
      .convert(utf8.encode(claim.replaceAll(RegExp(r'\s+'), '')))
      .toString();

  Future<ClaimVerdict?> get(String claim) async {
    final row =
        await (_db.select(_db.factChecks)
              ..where((FactChecks t) => t.claimHash.equals(keyFor(claim))))
            .getSingleOrNull();
    if (row == null) return null;
    final age = DateTime.now().difference(row.checkedAt);
    if (age > Duration(seconds: row.ttlS)) return null;
    try {
      final sources = (jsonDecode(row.sourcesJson) as List<Object?>)
          .whereType<Map<String, dynamic>>()
          .map(SourceRef.fromJson)
          .toList(growable: false);
      return ClaimVerdict(
        claim: row.claim,
        verdict: ClaimVerdictKind.values.firstWhere(
          (ClaimVerdictKind value) => value.name == row.verdict,
          orElse: () => ClaimVerdictKind.unknown,
        ),
        confidence: row.confidence,
        sources: sources,
        cached: true,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> put(ClaimVerdict verdict) async {
    await _db
        .into(_db.factChecks)
        .insertOnConflictUpdate(
          FactChecksCompanion.insert(
            claimHash: keyFor(verdict.claim),
            claim: verdict.claim,
            verdict: verdict.verdict.name,
            confidence: Value(verdict.confidence),
            sourcesJson: Value(
              jsonEncode(
                verdict.sources
                    .map((SourceRef s) => s.toJson())
                    .toList(growable: false),
              ),
            ),
            checkedAt: DateTime.now(),
            ttlS: Value(ttl.inSeconds),
          ),
        );
  }
}

/// 证据链校验 + 只降分（T-053）。
class ClaimVerifier {
  ClaimVerifier({
    required this.search,
    required this.judge,
    required this.prompts,
    required this.model,
    this.cache,
    this.maxPages = 3,
    this.maxSnippets = 4,
    this.evidenceChars = 6000,
  });

  final SearchProvider search;
  final LlmClient judge;
  final PromptRegistry prompts;
  final String model;
  final FactCheckCache? cache;
  final int maxPages;
  final int maxSnippets;
  final int evidenceChars;

  Future<ClaimVerdict> verify(
    ExtractedClaim claim, {
    CancelToken? cancel,
  }) async {
    final cached = await cache?.get(claim.text);
    if (cached != null) return cached;
    try {
      final pages = await _collect(claim);
      if (pages.isEmpty) return _unknown(claim.text);
      final evidence = pages
          .map(
            (ExtractedPage page) =>
                '<untrusted source="${page.url}">\n${page.title}\n${page.textMarkdown}\n</untrusted>',
          )
          .join('\n\n');
      final template = prompts.require('claim.verify');
      final prompt = template.render(<String, String>{
        'claim': claim.text,
        'evidence': _truncate(evidence, evidenceChars),
      });
      final buffer = StringBuffer();
      await for (final delta in judge.chat(
        ChatRequest(
          model: model,
          messages: <ChatMessage>[ChatMessage.system(prompt)],
          temperature: template.temperature,
          maxTokens: 500,
          forceJson: true,
        ),
        cancel: cancel,
      )) {
        if (delta is LlmTextDelta) buffer.write(delta.text);
        if (delta is LlmDoneDelta) break;
      }
      final verdict = _parse(claim.text, buffer.toString(), pages);
      await cache?.put(verdict);
      return verdict;
    } on Failure {
      return _unknown(claim.text);
    } on Object {
      return _unknown(claim.text);
    }
  }

  Future<List<ExtractedPage>> _collect(ExtractedClaim claim) async {
    final queries = claim.queries.isEmpty
        ? <String>[claim.text, '${claim.text} official docs']
        : claim.queries.take(2).toList();
    final hits = <String, SearchHit>{};
    for (final query in queries) {
      try {
        for (final hit in await search.search(SearchQuery(query: query))) {
          if (hit.authority == SourceAuthority.d) continue;
          hits.putIfAbsent(hit.url, () => hit);
        }
      } on Failure {
        // 单条检索失败不阻断其他查询。
      }
    }
    final ordered = hits.values.toList()
      ..sort(
        (SearchHit a, SearchHit b) =>
            a.authority.index.compareTo(b.authority.index),
      );
    final pages = <ExtractedPage>[];
    for (final hit in ordered.take(maxPages)) {
      try {
        final page = await search.fetch(hit.url);
        if (page.authority != SourceAuthority.d) pages.add(page);
      } on Failure {
        continue;
      }
    }
    return pages;
  }

  ClaimVerdict _parse(String claim, String raw, List<ExtractedPage> pages) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return _unknown(claim);
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map<String, dynamic>) return _unknown(claim);
      final rawVerdict = decoded['verdict']?.toString() ?? 'unknown';
      var verdict = ClaimVerdictKind.values.firstWhere(
        (ClaimVerdictKind value) => value.name == rawVerdict,
        orElse: () => ClaimVerdictKind.unknown,
      );
      final confidence = (decoded['confidence'] as num?)?.toDouble() ?? 0;
      final evidence = decoded['evidence']?.toString().trim() ?? '';
      final urls = (decoded['sources'] as List<Object?>? ?? const <Object?>[])
          .map((Object? url) => '$url')
          .toSet();
      final used = pages
          .where((ExtractedPage page) => urls.contains(page.url))
          .toList();
      final sources = used
          .map(
            (ExtractedPage page) => SourceRef(
              url: page.url,
              title: page.title,
              authority: page.authority,
              quote: evidence,
            ),
          )
          .toList(growable: false);

      // 证据必须逐字来自抓取到的页面。
      final corpus = pages
          .map((ExtractedPage page) => page.textMarkdown)
          .join('\n');
      if (evidence.isEmpty || !_containsEvidence(corpus, evidence)) {
        return _unknown(claim);
      }
      // contradicted 至少需要一个 A 级来源。
      if (verdict == ClaimVerdictKind.contradicted &&
          !sources.any(
            (SourceRef source) => source.authority == SourceAuthority.a,
          )) {
        verdict = ClaimVerdictKind.unknown;
      }
      return ClaimVerdict(
        claim: claim,
        verdict: verdict,
        confidence: confidence.clamp(0, 1).toDouble(),
        evidence: redact(evidence, maxLength: 500),
        sources: sources,
      );
    } on FormatException {
      return _unknown(claim);
    }
  }

  ClaimVerdict _unknown(String claim) =>
      ClaimVerdict(claim: claim, verdict: ClaimVerdictKind.unknown);

  bool _containsEvidence(String corpus, String evidence) {
    final normalizedCorpus = _normalize(corpus);
    return normalizedCorpus.contains(_normalize(evidence));
  }

  String _normalize(String value) => value.replaceAll(RegExp(r'\s+'), '');

  String _truncate(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);
}

/// 网络证据只降分：contradicted 每条扣 0.5，clamp 到 1..5。
TurnScore applyFactCheckPenalty(TurnScore score, List<ClaimVerdict> verdicts) {
  final contradictions = verdicts
      .where((ClaimVerdict v) => v.contradicts)
      .length;
  if (contradictions == 0) return score;
  final correctness = (score.correctness - 0.5 * contradictions).clamp(
    1.0,
    5.0,
  );
  return TurnScore(
    correctness: correctness,
    depth: score.depth,
    structure: score.structure,
    coverage: score.coverage,
    points: score.points,
    factualErrors: <FactualError>[
      ...score.factualErrors,
      for (final verdict in verdicts.where((ClaimVerdict v) => v.contradicts))
        FactualError(
          quote: verdict.claim,
          issue: '联网核查：${verdict.evidence}',
          sources: verdict.sources
              .map((SourceRef s) => s.url)
              .toList(growable: false),
        ),
    ],
    factChecks: <TurnScoreFactCheck>[
      for (final verdict in verdicts)
        TurnScoreFactCheck(
          claim: verdict.claim,
          verdict: verdict.verdict.name,
          evidence: verdict.evidence,
          sources: verdict.sources
              .map((SourceRef source) => source.url)
              .toList(growable: false),
        ),
    ],
    comment: score.comment,
    degraded: score.degraded,
    lowConfidence: score.lowConfidence,
  );
}
