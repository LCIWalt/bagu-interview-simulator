# ADR-0002 · M0 契约模型与 schema 实现细节

- 状态：已接受
- 日期：2026-10-22
- 关联：T-002、T-006，`docs/PROJECT_GUIDE.md` §5.6 / §6.1

## 决策 1：契约与跨层模型手写不可变类

`lib/core/contracts/` 的 7 个接口与其数据类型（`Question`、`Session`、`ChatRequest`、`LlmDelta` 等）使用手写不可变类与 sealed 分支，不使用 `freezed` 生成代码。

理由：

1. 冻结接口不应随 codegen 版本升级产生 diff；
2. `core/agent`、`core/llm` 的测试可在纯 Dart VM 下运行，不依赖生成步骤；
3. 避免 freezed/json_serializable 与 drift_dev 的 analyzer 版本互相牵制。

代价：`copyWith`/相等性需手写；领域层若需要大量 JSON 序列化，后续可在 feature 层引入 freezed，不改变契约。

## 决策 2：只加列

在 §6.1 冻结核心列基础上追加：

- `questions.answer_json`：参考答案 summary / keyPoints / pitfalls；
- `questions.followups_json`：追问列表；
- `question_local.origin`：`bank` | `user`（§7.1.1 用户自建题）。

理由：评分官必须读取结构化评分点；用户题必须与上游题库区分且不被更新覆盖。均为新增列，不删除/重命名既有列。

## 决策 3：FTS5 实现方式

`fts_questions` 为普通 FTS5 表（`tokenize='trigram'`），用 `questions` 上的 INSERT/UPDATE/DELETE 触发器同步；不使用 external content，避免 `rebuild` 命令与空内容表的兼容问题。`AppDatabase.rebuildFts()` 通过全量重灌实现重建。

## 验证

`test/db/app_database_test.dart`（建表、中文 trigram、增删改同步、级联删除）与 `test/db/schema_snapshot_test.dart`（schema 快照）。
