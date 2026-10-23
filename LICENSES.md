# 第三方依赖与内容许可

本项目自用、不分发付费版本。引入依赖前需确认非 GPL/AGPL。

## 运行时依赖（直接）

| 包 | 许可 |
|---|---|
| flutter_riverpod / riverpod | MIT |
| go_router | BSD-3-Clause |
| drift / sqlite3_flutter_libs | MIT / MIT（SQLite 为 Public Domain） |
| path_provider / path | BSD-3-Clause / MIT |
| dio | MIT |
| flutter_secure_storage | BSD-3-Clause |
| freezed_annotation / json_annotation | MIT / BSD-3-Clause |
| crypto | BSD-3-Clause |
| archive | MIT |
| pure_zstd | MIT |
| cryptography | Apache-2.0 |
| html | MIT |
| package_info_plus | BSD-3-Clause |
| yaml | MIT |
| intl | BSD-3-Clause |
| just_audio / audio_session | MIT |
| flutter_onnxruntime | MIT |
| bge-small-zh-v1.5（Xenova 转换） | MIT（BAAI） |

> 以各包 `LICENSE` 与实际 lock 版本为准；发布前用 `flutter pub deps --style=compact` 复核。

## 题库内容

- 内置 16 道种子题由本项目整理，状态为 `community`（待人工校对）。
- 每题 `source` 标注来源 URL 与许可：Go 官方文档（BSD-3-Clause）、MDN（CC-BY-SA-2.5）、
  RFC（IETF Trust）、Wikipedia（CC-BY-SA-4.0）。
- 不镜像整页内容；只保留摘要、评分点与回链。
- 若引入第三方题库（MIT/Apache/CC-BY），须保留版权声明与 LICENSE，并在 `mockmate-bank` 仓库登记。
