import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/features/bank/data/dedup/similar_question_detector.dart';

Question q(
  String id,
  String title, {
  List<String> topics = const <String>['mysql'],
  List<String> keyPoints = const <String>['B+ 树扇出大', '叶子链表范围查询'],
}) {
  return Question(
    id: id,
    bankVersion: 'v1',
    title: title,
    bodyMarkdown: '',
    topics: topics,
    role: 'backend',
    level: 3,
    difficulty: 3,
    type: QuestionType.knowledge,
    answer: QuestionAnswer(summary: 's', keyPoints: keyPoints),
    updatedAt: DateTime.utc(2026),
  );
}

void main() {
  const detector = SimilarQuestionDetector();

  test('detects near-duplicate titles with shared key points', () {
    final a = q('a', 'MySQL 为什么用 B+ 树做索引？');
    final b = q('b', '为什么 MySQL 使用 B+ 树索引');
    expect(detector.similarityBetween(a, b), greaterThan(0.9));
    expect(detector.findSimilar(a, <Question>[b]), hasLength(1));
  });

  test('does not flag unrelated questions', () {
    final a = q('a', 'MySQL 为什么用 B+ 树做索引？');
    final b = q(
      'b',
      'TCP 三次握手为什么需要第三次',
      topics: <String>['network'],
      keyPoints: <String>['确认序列号', '防止历史连接'],
    );
    expect(detector.similarityBetween(a, b), lessThan(0.5));
    expect(detector.findSimilar(a, <Question>[b]), isEmpty);
  });

  test('skips same id and respects threshold', () {
    final a = q('a', 'MySQL 索引结构');
    final sameId = q('a', 'MySQL 索引结构');
    expect(detector.findSimilar(a, <Question>[sameId]), isEmpty);
    const strict = SimilarQuestionDetector(threshold: 1.0);
    expect(
      strict.findSimilar(a, <Question>[
        q(
          'b',
          'MySQL 索引结构',
          topics: <String>['react'],
          keyPoints: <String>['x'],
        ),
      ]),
      isEmpty,
    );
  });

  test('normalizes punctuation and whitespace', () {
    final a = q('a', 'MySQL 为什么用 B+ 树？');
    final b = q('b', 'mysql 为什么用 b+ 树');
    expect(detector.similarityBetween(a, b), greaterThan(0.95));
  });
}
