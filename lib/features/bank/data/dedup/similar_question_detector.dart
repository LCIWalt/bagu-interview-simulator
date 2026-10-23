import 'package:mockmate/core/contracts/contracts.dart';

class SimilarMatch {
  const SimilarMatch({required this.question, required this.similarity});

  final Question question;
  final double similarity;
}

/// 入库查重（T-027）：标题字符 bigram + simhash，叠加主题与评分点。
/// 不引入原生依赖；阈值默认 0.90（bge 向量阈值另由 T-025 校准）。
class SimilarQuestionDetector {
  const SimilarQuestionDetector({this.threshold = 0.9});

  final double threshold;

  List<SimilarMatch> findSimilar(
    Question candidate,
    Iterable<Question> existing, {
    int limit = 5,
  }) {
    final matches = <SimilarMatch>[];
    for (final question in existing) {
      if (question.id == candidate.id) continue;
      final similarity = similarityBetween(candidate, question);
      if (similarity >= threshold) {
        matches.add(SimilarMatch(question: question, similarity: similarity));
      }
    }
    matches.sort(
      (SimilarMatch a, SimilarMatch b) => b.similarity.compareTo(a.similarity),
    );
    return matches.take(limit).toList(growable: false);
  }

  double similarityBetween(Question a, Question b) {
    final title = _titleSimilarity(a.title, b.title);
    final topics = _jaccard(a.topics.toSet(), b.topics.toSet());
    final points = _jaccard(
      a.answer.keyPoints.toSet(),
      b.answer.keyPoints.toSet(),
    );
    return 0.6 * title + 0.15 * topics + 0.25 * points;
  }

  double _titleSimilarity(String a, String b) {
    final left = _normalize(a);
    final right = _normalize(b);
    if (left.isEmpty || right.isEmpty) return 0;
    if (left == right) return 1;
    final jaccard = _jaccard(_bigrams(left), _bigrams(right));
    final simhash = _simhashSimilarity(left, right);
    return jaccard > simhash ? jaccard : simhash;
  }

  Set<String> _bigrams(String value) {
    if (value.length < 2) return <String>{value};
    return <String>{
      for (var i = 0; i < value.length - 1; i++) value.substring(i, i + 2),
    };
  }

  double _simhashSimilarity(String a, String b) {
    final ha = _simhash(a);
    final hb = _simhash(b);
    final distance = _hamming(ha, hb);
    return 1 - distance / 64;
  }

  int _simhash(String value) {
    final votes = List<int>.filled(64, 0);
    for (final gram in _bigrams(value)) {
      final hash = _fnv1a64(gram);
      for (var bit = 0; bit < 64; bit++) {
        votes[bit] += ((hash >> bit) & 1) == 1 ? 1 : -1;
      }
    }
    var result = 0;
    for (var bit = 0; bit < 64; bit++) {
      if (votes[bit] > 0) result |= 1 << bit;
    }
    return result;
  }

  int _fnv1a64(String value) {
    var hash = 0xcbf29ce484222325;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash;
  }

  int _hamming(int a, int b) {
    var value = a ^ b;
    var count = 0;
    while (value != 0) {
      count += value & 1;
      value >>= 1;
    }
    return count;
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0;
    if (a.isEmpty || b.isEmpty) return 0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0 : intersection / union;
  }

  String _normalize(String value) {
    var text = value.toLowerCase();
    text = text.replaceAll(
      RegExp(r'''[\s，。！？、；：,.!?;:"'()（）\[\]【】<>《》/\\_-]+'''),
      '',
    );
    return text;
  }
}
