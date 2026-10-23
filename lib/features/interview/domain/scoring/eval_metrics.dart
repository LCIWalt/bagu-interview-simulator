import 'dart:math';

class EvalSampleResult {
  const EvalSampleResult({
    required this.id,
    required this.predicted,
    required this.human,
    required this.answerChars,
    required this.evidenceOk,
    required this.jsonOk,
  });

  final String id;
  final double predicted;
  final double human;
  final int answerChars;
  final bool evidenceOk;
  final bool jsonOk;
}

/// 校准指标（指南 §7.3.2）：MAE、宽松偏差、长度相关性、证据率、JSON 合法率。
class EvalReport {
  const EvalReport({
    required this.samples,
    required this.mae,
    required this.bias,
    required this.lengthCorrelation,
    required this.evidenceRate,
    required this.jsonValidRate,
  });

  final int samples;
  final double mae;
  final double bias;
  final double lengthCorrelation;
  final double evidenceRate;
  final double jsonValidRate;

  bool get passes =>
      mae <= 0.5 &&
      bias.abs() <= 0.2 &&
      lengthCorrelation.abs() < 0.3 &&
      evidenceRate >= 0.999 &&
      jsonValidRate >= 0.99;

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('| 指标 | 值 | 阈值 | 结果 |')
      ..writeln('|---|---|---|---|')
      ..writeln('| 样本数 | $samples | — | — |')
      ..writeln(
        '| MAE | ${mae.toStringAsFixed(2)} | ≤ 0.5 | ${mae <= 0.5 ? 'PASS' : 'FAIL'} |',
      )
      ..writeln(
        '| 宽松偏差 | ${bias.toStringAsFixed(2)} | ±0.2 | ${bias.abs() <= 0.2 ? 'PASS' : 'FAIL'} |',
      )
      ..writeln(
        '| 长度相关性 | ${lengthCorrelation.toStringAsFixed(2)} | \\|r\\| < 0.3 | ${lengthCorrelation.abs() < 0.3 ? 'PASS' : 'FAIL'} |',
      )
      ..writeln(
        '| 证据率 | ${(evidenceRate * 100).toStringAsFixed(1)}% | 100% | ${evidenceRate >= 0.999 ? 'PASS' : 'FAIL'} |',
      )
      ..writeln(
        '| JSON 合法率 | ${(jsonValidRate * 100).toStringAsFixed(1)}% | ≥ 99% | ${jsonValidRate >= 0.99 ? 'PASS' : 'FAIL'} |',
      );
    return buffer.toString();
  }
}

EvalReport computeEvalReport(List<EvalSampleResult> results) {
  if (results.isEmpty) {
    return const EvalReport(
      samples: 0,
      mae: 0,
      bias: 0,
      lengthCorrelation: 0,
      evidenceRate: 0,
      jsonValidRate: 0,
    );
  }
  var absolute = 0.0;
  var signed = 0.0;
  var evidence = 0;
  var json = 0;
  for (final result in results) {
    absolute += (result.predicted - result.human).abs();
    signed += result.predicted - result.human;
    if (result.evidenceOk) evidence++;
    if (result.jsonOk) json++;
  }
  return EvalReport(
    samples: results.length,
    mae: absolute / results.length,
    bias: signed / results.length,
    lengthCorrelation: _pearson(
      results
          .map((EvalSampleResult r) => r.answerChars.toDouble())
          .toList(growable: false),
      results.map((EvalSampleResult r) => r.predicted).toList(growable: false),
    ),
    evidenceRate: evidence / results.length,
    jsonValidRate: json / results.length,
  );
}

/// 皮尔逊相关系数；方差为 0 时返回 0。
double _pearson(List<double> xs, List<double> ys) {
  if (xs.length != ys.length || xs.isEmpty) return 0;
  final meanX = xs.reduce((double a, double b) => a + b) / xs.length;
  final meanY = ys.reduce((double a, double b) => a + b) / ys.length;
  var covariance = 0.0;
  var varianceX = 0.0;
  var varianceY = 0.0;
  for (var i = 0; i < xs.length; i++) {
    final dx = xs[i] - meanX;
    final dy = ys[i] - meanY;
    covariance += dx * dy;
    varianceX += dx * dx;
    varianceY += dy * dy;
  }
  if (varianceX == 0 || varianceY == 0) return 0;
  return covariance / sqrt(varianceX * varianceY);
}
