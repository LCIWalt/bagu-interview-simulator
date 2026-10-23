import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mockmate/core/agent/prompts/prompt_source_base.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/llm/openai_compatible_client.dart';
import 'package:mockmate/features/interview/domain/scoring/eval_metrics.dart';
import 'package:mockmate/features/interview/domain/scoring/scoring_engine.dart';

/// 校准评测（T-055/T-056）。需要真实 key，CI 跳过。
///
/// 用法：
///   SCORER_API_KEY=... SCORER_BASE_URL=https://api.deepseek.com SCORER_MODEL=deepseek-chat \
///     dart run tool/eval.dart [--dataset test/eval/calibration_set.json] [--perturb]
Future<void> main(List<String> args) async {
  final datasetPath =
      _arg(args, '--dataset') ?? 'test/eval/calibration_set.json';
  final perturb = args.contains('--perturb');
  final apiKey = Platform.environment['SCORER_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    stderr.writeln('缺少 SCORER_API_KEY；CI 跳过真实评测。');
    exitCode = 2;
    return;
  }
  final baseUrl =
      Platform.environment['SCORER_BASE_URL'] ?? 'https://api.deepseek.com';
  final model = Platform.environment['SCORER_MODEL'] ?? 'deepseek-chat';

  final dataset =
      jsonDecode(File(datasetPath).readAsStringSync()) as List<dynamic>;
  final prompts = await PromptRegistry.load(
    _FilePromptSource(Directory('assets/prompts')),
  );
  final client = OpenAiCompatibleClient(
    id: 'eval',
    baseUrl: Uri.parse(baseUrl),
    apiKey: apiKey,
  );
  final engine = ScoringEngine(client: client, prompts: prompts, model: model);

  final results = <EvalSampleResult>[];
  final deltas = <double>[];
  for (final raw in dataset) {
    final sample = raw as Map<String, dynamic>;
    final question = _question(sample);
    final answer = sample['answer']?.toString() ?? '';
    final score = await engine.score(question: question, answerText: answer);
    final human = (sample['humanScore'] as num?)?.toDouble() ?? 0;
    final evidenceOk = score.points
        .where(
          (TurnScorePoint p) => p.verdict == 'hit' || p.verdict == 'partial',
        )
        .every((TurnScorePoint p) => p.evidence.isNotEmpty);
    results.add(
      EvalSampleResult(
        id: sample['id']?.toString() ?? '?',
        predicted: score.total,
        human: human,
        answerChars: answer.length,
        evidenceOk: evidenceOk,
        jsonOk: !score.degraded,
      ),
    );
    if (perturb) {
      final filler = ' 补充说明。' * (max(1, (3000 - answer.length) ~/ 6));
      final padded = '$answer$filler';
      final perturbed = await engine.score(
        question: question,
        answerText: padded,
      );
      deltas.add((perturbed.total - score.total).abs());
    }
  }

  final report = computeEvalReport(results);
  stdout
    ..writeln('# MockMate 校准评测')
    ..writeln()
    ..writeln(report.toMarkdown())
    ..writeln()
    ..writeln('数据集：$datasetPath；模型：$model');
  if (perturb && deltas.isNotEmpty) {
    final average =
        deltas.reduce((double a, double b) => a + b) / deltas.length;
    final worst = deltas.reduce(max);
    stdout
      ..writeln()
      ..writeln(
        '长度扰动（扩写到约 3000 字）：平均变化 ${average.toStringAsFixed(2)}，'
        '最大 ${worst.toStringAsFixed(2)}（阈值 < 0.3）',
      );
  }
  exitCode = report.passes && (!perturb || deltas.every((double d) => d < 0.3))
      ? 0
      : 1;
}

String? _arg(List<String> args, String name) {
  final index = args.indexOf(name);
  return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
}

Question _question(Map<String, dynamic> sample) {
  final json =
      sample['question'] as Map<String, dynamic>? ?? const <String, dynamic>{};
  List<String> strings(Object? value) =>
      (value as List<Object?>? ?? const <Object?>[])
          .map((Object? item) => '$item')
          .toList(growable: false);
  return Question(
    id: sample['id']?.toString() ?? 'q',
    bankVersion: 'eval',
    title: json['title']?.toString() ?? '',
    bodyMarkdown: '',
    topics: const <String>[],
    role: sample['role']?.toString() ?? 'backend',
    level: 3,
    difficulty: (sample['difficulty'] as num?)?.toInt() ?? 3,
    type: QuestionType.knowledge,
    answer: QuestionAnswer(
      summary: '',
      keyPoints: strings(json['keyPoints']),
      pitfalls: strings(json['pitfalls']),
    ),
    updatedAt: DateTime.utc(2026),
  );
}

class _FilePromptSource implements PromptSource {
  _FilePromptSource(this.directory);

  final Directory directory;

  @override
  Future<String> read(String assetPath) => File(assetPath).readAsString();

  @override
  Future<List<String>> list(String directory) async {
    return this.directory
        .listSync()
        .whereType<File>()
        .map((File file) => file.path)
        .where((String path) => path.endsWith('.md'))
        .toList()
      ..sort();
  }
}
