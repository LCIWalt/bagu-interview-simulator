# 八股文面试模拟助手（Bagu Interview Simulator）

三端（macOS / iOS / Android）本地优先的 AI 技术面试练习工具。产品规格以
`docs/PROJECT_GUIDE.md` 为唯一事实来源，任务队列见 `docs/TASKS.md`。

## 当前进度（2026-10-22）

- **M0 骨架完成**：三端工程、设计系统、冻结契约、SQLite/drift 基线、LLM 客户端、
  BYOK 设置与安全存储、日志/错误边界/i18n/路由、Prompt 装载。
- 验证：`flutter analyze` 零告警、48 个单测/widget 测试通过、macOS debug 与 Android debug APK
  构建通过；iOS 工程就绪，但本机 Xcode 未安装 iOS 平台组件，需安装后构建（见 `docs/ENVIRONMENT.md` §7.4）。
- **M1 进行中**：题库格式与校验器、FTS 检索、题库列表/搜索/筛选、题目详情
  （先自答再看答案、评分点、笔记、历史）、GitHub Release 更新管线（SHA-256 + Ed25519 +
  staging + 事务切换 + 保留 2 版本）、粘贴导入（跳过/覆盖/合并）已可用；内置 428 道种子题（Flutter 280 道 + Dart/Android 80 道 + 后端/前端/算法 68 道）。
- **M2 进行中**：练习模式闭环（题目 → 作答 → 提交 → 评分卡 → 下一题）、
  双模式会话状态机、评分点三态 + 证据校验 + 事实扣分 + JSON 重试/降级、申诉记录已可用。
- 出题策略（主题/薄弱点/难度/新鲜度加权、首题偏易、得分自适应）与成本控制
  （`llm_calls` token 统计、设置页本月用量；不设上限、不估算费用）已完成。
- **M3 进行中**：实战配置（岗位/级别/时长/难度/追问/风格/提示）、墙钟计时与阶段推进、
  题库驱动对话、全程静默异步评分、提前结束与基础报告已可用。
- AI 面试官流式对话（无 key 时回退本地题目）、结构化记忆（claims/项目/数字 + `memory.json`
  导出 + 下场摘要）已可用。
- 六段完整报告（结论/维度/逐题复盘/薄弱主题/7 天计划/面试官视角）+ Markdown 导出与删除、
  实战草稿恢复与 `turn_id` 幂等已可用。
- 双模式 E2E（20 题练习 + 12 轮实战、Fake LLM）已加入测试。
- **M4 进行中**：Tavily 搜索、单页抓取（内网/体积/类型防护、限速、缓存）、来源权威分级、
  断言抽取与风险分级、Ed25519 之外的联网核查（缓存 30 天、只降分、证据回链）已接入评分。
- 评分卡展示联网核查徽标（支持/矛盾/未知）与来源；`tool/eval.dart` 输出 MAE/偏差/长度相关性/
  证据率/JSON 合法率并支持长度扰动；申诉可导出为校准候选。
- 面经长文抽取题目草稿（证据校验 + 人工勾选）、批量导入（YAML/JSON/CSV/Markdown、逐行预览、
  冲突策略、事务回滚）、GitHub 远程导入（许可证白名单、
  限流/大小防护、来源追踪）、单题新建（表单校验、查重、
  `status:user`、即时可搜）、题库分类树（角色 → 主题）、
  标题/要点查重、`tool/build_bank_release.dart` 打包+Ed25519 签名，
  以及「App 拉取签名 release」集成测试已完成。
- 题库关系图（相似/追问/主题聚类 + 相关题）、RRF 混合检索与向量索引器（可注入
  `EmbeddingProvider`，无模型时退化 FTS）已完成。
- **M5 进行中**：OpenAI 兼容流式 TTS（`/audio/speech`）+ just_audio 播放，实战页半双工
  （播放中禁止提交、状态提示、切后台停止）；面试官头像状态机（idle/listening/thinking/speaking）
  已用 CustomPainter 临时实现（ADR-0004），Rive 资产待补。
- bge-small-zh INT8 模型 + BERT tokenizer + ONNX provider 已接入并随包分发；设置页可开启
  「语义检索（实验）」并重建向量索引，搜索走 RRF，模型失败自动回退 FTS。macOS/Android 构建通过；
  macOS 运行时已验证：512 维，相关 0.706 / 无关 0.492（设置页「模型自检」）；Android/iOS 运行时待验。
  40 条人工校准集、向量查重、Rive 形象尚未完成。
- macOS 自用构建无 App Sandbox（ADR-0006，ad-hoc 签名下 Keychain 所需），首次启动自动迁移旧容器数据。
- 发布：macOS release app（156MB）与 Android split-per-abi release APK（59–77MB）构建通过；
  `tool/package_macos.sh` 可产 ad-hoc DMG（沙箱内 hdiutil 被拒，需普通终端）；
  `docs/RELEASE.md` / `docs/PRIVACY.md` / `LICENSES.md` / `docs/qa/CHECKLIST.md` 已就绪。

## 快速开始

```bash
source tool/env.sh
flutter pub get
flutter analyze
flutter test
flutter run -d macos
```

代码生成（修改 drift schema / freezed 模型后）：

```bash
source tool/env.sh
HOME="$PWD/.toolchain/home" dart run build_runner build
```

三端构建：

```bash
flutter build macos --debug
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

本机环境、沙箱与已知坑见 `docs/ENVIRONMENT.md`。首次 iOS/macOS 构建前确认已关闭 SPM
（`flutter config --no-enable-swift-package-manager`，见 ADR-0001）。

## 目录

```
lib/app/            启动、路由、主题装配、Riverpod providers
lib/core/contracts/ 冻结接口与跨层模型（改动需 ADR + 批准）
lib/core/agent/     prompt 装载与运行时（不依赖 Flutter）
lib/core/llm/       OpenAI 兼容客户端（SSE / tools / 重试 / 取消）
lib/core/db/        drift schema、FTS5、迁移与快照
lib/core/design/    tokens、玻璃组件、设计演示页
lib/core/settings/  provider 配置、偏好、连通测试
lib/core/platform/  安全存储
lib/features/*      按功能分包
assets/prompts/     版本化 prompt（front-matter）
test/               单元 / widget / 契约测试
```

## 安全

- API Key 只存 Keychain / Keystore，不落数据库、不进日志（日志统一 `redact()`）。
- v1 不申请麦克风权限；语音输入使用系统输入法听写。
- 不做面试中实时提词/读屏答题。

## License

本项目采用 [Apache License 2.0](LICENSE)。

第三方依赖与题库内容许可见 [LICENSES.md](LICENSES.md)。
