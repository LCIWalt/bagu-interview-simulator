import 'package:mockmate/core/contracts/contracts.dart';

import 'claim_extractor.dart';
import 'claim_verifier.dart';

/// 评分官异步核查管线（T-053）：断言抽取 → 仅高风险 → 联网判定 → 只降分。
class FactCheckService {
  FactCheckService({
    required this.extractor,
    required this.verifier,
    this.maxClaims = 3,
  });

  final ClaimExtractor extractor;
  final ClaimVerifier verifier;
  final int maxClaims;

  Future<List<ClaimVerdict>> checkAnswer({
    required String answerText,
    CancelToken? cancel,
  }) async {
    final claims = await extractor.extract(
      answerText: answerText,
      cancel: cancel,
    );
    final risky = claims
        .where((ExtractedClaim claim) => claim.isHighRisk)
        .take(maxClaims);
    final verdicts = <ClaimVerdict>[];
    for (final claim in risky) {
      cancel?.throwIfCancelled();
      verdicts.add(await verifier.verify(claim, cancel: cancel));
    }
    return verdicts;
  }
}
