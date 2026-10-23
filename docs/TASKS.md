# Bagu Interview Simulator 任务卡（TASKS）

> 由 `docs/PROJECT_GUIDE.md`（v0.4）派生。**每张卡可独立验收**，一卡一 PR。
> 状态：`[ ]` 待做 · `[~]` 进行中 · `[x]` 完成 · `[!]` 阻塞
> M0（T-001–T-008）本地交付（2026-10-22）：macOS/Android 构建通过；T-001 的 iOS 构建受本机 Xcode 缺少 iOS 平台组件阻塞，CI 未实际运行（仓库未初始化 git / 无远端）。PR 链接待补。
> M1 进展（2026-10-22）：T-010/T-013/T-014/T-015/T-016/T-017/T-018 完成；T-019 已完成打包/签名工具与 App 拉取测试，尚缺独立仓库 CI；T-011/T-012 已落地 728 道种子题（Flutter 480 道 + Dart 83 道 + Android 97 道；面经仍缺）；T-027 已有标题/要点查重，待接 T-025 余弦。
> M2 进展（2026-10-22）：T-030/T-031/T-033/T-034 完成（练习闭环、会话持久化、评分引擎、评分卡+申诉）；T-032 出题策略、T-035 成本控制已完成；T-036 E2E 待做。
> M3 进展（2026-10-23）：复盘 tab 已从占位替换为会话列表；练习也走六段式整场报告；新增最近 20 场分数趋势与主题掌握度统计。
> M3 进展（2026-10-22）：T-040/T-042/T-046 完成；T-041 已完成（AI 面试官流式 + 本地回退）；T-043 已完成（claims/项目/数字抽取、memory.json 导出、下场摘要）；T-044 已完成（六段结构 + Markdown 导出 + 删除）；T-045 已完成（草稿恢复 + turn_id 幂等）；T-036 已完成（20 题练习 + 12 轮实战 E2E）。

**领取规则**

1. 只领依赖已 `[x]` 的卡；一次一张。
2. 「允许目录」是硬边界，越界先停。
3. 完成即勾选 + 附 PR 链接。
4. 卡本身有误 → 停下改卡，不要绕过。

---

## M0 · 骨架（三端能跑、能连通模型）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-001 | [~] 三端脚手架 + CI | Flutter 工程、lint、Actions（macOS/iOS 模拟器 + Android + analyze + test） | 三端均能 `run`；CI 绿；`analyze` 零告警 | — | 全仓（init） | 1d |
| T-002 | [x] 冻结契约 + fake | `core/contracts/*` 7 接口（含 EmbeddingProvider）+ `test/fakes/*` | 编译通过；每接口有 fake；契约样例可跑 | T-001 | `lib/core/contracts/`, `test/fakes/` | 0.5d |
| T-003 | [x] 设计系统 | tokens + `GlassPanel/GlassButton/GlassSheet` + demo 页 | 三级降级可切；三端截图结构一致；对比度达标 | T-001 | `lib/core/design/`, `assets/fonts/` | 1.5d |
| T-004 | [x] 配置与密钥 | provider 配置（LLM/embedding/TTS）、secure storage、连通测试 | key 不明文落盘；区分 401/超时/模型不存在 | T-002,T-006 | `lib/core/settings/`, `lib/core/platform/secure_*`, `features/settings/` | 1d |
| T-005 | [x] LLM 客户端 | SSE 流式、tool calls、取消、重试、用量 | 单测覆盖分片 JSON/断流/429 退避 | T-002 | `lib/core/llm/`, `test/llm/` | 1.5d |
| T-006 | [x] 数据库基线 | drift schema（§6.1 全表）+ 迁移框架 | 建表/迁移可跑；FTS5 trigram 成功；schema 快照 | T-001 | `lib/core/db/`, `test/db/` | 1d |
| T-007 | [x] 基础设施 | 日志（脱敏/滚动）、错误边界、i18n、路由 | 崩溃有可读提示；日志可导出 | T-001 | `lib/core/util/`, `lib/app/`, `lib/l10n/` | 0.5d |
| T-008 | [x] Prompt 装载 | front-matter 解析、变量注入、版本记录 | 缺变量报错清晰；id 唯一性校验 | T-002 | `lib/core/agent/prompts/`, `assets/prompts/` | 0.5d |

