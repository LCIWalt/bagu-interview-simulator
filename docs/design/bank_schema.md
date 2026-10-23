# 题库格式与校验（`mockmate-bank`）

> 关联：T-010、`docs/PROJECT_GUIDE.md` §6.2/§7.1。本文件是题库生产侧的契约；
> App 只消费，不在 App 内做内容运营。

## 1. 目录结构

```text
mockmate-bank/
├─ manifest.json
├─ taxonomy.yaml
├─ questions/<topic>/<id>.yaml
├─ experiences/<yyyy-mm>-<company>-<role>.md
└─ LICENSE / CONTRIBUTING.md / .github/workflows/validate.yml
```

- `<id>` 必须与 `questions/` 下的文件名一致（`be-go-001.yaml` → `id: be-go-001`）。
- 只允许小写字母、数字与连字符，长度 3–64。
- 内置种子题库位于 `assets/bank_seed/`，结构相同，可离线使用。

## 2. 题目 YAML

```yaml
id: be-go-001
title: Go 的 GMP 模型里，为什么需要 P？
body: 可选；缺省用 title 作为题干
topics: [go, runtime, concurrency]       # 必填，非空、无重复
role: backend                             # backend / frontend / algorithm / mobile…
level: mid                                # junior|mid|senior|staff，或 1–5
difficulty: 3                             # 1–5
type: knowledge                           # knowledge|behavioral|system-design|coding|project
answer:
  summary: 3–5 句标准答法
  keyPoints:                              # 必填，≥1，无重复；评分官只按这些判定
    - M 与 P 解耦的原因
    - 本地运行队列与 work stealing
    - syscall 阻塞时 P 的移交
  pitfalls: [只背结论, 混淆 G 与 M 的数量关系]
followups:
  - GOMAXPROCS 设得比核数大很多会怎样？
source:                                   # 必填
  url: https://go.dev/doc/…
  title: Go 官方文档
  license: BSD-3-Clause                   # 必须显式登记
  retrievedAt: 2026-10-01
status: verified                          # verified|community|ai-draft|user|orphaned
updatedAt: 2026-10-01                     # 必填，ISO 日期
```

### 字段规则

| 字段 | 规则 |
|---|---|
| `id` | 唯一、与文件名一致、`^[a-z0-9][a-z0-9-]{2,63}$` |
| `title` | 非空 |
| `topics` | 非空字符串数组，无重复 |
| `role` | 非空（岗位词表见 `taxonomy.yaml`） |
| `level` | `junior/mid/senior/staff` 或 1–5 |
| `difficulty` | 1–5 |
| `type` | 五个枚举之一 |
| `answer.summary` | 非空 |
| `answer.keyPoints` | **至少 1 条**，非空、无重复；这是评分点，不是参考答案的段落 |
| `source.url` | http(s) |
| `source.license` | 必须登记；非 MIT/Apache/CC-BY 系需人工审核 |
| `status` | 见下 |
| `updatedAt` | ISO 日期 |

**status 语义**：`verified` 人工逐条校对；`community` 来自社区待校；`ai-draft` 仅占位；
`user` 用户自建（入 `question_local`，题库更新永不覆盖）；`orphaned` 上游已删除。
检索默认对后三者降权，UI 必须显示来源与状态。

## 3. manifest.json

```json
{
  "schemaVersion": 1,
  "bankVersion": "2026.10.3",
  "minAppVersion": "0.5.0",
  "generatedAt": "2026-10-22T02:00:00Z",
  "gitCommit": "abc1234",
  "counts": { "questions": 620, "experiences": 48 },
  "files": [{ "path": "questions/backend/go-001.yaml", "sha256": "…64 hex…", "bytes": 4211 }],
  "assets": [{ "name": "bank-2026.10.3.tar.zst", "sha256": "…", "bytes": 5242880 }],
  "signature": "ed25519:…"
}
```

校验器检查 `schemaVersion=1`、`bankVersion` 形如 `YYYY.M.P`、`files[].sha256` 为 64 位 hex、
`signature` 以 `ed25519:` 开头。

**签名规范（T-016 已实现）**：`signature = ed25519:<base64>`；签名体为 manifest 去掉 `signature`
字段后、递归按 key 排序的紧凑 JSON（UTF-8）。App 内置公钥（`--dart-define=BANK_PUBLIC_KEY` 可覆盖），
私钥只放 CI Secret。更新包支持 `.tar.zst`（主）、`.tar.gz`、`.zip`；任一文件哈希、包大小
（≤50MB）、解压后大小（≤100MB）与 schema 均校验通过后，才在单个数据库事务内切换。

## 4. 校验

```bash
source tool/env.sh
dart run tool/validate_bank.dart assets/bank_seed
```

- 所有问题一次性收集，不 fail-fast；每条输出 `file:line:column [field] message`。
- 退出码：0 通过、1 有错、2 目录不存在。
- CI（`mockmate-bank` 仓库）应在每次 PR 与 release 前跑同一校验器。

## 5. 许可与来源

- 只导入 MIT / Apache-2.0 / CC-BY 系；无法识别许可证时拒绝导入。
- 每道题必须有 `source.url` + `source.license`；保留上游版权声明与 LICENSE。
- 不镜像整页内容；官方文档只引用必要片段并回链。
- 面经只存摘要 + 题目 + 出处，单页、用户触发，不批量爬取。
