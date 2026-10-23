import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/features/interview/domain/selection/question_selector.dart';

Question q(
  String id, {
  int difficulty = 3,
  List<String> topics = const <String>['go'],
}) {
  return Question(
    id: id,
    bankVersion: 'v1',
    title: id,
    bodyMarkdown: '',
    topics: topics,
    role: 'backend',
    level: 3,
    difficulty: difficulty,
    type: QuestionType.knowledge,
    answer: const QuestionAnswer(summary: 's', keyPoints: <String>['k']),
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  const config = SessionConfig(
    mode: SessionMode.drill,
    role: 'backend',
    level: 'mid',
    topics: <String>['go'],
  );

  test('prefers matching topics and fresh questions', () {
    final selector = QuestionSelector();
    final context = QuestionSelectionContext(
      config: config,
      recentIds: <String>{'seen'},
    );
    final selection = selector.select(<Question>[
      q('seen'),
      q('other', topics: const <String>['react']),
      q('match'),
    ], context);
    expect(selection?.question.id, 'match');
  });

  test('excludes questions already asked in this session', () {
    final selector = QuestionSelector();
    final selection = selector.select(<Question>[
      q('a'),
      q('b'),
    ], const QuestionSelectionContext(config: config, askedIds: <String>{'a'}));
    expect(selection?.question.id, 'b');
    expect(
      selector.select(
        <Question>[q('a')],
        const QuestionSelectionContext(config: config, askedIds: <String>{'a'}),
      ),
      isNull,
    );
  });

  test('first question is easier and later adapts to score', () {
    final selector = QuestionSelector();
    final first = selector.select(<Question>[
      q('easy', difficulty: 2),
      q('hard', difficulty: 5),
    ], const QuestionSelectionContext(config: config));
    expect(first?.question.id, 'easy');

    final high = selector.select(
      <Question>[q('easy', difficulty: 2), q('hard', difficulty: 4)],
      const QuestionSelectionContext(
        config: config,
        lastScore: 4.5,
        questionIndex: 2,
      ),
    );
    expect(high?.question.id, 'hard');
    expect(high?.followupDepth, 3); // 默认 2 -> 3
  });

  test('low score lowers followup depth and enables hint when allowed', () {
    final selector = QuestionSelector();
    final selection = selector.select(
      <Question>[q('easy', difficulty: 1), q('hard', difficulty: 5)],
      const QuestionSelectionContext(
        config: SessionConfig(
          mode: SessionMode.drill,
          role: 'backend',
          level: 'mid',
          followupDepth: 1,
          allowHints: true,
        ),
        lastScore: 1.5,
        questionIndex: 1,
      ),
    );
    expect(selection?.followupDepth, 0);
    expect(selection?.allowHint, isTrue);
  });

  test('weak topics contribute to the score', () {
    final selector = QuestionSelector();
    final selection = selector.select(
      <Question>[
        q('go', topics: <String>['go']),
        q('db', topics: <String>['db']),
      ],
      const QuestionSelectionContext(
        config: SessionConfig(
          mode: SessionMode.drill,
          role: 'backend',
          level: 'mid',
          topics: <String>['go', 'db'],
        ),
        weakTopics: <String, double>{'db': 1},
      ),
    );
    expect(selection?.question.id, 'db');
  });
}
