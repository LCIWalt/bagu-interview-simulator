# 开发环境（本机实测记录）

> 记录时间：2026-10-22 · 机器：Apple M4 / macOS 26.2 · 维护者：本项目
> 恢复环境只需一条命令：`source tool/env.sh`

---

## 1. 主机

| 项 | 值 |
|---|---|
| macOS | 26.2（Build 25C56） |
| 芯片 | Apple M4（arm64） |
| 可用磁盘 | 约 365 GB |
| 区域 / 语言 | zh-Hans-CN |
| 系统代理 | `http://127.0.0.1:7897`（Clash 类） |

---

## 2. 工具链总览

| 组件 | 版本 | 位置 | 来源 |
|---|---|---|---|
| Flutter | **3.47.7** stable | `mockmate/.toolchain/flutter` | 官方 zip（flutter-io.cn 镜像，分段下载） |
| Dart | **3.13.5**（随 Flutter） | 同上 | 同上 |
| DevTools | 2.60.0 | 同上 | 同上 |
| Gradle | **9.3.1** | `mockmate/.toolchain/gradle` | 腾讯镜像（官方源下载损坏） |
| JDK | **21.0.8**（Android Studio JBR） | `/Applications/Android Studio.app/Contents/jbr/Contents/Home` | 复用已有 |
| Android SDK | **36.1.0** | `~/Library/Android/sdk` | 复用已有 |
| ├ platforms | android-36、android-37.0 | 同上 | 复用 |
| ├ build-tools | 36.0.0、36.1.0 | 同上 | 复用 |
| ├ platform-tools | 36.0.2（adb） | 同上 | 复用 |
| ├ NDK | **28.2.13676358**（2.8 GB） | `~/Library/Android/sdk/ndk/` | 用户经 Android Studio 安装 |
| └ emulator | 36.3.10（AVD `Medium_Phone_API_36.1`） | 同上 | 复用（本项目用真机，不依赖） |
| Xcode | **26.6**（Build 17F113） | `/Applications/Xcode.app` | 复用已有 |
| CocoaPods | **1.17.0** | `/opt/homebrew` | 本次安装 |
| Homebrew | 7.0.10 | `/opt/homebrew` | 复用 |
| Git | 2.50.1（Apple Git-155） | 系统 | 复用 |

磁盘占用：`.toolchain/flutter` 4.1 GB、`.toolchain/gradle` 3.4 GB、`pub-cache` 154 MB。

---

## 3. 环境变量（`tool/env.sh`）

| 变量 | 值 | 原因 |
|---|---|---|
| `FLUTTER_ROOT` | `<repo>/.toolchain/flutter` | SDK 放项目内，不污染系统 |
| `XDG_CONFIG_HOME` | `<repo>/.toolchain/config` | Flutter 配置（含 SPM 开关）不能写 `~/.config` |
| `PUB_CACHE` | `<repo>/.toolchain/pub-cache` | 沙箱不允许写 `~/.pub-cache` |
| `GRADLE_USER_HOME` | `<repo>/.toolchain/gradle` | 发行版与依赖缓存；同时解决损坏重下 |
| `CP_HOME_DIR` | `<repo>/.toolchain/cocoapods` | CocoaPods 主目录 |
| `JAVA_HOME` | Android Studio JBR | 免装 JDK，版本满足 AGP 9.1 |
| `ANDROID_HOME` | `~/Library/Android/sdk` | 复用现有 SDK |
| `DEVELOPER_DIR` | `/Applications/Xcode.app/Contents/Developer` | `xcode-select` 仍指向 CLT，免 sudo 绕过 |
| `FLUTTER_STORAGE_BASE_URL` | `https://storage.flutter-io.cn` | 官方 storage 走代理不可用 |
| `FLUTTER_SUPPRESS_ANALYTICS` | `true` | 否则尝试写 `~/.dart-tool` 失败 |

**未覆盖 `HOME`**：`xcodebuild` 用 `getpwuid` 取真实 home，改 `HOME` 无效（已验证）。

---

## 4. 已验证的构建

| 目标 | 命令 | 结果 |
|---|---|---|
| Android debug APK | `flutter build apk --debug` | ✅ `build/app/outputs/flutter-apk/app-debug.apk` |
| macOS debug app | `flutter build macos --debug` | ✅ `build/macos/Build/Products/Debug/smoke.app` |
| iOS simulator | `flutter build ios --simulator --no-codesign` | ⛔ 本机 Xcode 未安装 iOS 26.5 平台组件（见 §7.4），代码/工程已就绪，CI 覆盖 |
| macOS debug（M0） | `flutter build macos --debug` | ✅ 2026-10-22 M0 验证（ad-hoc 签名） |
| Android debug APK（M0） | `flutter build apk --debug` | ✅ 2026-10-22 M0 验证（`app-debug.apk`） |
| Android release APK | `flutter build apk --release --split-per-abi` | ✅ 2026-10-22（arm64 69.4MB / v7a 59.0MB / x86_64 76.8MB，debug 签名） |
| Android universal APK | `flutter build apk --release` | ⚠️ 170MB（含三 ABI + 24MB 模型，不建议分发） |
| macOS release app | `flutter build macos --release` | ✅ 2026-10-22（156MB，含 ORT + 模型，ad-hoc 签名） |
| macOS DMG | `bash tool/package_macos.sh` | ⛔ 沙箱拒绝 hdiutil（`操作不被允许`），需普通终端执行 |

