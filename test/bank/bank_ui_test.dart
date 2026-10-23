import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/features/bank/data/question_local_repository.dart';
import 'package:mockmate/features/bank/presentation/bank_page.dart';
import 'package:mockmate/features/bank/presentation/question_detail_page.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

import '../fakes/fakes.dart';

class _RecordingBankRepository extends FakeBankRepository {
  _RecordingBankRepository({super.questions});

  final List<QuestionQuery> queries = <QuestionQuery>[];

  @override
  Future<List<Question>> search(QuestionQuery q) {
    queries.add(q);
    var result = questions;
    if (q.text.isNotEmpty) {
      result = result
          .where((Question item) => item.title.contains(q.text))
          .toList();
    }
    if (q.role != null) {
      result = result.where((Question item) => item.role == q.role).toList();
    }
    return Future<List<Question>>.value(result);
  }
}

Question _q(String id, {String role = 'backend', String title = ''}) =>
    Question(
      id: id,
      bankVersion: '2026.10.1',
      title: title.isEmpty ? '数据库索引为什么用 B+ 树 $id' : title,
      bodyMarkdown: '题干正文',
      topics: const <String>['mysql', 'index'],
      role: role,
      level: 3,
      difficulty: 3,
      type: QuestionType.knowledge,
      answer: const QuestionAnswer(
        summary: '参考答案：B+ 树扇出大、叶子有序。',
        keyPoints: <String>['非叶子只存键', '叶子链表支持范围扫描'],
      ),
      source: const QuestionSource(
        url: 'https://example.com',
        title: 'src',
        license: 'MIT',
      ),
      status: QuestionStatus.verified,
      updatedAt: DateTime.utc(2026),
    );

Widget _app(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: buildMockTheme(Brightness.light),
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  ),
);

void main() {
  testWidgets('bank list renders and debounces search by 300ms', (
    WidgetTester tester,
  ) async {
    final repo = _RecordingBankRepository(
      questions: <Question>[
        _q('q1'),
        _q('q2', role: 'frontend', title: 'React 列表 key'),
      ],
    );
    await tester.pumpWidget(
      _app(const BankPage(), <Override>[
        bankRepositoryProvider.overrideWithValue(repo),
        seedBankProvider.overrideWith((Ref ref) async => false),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('B+ 树'), findsWidgets);
    expect(repo.queries, hasLength(1));

    await tester.enterText(find.byType(TextField).first, 'React');
    await tester.pump(const Duration(milliseconds: 150));
    expect(repo.queries, hasLength(1), reason: '防抖期间不应触发查询');

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(repo.queries.length, greaterThanOrEqualTo(2));
    expect(repo.queries.last.text, 'React');
    expect(find.text('React 列表 key'), findsOneWidget);
    expect(find.textContaining('B+ 树'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '前端'));
    await tester.pumpAndSettle();
    expect(repo.queries.last.role, 'frontend');
  });

  testWidgets('detail reveals answer and saves notes after debounce', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final question = _q('q1');
    final local = QuestionLocalRepository(db);

    await tester.pumpWidget(
      _app(const QuestionDetailPage(questionId: 'q1'), <Override>[
        bankRepositoryProvider.overrideWithValue(
          FakeBankRepository(questions: <Question>[question]),
        ),
        questionLocalRepositoryProvider.overrideWithValue(local),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text(question.title), findsOneWidget);
    expect(find.textContaining('B+ 树扇出大'), findsNothing);

    await tester.tap(find.text('先自答，再看答案'));
    await tester.pumpAndSettle();
    expect(find.textContaining('B+ 树扇出大'), findsOneWidget);
    expect(find.text('非叶子只存键'), findsOneWidget);

    final noteField = find.byType(TextField).last;
    await tester.enterText(noteField, '我的 B+ 树笔记');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect((await local.get('q1'))?.noteMd, '我的 B+ 树笔记');
  });
}
