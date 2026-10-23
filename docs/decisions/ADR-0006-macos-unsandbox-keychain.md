# ADR-0006：macOS 自用构建去掉 App Sandbox 以恢复 Keychain

- 状态：已接受（自用/本地分发）
- 日期：2026-10-22

## 背景

ad-hoc 签名（无开发者证书）无法同时满足：

- `com.apple.security.app-sandbox` + `keychain-access-groups`：Xcode 要求开发证书，构建直接失败。
- 保留 sandbox 但没有 keychain entitlement：`flutter_secure_storage` 写入返回
  `-34018 A required entitlement isn't present`，API key 无法持久化，连通性测试拿不到 key。

## 决策

- macOS Debug/Release 移除 `com.apple.security.app-sandbox`，保留 `network.client`（Debug 保留 JIT）。
- `flutter_secure_storage` 使用 legacy keychain（`useDataProtectionKeyChain: false`）。
- 首次启动把旧 sandbox 容器里的数据库与本地题库迁移到非 sandbox 的
  `~/Library/Application Support/com.mockmate.mockmate/`。
- iOS/Android 不受影响，仍使用系统安全存储。

## 后果

- Keychain 可写，API key 能持久化；不再满足 Mac App Store 的 sandbox 要求。
- 分发方式仅限自用 DMG/本地安装，不上架。
- 若将来获得开发者证书，应恢复 sandbox + keychain-access-groups 并重新评估迁移。