`flutter doctor` 当前输出 4 类提示，**均不阻塞构建**：

| 提示 | 影响 | 处理 |
|---|---|---|
| `cmdline-tools component is missing` | 仅影响 `flutter doctor --android-licenses` | 可选：Android Studio → SDK Tools → 勾 **Android SDK Command-line Tools (latest)** |
| `Android license status unknown` | 同上；`licenses/` 已存在，Gradle 构建正常 | 同上装完后自动消除 |
| `Unable to get list of installed Simulator runtimes` | 本机用真机，不需要模拟器 | 忽略；如需要再 `xcodebuild -downloadPlatform iOS` |
| `Cannot find Chrome` | 不做 Web 端 | 忽略 |

---

## 5. 已知偏离与坑（重要）

### 5.1 Swift Package Manager 已关闭
```bash
flutter config --no-enable-swift-package-manager
```
**原因**：`xcodebuild` 解析 SPM 依赖时会写 `~/Library/Developer/Xcode/DerivedData`，本机沙箱拒绝（`You don't have permission ... manifests`）。
**后果**：iOS/macOS 插件走 CocoaPods（已验证可用）。
**风险**：Flutter 官方提示未来版本可能强制 SPM；升级 Flutter 时需重新评估。记录在 `docs/decisions/` 待补 ADR。

### 5.2 `xcode-select` 仍指向 CLT
当前：`/Library/Developer/CommandLineTools`。已用 `DEVELOPER_DIR` 绕过。
若要全局修复（需 sudo，用户执行）：
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### 5.3 Gradle 发行版
官方 `services.gradle.org` 下载得到损坏 zip（`zip END header not found`）。
已换腾讯镜像并把有效包放进 `GRADLE_USER_HOME/wrapper/dists/...`。
**若清空 `.toolchain/gradle`**，需重新下载，或改 `android/gradle/wrapper/gradle-wrapper.properties` 的 `distributionUrl`。

### 5.4 网络
- `storage.googleapis.com` 走代理返回 0 字节 → 用 `storage.flutter-io.cn`（**直连**，不要走代理）。
- `dl.google.com` 走代理可用（NDK / cmdline-tools 下载正常）。
- 国内镜像建议直连：`curl --noproxy '*'`。

### 5.5 NDK 版本
Flutter 3.47.7 在 `FlutterExtension.kt` 中写死 `ndkVersion = "28.2.13676358"`。
装其他版本（如 30）必须在每个工程 `android/app/build.gradle.kts` 手动覆盖，否则 Gradle 仍会尝试下载 28.2。当前统一用 28.2。

### 5.6 沙箱与写权限
本机 agent 只能写工作区。因此：
- Android SDK / NDK 由**用户在 Android Studio 里安装**；
- 系统级工具（Homebrew 包）安装需用户批准；
- 构建产物与缓存全部落在工作区（见 §3）。

---

## 6. 真机

| 平台 | 前提 | 命令 |
|---|---|---|
| Android | 开启 USB 调试并在手机上授权 | `flutter devices` → `flutter run -d <id>` |
| iOS | Xcode 登录 Apple ID（免费 Team），首次需在 Xcode 里跑一次以生成描述文件；**7 天过期需重签** | `flutter run -d <id>` |
| macOS | 无 | `flutter run -d macos` |

无 Apple 开发者账号（$99）→ 不做公证、不上架、无 TestFlight。

---

## 7. 日常命令

```bash
source tool/env.sh
flutter doctor
flutter pub get
flutter test
flutter run -d macos
flutter run -d <android-device>
flutter run -d <ios-device>
```

### 7.1 Agent / 沙箱环境注意

Dart CLI（`dart run build_runner`）与分析服务器会尝试写 `~/.dart-tool`、`~/.dartServer`，本机沙箱拒绝。非交互执行时需临时把 `HOME` 指到工作区：

```bash
source tool/env.sh
mkdir -p .toolchain/home
HOME="$PWD/.toolchain/home" dart run build_runner build
HOME="$PWD/.toolchain/home" flutter analyze
HOME="$PWD/.toolchain/home" flutter test
```

代码生成（drift / freezed / json_serializable）只在实体变更时执行；生成物入库。正常桌面终端里直接跑 `flutter` 命令不受影响。

---

## 8. 新机器复现步骤

