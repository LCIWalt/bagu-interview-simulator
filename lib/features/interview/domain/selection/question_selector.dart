import 'dart:math';

import '../../../../core/contracts/contracts.dart';

class QuestionSelectionContext {
  const QuestionSelectionContext({
    required this.config,
    this.askedIds = const <String>{},
    this.recentIds = const <String>{},
    this.weakTopics = const <String, double>{},
    this.lastScore,
    this.questionIndex = 0,
  });

  final SessionConfig config;

  /// 同场已问过，直接排除。
  final Set<String> askedIds;

  /// 最近跨场练过，仅降权（新鲜度）。
  final Set<String> recentIds;

  /// 主题 → 0..1 薄弱度。
  final Map<String, double> weakTopics;

  /// 上一题得分，用于难度自适应。
  final double? lastScore;
  final int questionIndex;
}

class QuestionSelection {
  const QuestionSelection({
    required this.question,
    required this.followupDepth,
    required this.allowHint,
    required this.score,
  });

  final Question question;
  final int followupDepth;
  final bool allowHint;
  final double score;
}

/// 出题策略（T-032）：0.40 主题 + 0.25 薄弱点 + 0.20 难度 + 0.10 新鲜度 + 0.05 随机。
class QuestionSelector {
  QuestionSelector({Random? random}) : _random = random ?? Random();

  final Random _random;

  QuestionSelection? select(
    List<Question> candidates,
    QuestionSelectionContext context,
  ) {
    Question? best;
    var bestScore = double.negativeInfinity;
    for (final question in candidates) {
      if (context.askedIds.contains(question.id)) continue;
      final score = _score(question, context);
      if (score > bestScore) {
        bestScore = score;
        best = question;
      }
    }
    if (best == null) return null;
    final followupDepth = _followupDepth(context);
    return QuestionSelection(
      question: best,
      followupDepth: followupDepth,
      allowHint:
          context.config.allowHints &&
          (context.lastScore == null || context.lastScore! <= 2),
      score: bestScore,
    );
  }

  double _score(Question question, QuestionSelectionContext context) {
    final topicMatch = _topicMatch(question, context.config);
    final weakness = _weakness(question, context.weakTopics);
    final difficulty = _difficultyFit(question, context);
    final freshness = context.recentIds.contains(question.id) ? 0.0 : 1.0;
    final random = _random.nextDouble();
    return 0.40 * topicMatch +
        0.25 * weakness +
        0.20 * difficulty +
        0.10 * freshness +
        0.05 * random;
  }

  double _topicMatch(Question question, SessionConfig config) {
    if (config.topics.isEmpty) return 0.5;
    final overlap = question.topics.toSet().intersection(config.topics.toSet());
    return overlap.isEmpty ? 0.0 : overlap.length / config.topics.length;
  }

  double _weakness(Question question, Map<String, double> weakTopics) {
    if (weakTopics.isEmpty) return 0.5;
    var max = 0.0;
    for (final topic in question.topics) {
      final value = weakTopics[topic];
      if (value != null && value > max) max = value;
    }
    return max.clamp(0, 1);
  }

  double _difficultyFit(Question question, QuestionSelectionContext context) {
    final target = _targetDifficulty(context);
    final distance = (question.difficulty - target).abs();
    return (1 - distance / 4).clamp(0, 1);
  }

  int _targetDifficulty(QuestionSelectionContext context) {
    var target = context.config.difficulty;
    if (context.questionIndex == 0) {
      target -= 1; // 首题偏易
    } else if (context.lastScore != null) {
      if (context.lastScore! >= 4) target += 1;
      if (context.lastScore! <= 2) target -= 1;
    }
    return target.clamp(1, 5);
  }

  int _followupDepth(QuestionSelectionContext context) {
    var depth = context.config.followupDepth;
    if (context.lastScore != null) {
      if (context.lastScore! >= 4 && depth < 3) depth += 1;
      if (context.lastScore! <= 2 && depth > 0) depth -= 1;
    }
    return depth.clamp(0, 3);
  }
}
