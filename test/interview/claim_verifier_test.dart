import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/interview/domain/factcheck/claim_extractor.dart';
import 'package:mockmate/features/interview/domain/factcheck/claim_verifier.dart';

import '../fakes/fakes.dart';

const String _prompt = '''
---
id: claim.verify
version: 1
model: m
temperature: 0.1
variables: [claim, evidence]
---
{{claim}}
{{evidence}}
''';

const String _claim = 'Go 1.22 起 loop var 每轮创建新变量';
const String _pageText = '从 Go 1.22 开始，for 循环的循环变量每轮迭代都会创建新的变量。';
const String _evidence = 'Go 1.22 开始，for 循环的循环变量每轮迭代都会创建新的变量';

class _FakeSearch implements SearchProvider {
  _FakeSearch({this.authority = SourceAuthority.a, this.fail = false});

  final SourceAuthority authority;
  final bool fail;
  int searches = 0;

  @override
  String get id => 'fake';

  @override
  Future<List<SearchHit>> search(SearchQuery q) async {
    searches++;
    if (fail) throw const NetworkFailure('offline');
    return <SearchHit>[
      SearchHit(
        url: authority == SourceAuthority.a
            ? 'https://go.dev/doc/go1.22'
            : 'https://stackoverflow.com/q/1',
        title: 'Go 1.22 release notes',
        snippet: 'loop var',
        authority: authority,
      ),
    ];
  }

  @override
  Future<ExtractedPage> fetch(String url) async {
    return ExtractedPage(
      url: url,
      title: 'Go 1.22 release notes',
      textMarkdown: _pageText,
      fetchedAt: DateTime.now(),
      authority: authority,
    );
  }
}

String _judgeJson({
  String verdict = 'contradicted',
  String evidence = _evidence,
  String url = 'https://go.dev/doc/go1.22',
}) {
  return jsonEncode(<String, Object?>{
    'verdict': verdict,
    'confidence': 0.9,
    'evidence': evidence,
    'sources': <String>[url],
  });
}

void main() {
  final prompts = PromptRegistry(<String, PromptTemplate>{
    'claim.verify': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
  });

  test('verifies contradicted with an A source and exact evidence', () async {
    final verifier = ClaimVerifier(
      search: _FakeSearch(),
      judge: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(textChunks: <String>[_judgeJson()]),
        ],
      ),
      prompts: prompts,
      model: 'm',
    );
    final verdict = await verifier.verify(
      const ExtractedClaim(
        text: _claim,
        risk: 'high',
        queries: <String>['q1', 'q2'],
      ),
    );
    expect(verdict.verdict, ClaimVerdictKind.contradicted);
    expect(verdict.sources.single.authority, SourceAuthority.a);
    expect(verdict.evidence, isNotEmpty);
  });

  test('C-only sources cannot produce contradicted', () async {
    final verifier = ClaimVerifier(
      search: _FakeSearch(authority: SourceAuthority.c),
      judge: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            textChunks: <String>[
              _judgeJson(url: 'https://stackoverflow.com/q/1'),
            ],
          ),
        ],
      ),
      prompts: prompts,
      model: 'm',
    );
    final verdict = await verifier.verify(
      const ExtractedClaim(text: _claim, risk: 'high', queries: <String>['q']),
    );
    expect(verdict.verdict, ClaimVerdictKind.unknown);
  });

  test('fabricated evidence or network failure yields unknown', () async {
    final fabricated = ClaimVerifier(
      search: _FakeSearch(),
      judge: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(textChunks: <String>[_judgeJson(evidence: '页面里没有这句')]),
        ],
      ),
      prompts: prompts,
      model: 'm',
    );
    expect(
      (await fabricated.verify(
        const ExtractedClaim(text: _claim, risk: 'high'),
      )).verdict,
      ClaimVerdictKind.unknown,
    );

    final offline = ClaimVerifier(
      search: _FakeSearch(fail: true),
      judge: FakeLlmClient(),
      prompts: prompts,
      model: 'm',
    );
    expect(
      (await offline.verify(const ExtractedClaim(text: _claim, risk: 'high')))
          .verdict,
      ClaimVerdictKind.unknown,
    );
  });

  test('caches verdicts and does not re-search', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final cache = FactCheckCache(db);
    final search = _FakeSearch();
    final verifier = ClaimVerifier(
      search: search,
      judge: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(textChunks: <String>[_judgeJson()]),
        ],
      ),
      prompts: prompts,
      model: 'm',
      cache: cache,
    );
    await verifier.verify(const ExtractedClaim(text: _claim, risk: 'high'));
    final firstCount = search.searches;
    final second = await verifier.verify(
      const ExtractedClaim(text: _claim, risk: 'high'),
    );
    expect(second.cached, isTrue);
    expect(second.verdict, ClaimVerdictKind.contradicted);
    expect(search.searches, firstCount);
  });

  test('only-down penalty subtracts 0.5 per contradiction', () {
    const score = TurnScore(
      correctness: 4,
      depth: 3,
      structure: 3,
      coverage: 1,
    );
    final verdicts = <ClaimVerdict>[
      const ClaimVerdict(
        claim: 'a',
        verdict: ClaimVerdictKind.contradicted,
        evidence: 'x',
      ),
    ];
    final updated = applyFactCheckPenalty(score, verdicts);
    expect(updated.correctness, closeTo(3.5, 1e-9));
    expect(updated.factualErrors, hasLength(1));
    expect(updated.factChecks, hasLength(1));
    expect(updated.factChecks.single.verdict, 'contradicted');
  });
}
