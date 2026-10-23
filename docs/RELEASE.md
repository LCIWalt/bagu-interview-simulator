# 构建与分发（自用）

> 环境与坑见 `docs/ENVIRONMENT.md`；以下命令先执行 `source tool/env.sh`。

## macOS

```bash
flutter build macos --release
bash tool/package_macos.sh          # 生成 dist/MockMate-<version>.dmg（ad-hoc 签名）
```

- 无 $99 账号：不做公证；首次打开需右键「打开」或
  `xattr -d com.apple.quarantine /Applications/MockMate.app`。
- entitlements：无 App Sandbox（ad-hoc 自用构建，见 ADR-0006），保留 `network.client`；不申请麦克风。
- Sparkle 更新暂不接；手动替换 App。

## Android

```bash
flutter build apk --release --split-per-abi
```

- 必须用 `--split-per-abi`：含 bge 模型与 ONNX Runtime 后 universal APK 约 170MB，
  分 ABI 后 arm64 约 69MB、v7a 约 59MB、x86_64 约 77MB。
- v1 只有 `INTERNET` 权限。
- 自用可先用 debug 签名；正式分发前在 `android/app/build.gradle.kts` 配置自己的 keystore，
  密钥不入库、不进 CI 明文。
- 产物：`build/app/outputs/flutter-apk/app-*-release.apk`。

## iOS 真机（本机已验证）

沙箱/受限终端里 `flutter run` 会因 DerivedData 与 `~/.dart-tool` 写入被拒而失败，用脚本：

```bash
bash tool/build_ios_device.sh <你的设备UDID> com.mockmate.mockmate
```

脚本把 DerivedData 放到 `.toolchain/DerivedData`，并把 Flutter 配置/遥测目录移到工作区，
然后 `xcodebuild` 签名、`devicectl` 安装并启动。已验证设备 iPhone（iOS 26.5.2），
bundle id 使用占位值 `com.mockmate.mockmate`；签名团队请在 Xcode 中选择你自己的 Team。

普通 Terminal.app 中也可以直接 `flutter run -d <udid>`；DSH/沙箱终端建议用上面的脚本。

- 无开发者账号：模拟器 `flutter build ios --simulator --no-codesign`；
  真机用免费个人 Team 在 Xcode 直装，**7 天过期需重签**。
- 不做 TestFlight、不上架、不公证。
- 本机 Xcode 目前缺 iOS 平台组件（`docs/ENVIRONMENT.md` §7.4），需先从 Xcode Settings 安装。

## CI

- `.github/workflows/ci.yml`：analyze / format / test + macOS/iOS/Android 构建。
- `.github/workflows/eval.yml`：手动触发校准评测（需 `SCORER_API_KEY`）。
- `.github/workflows/release.yml`：打 tag 产出 macOS/Android 未签名产物（无 Secret 时可跳过签名）。