---

## M1 · 题库基础（可浏览、可检索、可更新、可回滚）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-010 | [x] 题库格式 + 校验器 | `mockmate-bank` 结构、JSON Schema、`tool/validate_bank.dart` | 缺 id/重复 id/坏 rubric 全部报错并给路径行号 | T-002 | `tool/`, `docs/design/bank_schema.md` | 1d |
| T-011 | [~] 开源题库导入 | 从 MIT 许可仓库（如 `isboyjc/Interview`）抽取 → 转 YAML → 去重 → 许可登记 | ≥80 题、每条带 sourceUrl + license；生成 `LICENSES.md`；非许可仓库拒绝 | T-010 | `tool/import_oss.dart`, `assets/bank_seed/` | 1d |
| T-012 | [~] 种子题库（人工补） | 60 题（后端/前端/算法）+ 8 篇面经 | 全过校验器；每题有 keyPoints、来源、license | T-010,T-011 | `assets/bank_seed/` | 2d |
| T-013 | [x] 题库读取与检索 | `BankRepository`、FTS 查询、筛选、分页 | 200 题检索 p95 < 50ms；组合筛选正确 | T-006,T-012 | `lib/features/bank/data/`, `lib/core/db/` | 1.5d |
| T-014 | [x] 题库 UI | 分类树、列表、搜索、筛选器 | 滚动 60fps；300ms 防抖；状态可恢复 | T-003,T-013 | `lib/features/bank/presentation/` | 1.5d |
| T-015 | [x] 题目详情 | 题干、答案折叠、评分点、追问、来源、笔记、历史 | 笔记防抖保存；「先自答再看答案」可用 | T-014 | `lib/features/bank/presentation/` | 1d |
| T-016 | [x] 更新管线 | manifest、版本比较、下载、SHA-256、Ed25519、staging、原子切换、回滚 | 断网/校验失败/磁盘满 均不影响现有版本；回滚保留 2 版本 | T-006 | `lib/features/bank/data/update/`, `tool/` | 2d |
| T-017 | [x] 更新 UI | 检查更新、进度、失败原因、重试、镜像 | 失败文案可指导动作；可取消 | T-003,T-016 | `lib/features/bank/presentation/update/` | 1d |
| T-018 | [x] 离线导入 | 文件/粘贴导入、重复 ID 处理 | 不覆盖 `question_local`；可合并/跳过 | T-013 | `lib/features/bank/data/import/` | 1d |
| T-019 | [~] bank 仓库 CI | validate + 打包 + 签名 + release | 打 tag 产出 tar.zst + manifest + 签名；App 可拉 | T-010 | `mockmate-bank/.github/` | 1d |

---

