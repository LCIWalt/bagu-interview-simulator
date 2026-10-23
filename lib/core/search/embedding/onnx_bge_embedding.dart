import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:mockmate/core/contracts/contracts.dart';

import 'bert_tokenizer.dart';

/// bge-small-zh-v1.5（INT8）本地 embedding（T-024）。
///
/// 模型/分词器缺失、原生 ORT 初始化失败时 `create` 返回 null，调用方回退 FTS。
class OnnxBgeEmbeddingProvider implements EmbeddingProvider {
  OnnxBgeEmbeddingProvider._(this._session, this._tokenizer);

  static const String modelAsset =
      'assets/models/bge-small-zh-v1.5-quantized.onnx';
  static const String tokenizerAsset = 'assets/models/bge-tokenizer.json';

  final OrtSession _session;
  final BertWordPieceTokenizer _tokenizer;
  bool _closed = false;

  static Future<OnnxBgeEmbeddingProvider?> create({
    String modelPath = modelAsset,
    String tokenizerPath = tokenizerAsset,
    AssetBundle? bundle,
  }) async {
    try {
      final json = await (bundle ?? rootBundle).loadString(tokenizerPath);
      final tokenizer = BertWordPieceTokenizer.fromJsonString(json);
      final runtime = OnnxRuntime();
      final session = await runtime.createSessionFromAsset(modelPath);
      return OnnxBgeEmbeddingProvider._(session, tokenizer);
    } on Object {
      return null;
    }
  }

  @override
  String get id => 'bge-small-zh';

  @override
  String get model => 'bge-small-zh-v1.5-int8';

  @override
  int get dimensions => 512;

  @override
  bool get isAvailable => !_closed;

  @override
  Future<List<double>> embed(String text) async {
    final batch = await embedBatch(<String>[text]);
    return batch.first;
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    if (texts.isEmpty) return const <List<double>>[];
    final encoded = texts
        .map((String text) => _tokenizer.encodeUnpadded(text, maxLength: 512))
        .toList(growable: false);
    final length = encoded
        .map((List<int> ids) => ids.length)
        .reduce((int a, int b) => a > b ? a : b);
    final count = texts.length;
    final ids = Int64List(count * length);
    final mask = Int64List(count * length);
    final types = Int64List(count * length);
    for (var row = 0; row < count; row++) {
      final tokens = encoded[row];
      for (var col = 0; col < length; col++) {
        final index = row * length + col;
        if (col < tokens.length) {
          ids[index] = tokens[col];
          mask[index] = 1;
        } else {
          ids[index] = _tokenizer.padId;
        }
      }
    }
    final outputs = await _session.run(<String, OrtValue>{
      'input_ids': await OrtValue.fromList(ids, <int>[count, length]),
      'attention_mask': await OrtValue.fromList(mask, <int>[count, length]),
      'token_type_ids': await OrtValue.fromList(types, <int>[count, length]),
    });
    final hidden = outputs['last_hidden_state'];
    if (hidden == null) throw const ParseFailure('bge 缺少 last_hidden_state');
    final data = await hidden.asList();
    final vectors = <List<double>>[];
    for (var row = 0; row < count; row++) {
      // BGE 使用 CLS pooling，再做 L2 归一化。
      final tokenRows = data[row];
      final cls =
          (tokenRows is List ? tokenRows.first : tokenRows) as List<dynamic>;
      final vector = cls
          .map((dynamic value) => (value as num).toDouble())
          .toList(growable: false);
      vectors.add(_normalize(vector));
    }
    return vectors;
  }

  List<double> _normalize(List<double> vector) {
    var norm = 0.0;
    for (final value in vector) {
      norm += value * value;
    }
    if (norm == 0) return vector;
    final scale = 1 / (norm == 1 ? 1 : _sqrt(norm));
    return vector.map((double value) => value * scale).toList(growable: false);
  }

  double _sqrt(double value) {
    var guess = value;
    for (var i = 0; i < 20; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }

  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    await _session.close();
  }
}
