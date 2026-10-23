/// 本地向量嵌入契约（D21：bge-small-zh-v1.5 int8，512 维）。
///
/// 实现必须离线可用；模型缺失/加载失败时 [isAvailable] 为 false，
/// 上层退化到纯 FTS，而不是抛错。
abstract interface class EmbeddingProvider {
  String get id;

  /// 模型标识（含量化版本），变更时触发全量重建。
  String get model;

  int get dimensions;

  bool get isAvailable;

  Future<List<double>> embed(String text);

  Future<List<List<double>>> embedBatch(List<String> texts);
}
