# ADR-0005：bge-small-zh INT8 ONNX 三端 spike

- 状态：进行中（T-024a）
- 日期：2026-10-22

## 决策

- 引入 `flutter_onnxruntime 1.9.0`，模型 `Xenova/bge-small-zh-v1.5` 的
  `onnx/model_quantized.onnx`（23MB）+ `tokenizer.json`（429KB），随 App 打包。
- 实现纯 Dart BERT WordPiece tokenizer 与 `OnnxBgeEmbeddingProvider`（CLS pooling + L2 归一化）。
- macOS/iOS Podfile 改为 `use_frameworks! :linkage => :static`；iOS 最低 16.0。
- Android 增加 `proguard-rules.pro` 保留 `ai.onnxruntime.**`。

## 验证

- macOS debug 构建：✅（CocoaPods 下载 onnxruntime 1.28.0，静态链接）
- Android debug 构建：✅
- 运行时推理：✅ 2026-10-22 18:39 在工位通过 App 内「模型自检」验证：
  - 512 维
  - “Go GMP” vs “goroutine 调度” 余弦 **0.706**
  - “Go GMP” vs “MySQL B+ 树” 余弦 **0.492**
  - 设置页会显示 3 次嵌入耗时，用于评估单题 ≤80ms。
- `integration_test` 仍受本机 `open returned 1` 影响，改以 App 内自检为准。
- iOS 构建：未验证（本机缺 iOS 平台组件）。

## 应用接线

- 设置页新增「语义检索（实验）」开关（`AppPreferences.semanticSearch`，默认关）与「重建向量索引」。
- 开关开启且输入非空时，题库搜索走 `HybridSearchEngine`（RRF）；模型加载失败/无向量时回退 FTS。
- 首次搜索可能触发模型加载（数秒），设置页重建索引可观察进度。

## 待办

1. 在普通终端运行：
   `flutter test integration_test/onnx_embedding_test.dart -d macos`
   确认 512 维、Go 相关相似度 > MySQL 无关相似度。
2. Android/iOS 真机跑同一集成测试。
3. 通过后把 `OnnxBgeEmbeddingProvider` 注入 `HybridSearchEngine`，再跑 T-025 召回/性能校准。
4. 若推理失败，按错误调整输入 dtype/shape/输出名，不更换模型。