## M1.5 · 新增题库与语义检索（题库要能长大、能互相关联）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-020 | [x] 单题新建 | 新建表单、必填校验、保存为 `status:user`、入库后可检索 | 评分点缺失阻止保存；保存后 1s 内可搜到 | T-013 | `lib/features/bank/presentation/edit/` | 1d |
| T-021 | [x] 批量导入 | YAML/JSON/CSV/Markdown：预览 → 字段映射 → 校验 → 冲突处理 | 100 条 <5s；错误逐行定位；失败整体回滚 | T-013,T-010 | `lib/features/bank/data/import_bulk/` | 1.5d |
| T-022 | [x] 面经抽题 | 粘贴正文 → LLM 拆多题草稿 → 勾选 → 补评分点 → 入库 | 5 篇样本拆出的题人工判定 ≥80% 可用；不编造 | T-023 | `lib/features/bank/data/import_exp/` | 2d |
| T-023 | [x] 远程源导入 | GitHub 仓库/单文件 URL → 读 LICENSE → 白名单校验 → 拉取解析 | 非 MIT/Apache/CC-BY 仓库被拒并说明；断网不污染本地 | T-010,T-018 | `lib/features/bank/data/remote/`, `tool/` | 1.5d |
| T-024a | [~] ONNX 三端 spike | macOS/iOS/Android 各跑通一次 bge-small 推理，记录包体/耗时/内存 | 三端均输出 512 维向量；单题 <30ms；失败可回退 FTS | T-001 | `spike/onnx/` | 1d |
| T-024 | [~] 本地 embedding 管线 | 模型内置、WordPiece 分词、批量推理、增量、模型版本、重建 | 2000 题全量 <3min；断网可用；换模型可重建 | T-024a,T-002,T-006 | `lib/core/embedding/`, `lib/features/bank/data/vector/` | 2d |
| T-025 | [~] 混合检索 | FTS + 向量 + RRF + 过滤；isolate 精确余弦 | 2000 题 p95 <100ms；召回率 ≥85%（对比纯 FTS） | T-024,T-013 | `lib/features/bank/data/search/` | 2d |
| T-026 | [~] 关系图 | similar/followup/cluster/prerequisite 建边与维护；相关题 UI | 孤立点/悬空边为 0；相关题抽检 80% 相关 | T-025 | `lib/features/bank/domain/graph/`, `tool/` | 2d |
| T-027 | [~] 去重拦截 | 入库前余弦检测 + 并排对比 + 合并选项 | 20 组重复样本召回 ≥90%、误杀 <10% | T-025,T-020 | `lib/features/bank/data/dedup/` | 1d |

---

## M2 · 练习模式（单题闭环）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-030 | [x] 练习入口与卡片 | 首页入口、题目卡、作答区、提交 | 一题一屏；听写/键盘切换自然；提交无抖动 | T-003,T-013 | `lib/features/interview/presentation/drill/` | 1.5d |
| T-031 | [x] 会话仓库 + 双模式状态机 | `SessionRepository`、drill/mock 状态机 | 单测覆盖非法转移、跳过、超时；mode 不可中途切换 | T-002,T-006 | `lib/features/interview/domain/` | 1.5d |
| T-032 | [x] 出题策略 | 过滤 + 打分 + 去重 + 难度自适应 + 关联题 | 单测断言：权重、避重、升降难度、similar 题不作为同场追问 | T-013,T-031,T-026 | `lib/features/interview/domain/selection/` | 1.5d |
| T-033 | [x] 评分引擎 | 评分点三态、覆盖率、事实错误、JSON 校验/重试/降级 | 无证据不给分；off-topic 不计命中；降级有测试 | T-005,T-013 | `lib/features/interview/domain/scoring/` | 2d |
| T-034 | [x] 评分卡片 | 三维分、要点命中、事实错误、原话证据、申诉入口 | 长文本不溢出；「这点我答了」可提交落库 | T-033,T-003 | `lib/features/interview/presentation/feedback/` | 1.5d |
| T-035 | [x] 用量展示 | 仅累计 `llm_calls` token；**不设上限、不做费用估算** | 设置页可看本月 tokens | T-005,T-006 | `lib/core/agent/`, `features/settings/` | 1d |
| T-036 | [x] 双模式 E2E | `FakeLlmClient` 场景脚本 + 集成测试 | CI 跑完 20 题练习 + 12 轮实战并出报告快照 | T-031,T-033 | `test/integration/`, `test/fakes/` | 1.5d |

---

