import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/bank_repository_impl.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/domain/experience_extractor.dart';
import 'package:mockmate/features/bank/presentation/import/experience_import_sheet.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

import '../fakes/fakes.dart';

const String _prompt = '''
---
id: experience.extract
version: 1
model: m
temperature: 0.2
variables: [experienceText]
---
{{experienceText}}
''';

const String _experience =
    '面试官先问 GMP 里 P 的作用，我回答了执行上下文。'
    '接着问 TCP 三次握手，我讲了序列号确认。';

String _response() => jsonEncode(<String, Object?>{
  'questions': <Object?>[
    <String, Object?>{
      'title': 'Go 的 P 有什么作用？',
      'role': 'backend',
      'level': 'mid',
      'difficulty': 3,
      'topics': <String>['go'],
      'keyPoints': <String>['P 提供执行上下文', 'M 需要绑定 P'],
      'followups': <String>['P 的数量如何决定'],
      'evidence': '面试官先问 GMP 里 P 的作用',
    },
    <String, Object?>{
      'title': 'TCP 为什么三次握手？',
      'role': 'backend',
      'level': 'senior',
      'difficulty': 4,
      'topics': <String>['network'],
      'keyPoints': <String>['确认序列号'],
      'evidence': '接着问 TCP 三次握手',
    },
    <String, Object?>{
      'title': '编造的题',
      'role': 'backend',
      'level': 'mid',
      'difficulty': 2,
      'topics': <String>['x'],
      'keyPoints': <String>['编造'],
      'evidence': '面经中不存在这句话',
    },
  ],
});

ExperienceExtractor _extractor() {
  final prompts = PromptRegistry(<String, PromptTemplate>{
    'experience.extract': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
  });
  return ExperienceExtractor(
    client: FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>[_response()]),
      ],
    ),
    prompts: prompts,
    model: 'm',
  );
}

void main() {
  test('extracts only evidence-backed, deduped drafts', () async {
    final drafts = await _extractor().extract(_experience);
    expect(drafts, hasLength(2));
    expect(drafts.first.keyPoints, hasLength(2));
    expect(drafts.first.toQuestion().status.name, 'user');
    expect(drafts.first.toQuestion().id, startsWith('exp-'));
  });

  testWidgets('sheet extracts and saves selected drafts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = BankRepositoryImpl(db);
    final local = QuestionLocalRepository(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          experienceExtractorProvider.overrideWith(
            (Ref ref) async => _extractor(),
          ),
          bankRepositoryImplProvider.overrideWithValue(repo),
          questionLocalRepositoryProvider.overrideWithValue(local),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: ExperienceImportSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, _experience);
    await tester.tap(find.text('提取草稿'));
    await tester.pumpAndSettle();
    expect(find.text('Go 的 P 有什么作用？'), findsOneWidget);
    expect(find.text('TCP 为什么三次握手？'), findsOneWidget);

    await tester.tap(find.text('保存 2 道'));
    await tester.pumpAndSettle();
    expect(await repo.countQuestions(), 2);
    final created = await repo.search(const QuestionQuery(text: 'P 有什么作用'));
    expect((await local.get(created.single.id))?.origin, 'experience');
  });
}
