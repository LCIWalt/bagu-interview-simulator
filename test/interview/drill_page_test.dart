import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/interview/domain/scoring/scoring_engine.dart';
import 'package:mockmate/features/interview/presentation/drill/drill_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

import '../fakes/fakes.dart';

final Question _question = Question(
  id: 'q1',
  bankVersion: '2026.10.1',
  title: 'Go 的 GMP 模型里，为什么需要 P？',
  bodyMarkdown: '请说明 P 的作用。',
  topics: const <String>['go'],
  role: 'backend',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: const QuestionAnswer(
    summary: 'summary',
    keyPoints: <String>['M 与 P 解耦', 'syscall 时 P 移交'],
  ),
  status: QuestionStatus.verified,
  updatedAt: DateTime.utc(2026),
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

const String _prompt = '''
---
id: scorer.rubric
version: 1
model: m
temperature: 0.2
variables: [questionTitle, keyPoints, pitfalls, answerText, followupDepth]
---
{{questionTitle}}
{{keyPoints}}
{{pitfalls}}
{{answerText}}
{{followupDepth}}
''';

final PromptRegistry _prompts = PromptRegistry(<String, PromptTemplate>{
  'scorer.rubric': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
});

void main() {
  testWidgets('submit -> score card -> appeal persisted', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sessionRepo = DriftSessionRepository(db);
    final scoreJson = jsonEncode(<String, Object?>{
      'points': <Object?>[
        <String, Object?>{
          'point': 'M 与 P 解耦',
          'verdict': 'hit',
          'evidence': 'M 与 P 解耦',
        },
        <String, Object?>{
          'point': 'syscall 时 P 移交',
          'verdict': 'miss',
          'evidence': '',
        },
      ],
      'factualErrors': <Object?>[],
      'correctness': 4,
      'depth': 4,
      'structure': 3,
      'comment': '结构清晰',
    });
    final engine = ScoringEngine(
      client: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(textChunks: <String>[scoreJson]),
        ],
      ),
      prompts: _prompts,
      model: 'deepseek-chat',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          bankRepositoryProvider.overrideWithValue(
            FakeBankRepository(questions: <Question>[_question]),
          ),
          sessionRepositoryProvider.overrideWithValue(sessionRepo),
          sessionRepositoryImplProvider.overrideWithValue(sessionRepo),
          scoringEngineFactoryProvider.overrideWithValue(
            (String sessionId) async => engine,
          ),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const DrillPage(),
        ),
      ),
    );
    await _settle(tester);

    expect(find.text(_question.title), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'M 与 P 解耦，P 提供执行上下文。');
    await tester.tap(find.text('提交评分'));
    await _settle(tester);

    expect(find.text('本题评分'), findsOneWidget);
    expect(find.textContaining('/ 5'), findsWidgets);
    expect(find.text('结构清晰'), findsOneWidget);

    await tester.tap(find.text('这点我答了'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).last, '我在回答里提到了 syscall 移交');
    await tester.tap(find.text('提交评分').last);
    await _settle(tester);

    final turns = await sessionRepo.turnsFor(
      (await sessionRepo.activeSession())!.id,
    );
    final settings = await db.select(db.settings).get();
    expect(
      settings.any((Setting row) => row.key == 'appeal.${turns.single.id}'),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox());
  });
}
