import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockmate/core/search/embedding/onnx_bge_embedding.dart';

double cosine(List<double> a, List<double> b) {
  var dot = 0.0;
  var na = 0.0;
  var nb = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  return dot / (sqrt(na) * sqrt(nb));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads bge int8 and separates related topics', (
    WidgetTester tester,
  ) async {
    final provider = await OnnxBgeEmbeddingProvider.create();
    expect(
      provider,
      isNotNull,
      reason: 'ONNX session/tokenizer failed to load',
    );
    final go = await provider!.embed('Go 的 GMP 调度模型，P 提供执行上下文');
    final goroutine = await provider.embed('goroutine 如何被 M 调度执行');
    final mysql = await provider.embed('MySQL 的 B+ 树索引结构');
    expect(go, hasLength(512));
    expect(cosine(go, goroutine), greaterThan(cosine(go, mysql)));
    await provider.dispose();
  });
}
