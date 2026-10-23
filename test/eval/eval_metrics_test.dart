import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/features/interview/domain/scoring/eval_metrics.dart';

void main() {
  test('computes MAE, bias, correlation, evidence and JSON rates', () {
    final report = computeEvalReport(const <EvalSampleResult>[
      EvalSampleResult(
        id: 'a',
        predicted: 3,
        human: 3,
        answerChars: 100,
        evidenceOk: true,
        jsonOk: true,
      ),
      EvalSampleResult(
        id: 'b',
        predicted: 4,
        human: 3.5,
        answerChars: 500,
        evidenceOk: true,
        jsonOk: true,
      ),
      EvalSampleResult(
        id: 'c',
        predicted: 2,
        human: 3,
        answerChars: 1000,
        evidenceOk: false,
        jsonOk: true,
      ),
    ]);
    expect(report.mae, closeTo((0 + 0.5 + 1) / 3, 1e-9));
    expect(report.bias, closeTo((0 + 0.5 - 1) / 3, 1e-9));
    expect(report.evidenceRate, closeTo(2 / 3, 1e-9));
    expect(report.jsonValidRate, 1);
    expect(report.lengthCorrelation, closeTo(-0.554, 0.01));
  });

  test('passes only when all thresholds are met', () {
    const good = EvalReport(
      samples: 40,
      mae: 0.4,
      bias: 0.1,
      lengthCorrelation: 0.2,
      evidenceRate: 1,
      jsonValidRate: 1,
    );
    expect(good.passes, isTrue);
    const biased = EvalReport(
      samples: 40,
      mae: 0.4,
      bias: 0.3,
      lengthCorrelation: 0.2,
      evidenceRate: 1,
      jsonValidRate: 1,
    );
    expect(biased.passes, isFalse);
  });
}