## M3 · 实战模式（整场 + 报告 + 记忆）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-040 | [x] 面试配置页 | 岗位/级别/时长/难度滑杆/风格/追问层数/提示 | 校验完整；记住上次；可粘贴 JD | T-003,T-031 | `lib/features/interview/presentation/config/` | 1d |
| T-041 | [x] 实战对话 | 面试官 prompt、流式渲染、阶段推进 | 首 token <1.5s；中途不评分不点评；可中断 | T-005,T-008,T-031 | `lib/features/interview/presentation/live/` | 2d |
| T-042 | [x] 阶段与时间预算 | 5 阶段、软/硬上限、墙钟校正、closing | 切后台 5 分钟计时正确；到点自动收尾 | T-031 | `lib/features/interview/domain/timer/` | 1d |
| T-043 | [x] 结构化记忆 | claims/项目/数字抽取、`memory.json` 导出、下场复用 | schema 正确；下场可加载且不重复提问 | T-033,T-041 | `lib/features/interview/domain/memory/` | 2d |
| T-044 | [x] 汇总与报告 | 六段报告、Markdown 导出、可删除 | 空/单题不崩；生成 <8s；外部可打开 | T-033,T-043 | `lib/features/review/` | 2d |
| T-045 | [x] 会话恢复 | 杀进程/断网恢复同一轮；不重复计费 | 强杀重开轮次连续、无重复题 | T-031,T-041 | `lib/features/interview/data/` | 1d |
| T-046 | [x] 提前结束 | 「结束并出报告」+ 样本不足标注 | 报告标注题数与置信度 | T-044 | `lib/features/interview/presentation/live/` | 0.5d |

---

## M4 · 评分可信（联网核查 + 校准门禁）

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-050 | [x] 搜索 provider | Tavily 等实现 + 查询改写 + 结果归一化 | 429/超时/无 key 错误清晰；含 url/title/snippet/date | T-002 | `lib/core/search/` | 1d |
| T-051 | [x] 抓取 + 权威分级 | readability、`<untrusted>`、域名 A/B/C/D、限速、缓存 | 内网/超大/非 HTML 防护；D 级不采信 | T-050 | `lib/core/search/fetch/` | 1.5d |
| T-052 | [x] 断言抽取 + 风险分级 | 只抽可证伪断言；命中阈值才核查 | 20 条样本：该查的查、不该查的不查 | T-033 | `lib/features/interview/domain/factcheck/` | 1.5d |
| T-053 | [x] 核查判定与缓存 | verdict + 证据 + URL + 只降分规则 + `fact_checks` | 无 A 级源不判 contradicted；断网 unknown；可回链 | T-051,T-052 | `lib/features/interview/domain/factcheck/` | 2d |
| T-054 | [x] 核查展示 | 来源徽标、证据折叠、unknown 标识、一键打开 | 每条扣分可点开原文；unknown 不误导 | T-034,T-053 | `lib/features/interview/presentation/feedback/` | 1d |
| T-055 | [~] 校准集 | 40 条人工标注（含 5 条「长但空」、5 条「短但准」） | 双人一致性 ≥0.7；覆盖 3 难度 × 2 岗位 | T-033 | `test/eval/`, `tool/eval.dart` | 2d |
| T-056 | [x] 评测 + 长度扰动 | MAE、宽松偏差、长度相关性、证据率、JSON 合法率；扰动测试 | 一条命令出报告；扩写到 3000 字分数变化 <0.3 | T-055 | `tool/`, `.github/workflows/` | 1d |
| T-057 | [x] 申诉闭环 | 用户申诉 → 记录 → 进校准候选 | 数据可导出；不自动改分 | T-034 | `lib/features/interview/`, `test/eval/` | 1d |

---

