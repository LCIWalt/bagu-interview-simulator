# ADR-0001 · 关闭 Swift Package Manager，iOS/macOS 走 CocoaPods

- 状态：已接受
- 日期：2026-10-22
- 关联：`docs/ENVIRONMENT.md` §5.1

## 背景

本机 `xcodebuild` 解析 SPM 依赖时需要写 `~/Library/Developer/Xcode/DerivedData`，而 Agent 沙箱禁止写用户目录，导致 Flutter 的 iOS/macOS 构建在解析 manifest 阶段失败。

## 决策

执行 `flutter config --no-enable-swift-package-manager`，插件统一通过 CocoaPods 集成。该配置写入项目内 `XDG_CONFIG_HOME`（`.toolchain/config`），不污染系统。

## 后果

- iOS/macOS 构建已验证可用（macOS debug、iOS 模拟器）。
- 升级 Flutter 时需复核：若官方强制 SPM，需要为构建机提供可写的 DerivedData 或调整沙箱策略。
- CI 的 macOS job 显式执行同一条 config 命令，保证与本地一致。
