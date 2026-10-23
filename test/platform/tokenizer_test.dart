import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/search/embedding/bert_tokenizer.dart';

String tokenizerJson() => jsonEncode(<String, Object?>{
  'model': <String, Object?>{
    'type': 'WordPiece',
    'vocab': <String, int>{
      '[PAD]': 0,
      '[UNK]': 1,
      '[CLS]': 2,
      '[SEP]': 3,
      'hello': 4,
      'world': 5,
      '##s': 6,
      '你': 7,
      '好': 8,
      '，': 9,
    },
  },
});

void main() {
  late BertWordPieceTokenizer tokenizer;
  setUp(
    () => tokenizer = BertWordPieceTokenizer.fromJsonString(tokenizerJson()),
  );

  test('lowercases, splits CJK and applies wordpiece', () {
    final ids = tokenizer.encodeUnpadded('Hello worlds 你好');
    // hello | world ##s | 你 | 好
    expect(ids, <int>[2, 4, 5, 6, 7, 8, 3]);
  });

  test('splits punctuation and handles unknown words', () {
    final ids = tokenizer.encodeUnpadded('你，好 unknown');
    expect(ids, <int>[2, 7, 9, 8, 1, 3]);
  });

  test('pads and truncates to requested length', () {
    final padded = tokenizer.encode('hello', maxLength: 8);
    expect(padded, hasLength(8));
    expect(padded.first, 2);
    expect(padded.last, 0);

    final long = tokenizer.encodeUnpadded(
      List<String>.filled(20, 'hello').join(' '),
      maxLength: 8,
    );
    expect(long, hasLength(8));
    expect(long.last, 3);
  });

  test('rejects malformed tokenizer json', () {
    expect(
      () => BertWordPieceTokenizer.fromJsonString('{}'),
      throwsFormatException,
    );
  });
}
