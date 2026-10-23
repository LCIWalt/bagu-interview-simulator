import 'dart:convert';

/// 轻量 BERT WordPiece tokenizer（T-024a）。
///
/// 只覆盖 BGE 中文模型所需：clean/lowercase、CJK 逐字切分、WordPiece 贪心。
class BertWordPieceTokenizer {
  BertWordPieceTokenizer({
    required this.vocab,
    required this.clsId,
    required this.sepId,
    required this.padId,
    required this.unkId,
    this.maxLength = 512,
  });

  factory BertWordPieceTokenizer.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('tokenizer.json 不是对象');
    }
    final model = decoded['model'];
    if (model is! Map<String, dynamic>) throw const FormatException('缺少 model');
    final rawVocab = model['vocab'];
    if (rawVocab is! Map<String, dynamic>) {
      throw const FormatException('缺少 vocab');
    }
    final vocab = <String, int>{
      for (final entry in rawVocab.entries)
        if (entry.value is num) entry.key: (entry.value as num).toInt(),
    };
    int idOf(String token, int fallback) => vocab[token] ?? fallback;
    return BertWordPieceTokenizer(
      vocab: vocab,
      clsId: idOf('[CLS]', 101),
      sepId: idOf('[SEP]', 102),
      padId: idOf('[PAD]', 0),
      unkId: idOf('[UNK]', 100),
    );
  }

  final Map<String, int> vocab;
  final int clsId;
  final int sepId;
  final int padId;
  final int unkId;
  final int maxLength;

  List<int> encode(String text, {int? maxLength}) {
    final limit = (maxLength ?? this.maxLength).clamp(8, this.maxLength);
    final ids = <int>[clsId];
    for (final word in _words(text)) {
      if (ids.length >= limit - 1) break;
      final pieces = _wordPieces(word);
      for (final piece in pieces) {
        if (ids.length >= limit - 1) break;
        ids.add(vocab[piece] ?? unkId);
      }
    }
    ids.add(sepId);
    while (ids.length < limit) {
      ids.add(padId);
    }
    return ids;
  }

  List<int> encodeUnpadded(String text, {int? maxLength}) {
    final limit = (maxLength ?? this.maxLength).clamp(8, this.maxLength);
    final ids = <int>[clsId];
    for (final word in _words(text)) {
      if (ids.length >= limit - 1) break;
      for (final piece in _wordPieces(word)) {
        if (ids.length >= limit - 1) break;
        ids.add(vocab[piece] ?? unkId);
      }
    }
    ids.add(sepId);
    return ids;
  }

  List<String> _words(String text) {
    var value = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0000-\u001f\u007f\ufffd]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // CJK 与全角标点逐字拆开，匹配 BERT basic tokenizer。
    value = value.replaceAllMapped(
      RegExp(r'([\u3400-\u4dbf\u4e00-\u9fff\u3040-\u30ff])'),
      (Match match) => ' ${match.group(1)} ',
    );
    value = value.replaceAllMapped(
      RegExp(r'([!-/:-@\[-`{-~\u3000-\u303f\uff00-\uffef])'),
      (Match match) => ' ${match.group(1)} ',
    );
    return value
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _wordPieces(String word) {
    if (word.length > 100) return const <String>['[UNK]'];
    if (vocab.containsKey(word)) return <String>[word];
    final pieces = <String>[];
    var start = 0;
    while (start < word.length) {
      var end = word.length;
      String? current;
      while (start < end) {
        var piece = word.substring(start, end);
        if (start > 0) piece = '##$piece';
        if (vocab.containsKey(piece)) {
          current = piece;
          break;
        }
        end--;
      }
      if (current == null) return const <String>['[UNK]'];
      pieces.add(current);
      start = end;
    }
    return pieces;
  }
}