1. 安装 Xcode（含命令行工具）、Android Studio（含 SDK + NDK 28.2.13676358）、Homebrew。
2. `brew install cocoapods`
3. 下载 Flutter 3.47.7 stable zip 到 `mockmate/.toolchain/`，解压为 `.toolchain/flutter`。
4. 创建 `.toolchain/{config,pub-cache,gradle,cocoapods}`。
5. `source tool/env.sh && flutter --version`
6. `flutter config --no-enable-swift-package-manager`
7. 若 Gradle 下载失败：从 `https://mirrors.cloud.tencent.com/gradle/gradle-9.3.1-all.zip` 下载并放入
   `.toolchain/gradle/wrapper/dists/gradle-9.3.1-all/<hash>/gradle-9.3.1-all.zip`
8. `flutter create` 一个临时工程验证 `build apk` 与 `build macos`。

---

## 9. 待办

- [ ] iOS 真机首次签名验证（需用户登录 Apple ID）
- [ ] `cmdline-tools` 可选安装（消除 doctor 两条提示）
- [ ] M1.5 ONNX Runtime spike 前，确认 iOS 静态库与 Android ABI 打包方式
- [ ] 为「关闭 SPM」补一份 ADR（`docs/decisions/ADR-0001-disable-spm.md`）

### 7.0 M0 平台配置（已落地）

| 项 | 值 |
|---|---|
| iOS deployment target | 15.0（`ios/Podfile` 与 Xcode 工程） |
| macOS deployment target | 14.0（`macos/Podfile` 与 Xcode 工程） |
| macOS 权限 | app sandbox + `network.client`（+ debug 的 `network.server`/JIT） |
| Android | `minSdk 26`；Manifest 仅 `INTERNET`（v1 无麦克风） |
| macOS Keychain | 不启用 `keychain-access-groups`：无 $99 账号时该 entitlement 要求开发证书签名，会阻断 ad-hoc 构建；`PlatformSecureStore` 在 macOS 使用传统 login keychain（`useDataProtectionKeyChain: false`） |

### 7.2 sqlite3 pod 的 Tcl 问题（仅沙箱/本机 Agent）

`sqlite3_flutter_libs` 在 macOS 上通过 `configure`（autosetup + Tcl）生成 amalgamation。系统 `/usr/bin/tclsh` 为 **8.5.9**，在沙箱内执行失败的编译器探测时无法创建临时错误文件，表现为：

```
Error: couldn't create error file for command: not owner
```

处理（`tool/env.sh` 已自动化）：

1. 先跑一次 `pod install`，让 sqlite 源码落到 `.toolchain/cocoapods/cache/`；
2. `source tool/env.sh` 会自动用 `cc` 编译其中的 `autosetup/jimsh0.c` 到 `.toolchain/bin/jimsh0`，并导出 `autosetup_tclsh`；
3. 重新 `pod install` / `flutter build macos`。

在普通终端（无沙箱）或 CI 上不会触发；`autosetup_tclsh` 未设置时 autosetup 直接使用系统 tclsh。

### 7.3 Android SDK 只读 + CMake（本机 Agent）

`path_provider_android` 依赖 `jni`，构建时需要 **CMake 3.22.1**。本机 SDK 目录对 Agent 只读、且未安装 CMake，Gradle 会尝试自动安装并失败：

```
Failed to install ... cmake;3.22.1
The SDK directory is not writable
```

处理（仅 Agent 环境）：

1. 从 `https://dl.google.com/android/repository/cmake-3.22.1-darwin.zip` 下载并解压到
   `.toolchain/android-sdk-home/cmake/3.22.1/`（含 `bin/cmake`、`source.properties`）；
2. 用符号链接把真实 SDK 的 `platforms`、`ndk`、`build-tools`、`platform-tools`、`licenses`
   等目录链到 `.toolchain/android-sdk-home/`；
3. `flutter config --android-sdk <repo>/.toolchain/android-sdk-home`；
4. 构建时同时导出 `ANDROID_HOME` / `ANDROID_SDK_ROOT` 指向该目录。

正常用户环境只需在 Android Studio → SDK Tools 里安装 **CMake 3.22.1**，不需要上述链接。

另外，本机只装了 android-36/37，而部分插件声明 `compileSdk 34`。`android/build.gradle.kts`
会把子工程 `compileSdkVersion` 统一抬到 36，避免向只读 SDK 安装 Platform 34。CI 上可直接安装对应版本，该覆盖仍然安全。

### 7.4 iOS 平台组件缺失（本机）

`xcodebuild` 能列出 iOS 26.5 SDK，但设备/模拟器 destination 均不可用：

```
error: iOS 26.5 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

这不是工程配置问题。安装 iOS 平台组件（数 GB）后即可：

```bash
source tool/env.sh
flutter build ios --simulator --no-codesign   # 开发/CI
flutter build ios --no-codesign               # 真机产物（未签名）
```

另：Agent 沙箱内启动 GUI App 会失败（`Error waiting for a debug connection: The log reader stopped unexpectedly`），因此
`flutter test integration_test -d macos` 需要在普通终端手工执行；M0 已提供
`integration_test/app_boot_test.dart`（启动 + Keychain 往返）。
