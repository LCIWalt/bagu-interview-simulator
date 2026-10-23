# ADR-0003 · 题库更新管线与契约增量

- 状态：已接受
- 日期：2026-10-22
- 关联：T-016/T-017/T-018，`docs/PROJECT_GUIDE.md` §6.3

## 契约增量

`BankUpdateProgress` 新增 `BankUpToDate(BankManifest?)`，用于表达「304 / 版本不高于本地」。
原 `BankUpdated` 只在真正完成切换后发出。这是纯增量，旧实现不受影响；`BankRepository.update`
签名不变。

## 签名与压缩

- `signature = ed25519:<base64>`，签名对象为去掉 `signature` 后递归排序 key 的紧凑 JSON。
- 解压使用 `pure_zstd`（纯 Dart，MIT）处理 `.tar.zst`，`archive` 处理 tar/gzip/zip；
  不引入原生 zstd 库，保持三端零额外原生依赖。
- 公钥默认内置开发 key，正式分发用 `--dart-define=BANK_PUBLIC_KEY` 注入；私钥只进 CI Secret。

## 事务与回滚

1. 下载与校验全部在 staging 完成，现有 `bank_meta.active_dir` 不变；
2. 题库文件移动到 `bank/versions/<version>` 后，才在**单个 drift 事务**内 upsert 题目、
   标记 orphaned、写 `bank_meta`/manifest；
3. 事务失败删除新版本目录并保留旧版本；`question_local` 不参与更新；
4. 成功后仅保留最近 2 个版本目录。

## 已知限制

- Release 源默认指向占位仓库 `mockmate/mockmate-bank`，上线前需替换
  `kDefaultBankReleaseApiUrl`；`beta`/`mirror` 通道当前共用 stable 资产。
- 断点续传未实现（HTTP Range）；失败重试由用户触发，下载进度与取消已支持。