## M5 · 语音与形象

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-060 | [ ] 听写作答体验 | 作答计时（t0/t1）、听写提示、粘贴入口、术语纠错（可撤销） | 三端可用；纠错可见可撤销；时长标「估算」 | T-030 | `lib/features/interview/presentation/`, `assets/hotwords.txt` | 1.5d |
| T-061 | [x] TTS provider | 流式合成、音色、语速、失败降级系统 TTS | 首包 <2.5s；失败不阻塞 | T-002 | `lib/core/platform/tts/` | 1.5d |
| T-062 | [~] 半双工控制 | 播放中禁止提交、状态提示、音频焦点、蓝牙切换 | 播放与提交不重叠；来电暂停后恢复 | T-061,T-041 | `lib/features/interview/presentation/live/` | 1d |
| T-063 | [~] 形象资源 | Rive「小深」+ idle/listening/thinking/speaking + 授权说明 | 单文件 ≤3MB；切态无跳帧；含源文件 | T-003 | `assets/rive/`, `docs/design/` | 2d |
| T-064 | [x] 形象集成 | 事件驱动切态、可选口型、可完全关闭 | 关闭后流程无损；CPU <5% | T-063,T-061 | `lib/features/avatar/` | 1.5d |
| T-065 | [ ] 三端性能 | 玻璃降级、模糊层数、列虚拟化、帧率监测 | 低端 Android 不卡；内存 <400MB | T-003 | `lib/core/design/`, `lib/core/platform/` | 1d |

---

## M6 · 面经与发布

| ID | 任务 | 交付物 | 验收标准 | 依赖 | 允许目录 | 估时 |
|---|---|---|---|---|---|---|
| T-070 | [ ] 单页抓取（用户触发） | 粘贴链接 → 抓单页正文 → 抽取成题 | 只抓单页、限速、标来源；失败可手动粘贴正文 | T-051,T-022 | `lib/core/search/single_page/` | 1d |
| T-071 | [ ] 无障碍 | 语义标签、字体缩放、对比度、读屏走查 | 5 条核心路径可纯读屏完成 | T-014,T-030 | `lib/` | 1d |
| T-072 | [~] macOS 打包 | 本机 release 构建、ad-hoc DMG、首次打开说明 | 另一台 Mac 右键可打开；无公证依赖 | T-001 | `.github/workflows/`, `macos/`, `docs/` | 1d |
| T-073 | [~] iOS 打包 | 模拟器构建、免费签名真机安装、7 天重签文档 | 真机可启动；文档步骤可复现 | T-001 | `ios/`, `docs/` | 1d |
| T-074 | [~] Android 打包 | 签名、APK/AAB、权限清单 | 真机可启动；包 <80MB | T-001 | `android/`, `.github/workflows/` | 1d |
| T-075 | [x] 文档与合规 | README、隐私说明、权限说明、`LICENSES.md` | 覆盖数据去向；无 GPL；第三方题库许可正确 | 全部 | `README.md`, `docs/` | 0.5d |
| T-076 | [~] 发布前 QA | 三端真机矩阵、弱网、耳机、锁屏、45min 长会话 | 清单全绿；已知问题进 release notes | 全部 | `docs/qa/` | 2d |

---

## 关键路径

```
T-001 → T-002 → T-006 → T-013 → T-032 → T-033 → T-034
                     ↑                    ↓
        T-010 → T-011 → T-012        T-055 → T-056
                     ↓
        T-020 → T-027（新增/去重）
        T-024a → T-024 → T-025 → T-026（本地向量/关系）
T-031 → T-041 → T-043 → T-044
T-050 → T-051 → T-053 → T-054
T-061 → T-062
```

**并行分工**（先完成 T-002 / T-006 冻契约）

| 工作流 | 任务 |
|---|---|
| A 核心/Agent/评分 | T-005, T-008, T-031, T-032, T-033, T-035, T-043, T-052–T-057 |
| B 题库/数据 | T-010–T-019, T-011, T-022, T-023, T-070 |
| C 语义/关系 | T-024, T-025, T-026, T-027 |
| D UI/设计 | T-003, T-014, T-015, T-020, T-021, T-030, T-034, T-040, T-071 |
| E 搜索/核查 | T-050, T-051, T-053, T-054 |
| F 语音/形象 | T-060–T-065 |
| G 发布 | T-072–T-076 |
