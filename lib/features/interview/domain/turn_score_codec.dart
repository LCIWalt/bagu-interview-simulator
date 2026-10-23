import 'dart:convert';

import 'package:mockmate/core/contracts/contracts.dart';

/// 单题评分与 `turns.score_json` 的编解码。
abstract final class TurnScoreCodec {
  static String encode(TurnScore score) => jsonEncode(<String, Object?>{
    'correctness': score.correctness,
    'depth': score.depth,
    'structure': score.structure,
    'coverage': score.coverage,
    'comment': score.comment,
    'degraded': score.degraded,
    'lowConfidence': score.lowConfidence,
    'points': score.points
        .map(
          (TurnScorePoint point) => <String, Object?>{
            'point': point.point,
            'verdict': point.verdict,
            'evidence': point.evidence,
          },
        )
        .toList(growable: false),
    'factualErrors': score.factualErrors
        .map(
          (FactualError error) => <String, Object?>{
            'quote': error.quote,
            'issue': error.issue,
            'sources': error.sources,
          },
        )
        .toList(growable: false),
  });

  static TurnScore? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      double readNumber(Object? value) => value is num ? value.toDouble() : 0;
      return TurnScore(
        correctness: readNumber(decoded['correctness']),
        depth: readNumber(decoded['depth']),
        structure: readNumber(decoded['structure']),
        coverage: readNumber(decoded['coverage']),
        comment: decoded['comment']?.toString() ?? '',
        degraded: decoded['degraded'] == true,
        lowConfidence: decoded['lowConfidence'] == true,
        points: (decoded['points'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> point) => TurnScorePoint(
                point: point['point']?.toString() ?? '',
                verdict: point['verdict']?.toString() ?? 'miss',
                evidence: point['evidence']?.toString() ?? '',
              ),
            )
            .toList(growable: false),
        factualErrors:
            (decoded['factualErrors'] as List<Object?>? ?? const <Object?>[])
                .whereType<Map<String, dynamic>>()
                .map(
                  (Map<String, dynamic> error) => FactualError(
                    quote: error['quote']?.toString() ?? '',
                    issue: error['issue']?.toString() ?? '',
                    sources:
                        (error['sources'] as List<Object?>? ??
                                const <Object?>[])
                            .map((Object? source) => '$source')
                            .toList(growable: false),
                  ),
                )
                .toList(growable: false),
        factChecks:
            (decoded['factChecks'] as List<Object?>? ?? const <Object?>[])
                .whereType<Map<String, dynamic>>()
                .map(
                  (Map<String, dynamic> check) => TurnScoreFactCheck(
                    claim: check['claim']?.toString() ?? '',
                    verdict: check['verdict']?.toString() ?? 'unknown',
                    evidence: check['evidence']?.toString() ?? '',
                    sources:
                        (check['sources'] as List<Object?>? ??
                                const <Object?>[])
                            .map((Object? source) => '$source')
                            .toList(growable: false),
                  ),
                )
                .toList(growable: false),
      );
    } on FormatException {
      return null;
    }
  }
}

SessionStatus parseSessionStatus(String raw) => switch (raw) {
  'completed' => SessionStatus.completed,
  'abandoned' => SessionStatus.abandoned,
  _ => SessionStatus.active,
};

String encodeSessionStatus(SessionStatus status) => status.name;
