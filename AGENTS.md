# AGENTS.md — MockMate 实现守则

你是本仓库的实现 Agent。本文件是**行为合同**，与 `docs/PROJECT_GUIDE.md`（事实来源）、`docs/TASKS.md`（工作队列）配合使用。

## 1. 开场必做

1. 读 `docs/PROJECT_GUIDE.md` 全文（至少 §0/§3/§4/§5/§6/§7/§10）。
2. 读 `docs/TASKS.md`，选一张依赖已完成的卡，确认「允许目录」。
3. 在 PR 描述里写明任务 ID 与验收标准。
4. 不确定的产品决策 → 停下来问，**不要自行发明**。

## 2. 仓库地图

| 路径 | 职责 | 谁能改 |
|---|---|---|
| `lib/core/contracts/` | 冻结接口 | 仅 ADR + 人类批准 |
| `lib/core/agent/` | 运行时、工具注册、prompt 装配 | A 工作流 |
| `lib/core/llm/` | 模型客户端 | A |
| `lib/core/db/` | schema + 迁移 | B（改 schema 需批准） |
| `lib/core/design/` | tokens、玻璃组件 | C |
| `lib/features/*` | 按功能分包 | 对应工作流 |
| `assets/prompts/` | 版本化 prompt | A |
| `assets/bank_seed/` | 内置题库 | B |
| `tool/` | 脚本（校验/导入/评测） | 任何人，需带测试 |
| `docs/` | 文档与 ADR | 任何人 |

## 3. 常用命令

```bash
source tool/env.sh               # 必须先执行：Flutter/JDK/Android/Xcode 变量
flutter pub get
flutter analyze                 # 必须零告警
dart format --set-exit-if-changed lib test tool
flutter test                    # 单元 + widget
flutter test integration_test   # 需设备/模拟器
flutter run -d macos
flutter run -d <ios-device>
flutter run -d <android-device>
dart run tool/validate_bank.dart assets/bank_seed
dart run tool/eval.dart         # LLM 校准集（需配置 key，CI 跳过）
```

## 4. 硬约束

**MUST**

- 依赖方向：`features → domain → contracts`；禁止 feature 直接 import `dio`/`drift`/具体 provider。
- `core/agent` 不得 import Flutter（保持可纯 Dart 单测）。
- 所有外部 API 调用必须经 `core/llm` 或 `core/search` 的 provider 抽象，禁止散落 `http.get`。
- 密钥只经 `SecureStore`；日志必须过 `redact()`。
- 新增/修改行为 → 同步更新 `docs/PROJECT_GUIDE.md` 对应章节。
- 数据库变更 → 迁移 + 迁移测试 + schema 快照；**只加列不删列**。
- Prompt 变更 → 跑评测集并在 PR 贴前后对比。
- 抓取内容一律按不可信输入处理（`<untrusted>` 包裹、参数白名单）。
- 测试不得依赖真实网络/真实 key；用 `test/fakes/`。
- **三端（macOS / iOS / Android）都要能构建**；只在一个平台验过的 UI 改动不算完成。
- v1 **不申请麦克风权限**（语音输入走系统输入法听写，见指南 §7.4）；引入录音能力需 ADR。

**MUST NOT**

- 提交任何密钥、token、`.env`、签名证书。
- 引入 GPL/AGPL 依赖；引入新运行时依赖需说明理由。
- 在未获批准时修改 `core/contracts/`、DB schema、工具名、prompt 变量名。
- 顺手重构无关文件、改格式、升级无关依赖（PR 必须可聚焦审阅）。
- 用 `// ignore:` 压制 analyzer 除非有注释说明原因。
- 实现"面试中实时辅助/提词"类功能（伦理红线，见指南 §9.4）。

## 5. Definition of Done

一个任务只有全部满足才算完成：

- [ ] 功能符合任务卡验收标准，手工验证过（贴命令/截图说明）
- [ ] 涉及 UI 的改动在 **macOS / iOS / Android 三端**都跑过一遍（模拟器可接受）
- [ ] `flutter analyze` 零告警，`dart format` 无 diff
- [ ] 新增逻辑有单测；覆盖率不下降（`core/*` ≥ 70%）
- [ ] 错误路径有处理：超时、断网、空数据、权限拒绝、取消
- [ ] 无硬编码文案（走 i18n）、无硬编码模型名（走配置）
- [ ] 日志无敏感信息
- [ ] 文档已同步；必要时新增 ADR
- [ ] `docs/TASKS.md` 勾选并附 PR 链接
- [ ] PR 描述含：改了什么 / 为什么 / 怎么验证 / 已知限制

## 6. 代码风格

- 文件 ≤ 400 行；函数 ≤ 60 行；参数 > 4 个用配置对象。
- 领域模型用 `freezed`；跨层数据不用 `Map<String, dynamic>`。
- 错误用 `sealed class Failure`（`NetworkFailure` / `AuthFailure` / `ParseFailure` / `Cancelled`），UI 只按 Failure 分支。
- 异步一律可取消（`CancelToken`），禁止裸 `Future` 挂 UI。
- 命名：领域用业务词（`Session`, `Turn`, `Rubric`），不用 `Data/Info/Manager/Helper`。

## 7. 提交与 PR

```
feat(bank): 实现 manifest 校验与原子切换 (T-016)

- 新增 BankUpdater，支持 staging/回滚
- 失败路径：网络/校验/磁盘满
验证：flutter test test/bank/update_test.dart
```

分支：`feat/T-016-bank-update`。一卡一 PR，≤ 600 行 diff（生成代码除外）。

## 8. 卡住了怎么办

| 情况 | 动作 |
|---|---|
| 任务卡描述矛盾/缺失 | 停下，指出具体矛盾，提出 2 个方案 + 推荐 |
| 需要越界改文件 | 停下，说明为什么必须越界 |
| 依赖库不满足（平台限制） | 记录到 `docs/decisions/` 提案，不要偷偷换方案 |
| 真实 API 行为与文档不符 | 记录请求/响应（脱敏），更新文档 |
| 预计超时 2 倍 | 拆卡，先交付可用子集 |

## 9. 汇报格式（每次交付）

```markdown
## 结果
一句话：完成了什么 / 没完成什么

## 改动
- 文件列表（分组）

## 验证
- 命令 + 结果（贴关键输出）

## 决策与偏离
- 与文档不一致处及原因

## 遗留 / 下一步
- 明确列 TODO 或建议的下一张卡
```
