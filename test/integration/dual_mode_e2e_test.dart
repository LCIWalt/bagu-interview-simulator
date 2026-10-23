import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/interview/domain/scoring/scoring_engine.dart';

import '../fakes/fakes.dart';

const String _prompt =
    '---\n'
    'id: scorer.rubric\n'
    'version: 1\n'
    'model: m\n'
    'temperature: 0.2\n'
    'variables: [questionTitle, keyPoints, pitfalls, answerText, followupDepth]\n'
    '---\n'
    '{{questionTitle}} {{keyPoints}} {{pitfalls}} {{answerText}} {{followupDepth}}\n';

String _scoreJson(String evidence) => jsonEncode(<String, Object?>{
  'points': <Object?>[
    <String, Object?>{'point': 'kp1', 'verdict': 'hit', 'evidence': evidence},
  ],
  'factualErrors': <Object?>[],
  'correctness': 4,
  'depth': 3,
  'structure': 3,
  'comment': '',
});

Question _question(String id) => Question(
  id: id,
  bankVersion: 'v1',
  title: 'E2E 题目 $id',
  bodyMarkdown: '',
  topics: const <String>['go'],
  role: 'backend',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: const QuestionAnswer(summary: 's', keyPoints: <String>['kp1']),
  updatedAt: DateTime.utc(2026),
);

void main() {
  test(
    '20 practice turns + 12 mock turns with FakeLlmClient produce reports',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final repo = DriftSessionRepository(db);
      final prompts = PromptRegistry(<String, PromptTemplate>{
        'scorer.rubric': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
      });
      final questions = <Question>[_question('q1'), _question('q2')];
      final engine = ScoringEngine(
        client: FakeLlmClient(
          script: <FakeLlmTurn>[
            for (var i = 0; i < 32; i++)
              FakeLlmTurn(textChunks: <String>[_scoreJson('answer $i')]),
          ],
        ),
        prompts: prompts,
        model: 'm',
      );

      // 练习模式：20 题。
      final drill = await repo.create(
        const SessionConfig(
          mode: SessionMode.drill,
          role: 'backend',
          level: 'mid',
        ),
      );
      for (var i = 0; i < 20; i++) {
        final question = questions[i % 2];
        final turn = await repo.appendAnswer(
          drill.id,
          AnswerInput(
            id: 't_drill_$i',
            questionId: question.id,
            questionText: question.title,
            text: 'answer $i',
            tStartedAt: DateTime.now(),
          ),
        );
        final score = await engine.score(
          question: question,
          answerText: 'answer $i',
        );
        await repo.saveScore(turn.id, score);
      }
      final drillReport = await repo.finish(drill.id);
      expect(drillReport.turns, hasLength(20));
      expect(drillReport.dimensions['correctness'], closeTo(4, 1e-9));
      expect(drillReport.sampleShortfall, isFalse);

      // 实战模式：12 轮 + 报告快照。
      final mock = await repo.create(
        const SessionConfig(
          mode: SessionMode.mock,
          role: 'backend',
          level: 'senior',
        ),
      );
      for (var i = 0; i < 12; i++) {
        final question = questions[i % 2];
        final turn = await repo.appendAnswer(
          mock.id,
          AnswerInput(
            id: 't_mock_$i',
            questionId: question.id,
            questionText: question.title,
            text: 'answer ${i + 20}',
            tStartedAt: DateTime.now(),
          ),
        );
        final score = await engine.score(
          question: question,
          answerText: 'answer ${i + 20}',
        );
        await repo.saveScore(turn.id, score);
      }
      final mockReport = await repo.finish(mock.id);
      expect(mockReport.turns, hasLength(12));
      expect(mockReport.markdown, contains('# MockMate 面试报告'));
      expect(mockReport.markdown, contains('## 逐题回顾'));
      expect(mockReport.sevenDayPlan, hasLength(7));
      expect(mockReport.interviewerView, isNotEmpty);
    },
  );
}
