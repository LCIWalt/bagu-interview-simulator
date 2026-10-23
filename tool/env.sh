#!/usr/bin/env bash
# MockMate 开发环境（macOS arm64）— 本机实测可用
# 用法：source tool/env.sh
# 详细参数、坑与复现步骤见 docs/ENVIRONMENT.md

MOCKMATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export MOCKMATE_ROOT

# ---- Flutter（项目内 SDK，4.1G）----
export FLUTTER_ROOT="${MOCKMATE_ROOT}/.toolchain/flutter"
if [ -d "${FLUTTER_ROOT}/bin" ]; then
  export PATH="${FLUTTER_ROOT}/bin:${PATH}"
fi

# ---- 所有缓存都放工作区，避免写用户目录（沙箱限制）----
export XDG_CONFIG_HOME="${MOCKMATE_ROOT}/.toolchain/config"   # flutter config 存这里
export PUB_CACHE="${MOCKMATE_ROOT}/.toolchain/pub-cache"      # Dart 包缓存
export GRADLE_USER_HOME="${MOCKMATE_ROOT}/.toolchain/gradle"  # Gradle 发行版与依赖
export CP_HOME_DIR="${MOCKMATE_ROOT}/.toolchain/cocoapods"    # CocoaPods 主目录

# ---- Java：复用 Android Studio 自带 JBR 21 ----
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# ---- Android SDK：复用已有安装（含 NDK 28.2.13676358）----
export ANDROID_HOME="${HOME}/Library/Android/sdk"
export ANDROID_SDK_ROOT="${ANDROID_HOME}"

# ---- Xcode：xcode-select 指向 CLT，用 DEVELOPER_DIR 免 sudo 绕过 ----
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# ---- 国内镜像 ----
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
# pub.dev 官方可直连；如超时再启用：
# export PUB_HOSTED_URL="https://pub.flutter-io.cn"

# ---- 关闭统计（否则 flutter 会尝试写 ~/.dart-tool 并失败）----
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true

# ---- sqlite3 pod 的 configure 需要自带 Tcl（系统 tclsh 8.5 在沙箱下无法建临时错误文件）----
# pod install 首次失败后，源码会留在缓存里；这里自动编译 Jim Tcl 供 autosetup 使用。
JIMSH="${MOCKMATE_ROOT}/.toolchain/bin/jimsh0"
if [ ! -x "${JIMSH}" ]; then
  JIMSH_SRC="$(ls -d "${MOCKMATE_ROOT}"/.toolchain/cocoapods/cache/Pods/Release/sqlite3/*/sqlite-src-*/autosetup/jimsh0.c 2>/dev/null | head -1)"
  if [ -n "${JIMSH_SRC}" ]; then
    mkdir -p "$(dirname "${JIMSH}")"
    cc -O2 -o "${JIMSH}" "${JIMSH_SRC}" >/dev/null 2>&1 || true
  fi
fi
if [ -x "${JIMSH}" ]; then
  export autosetup_tclsh="${JIMSH}"
fi

echo "MockMate env ready:"
echo "  flutter : $(command -v flutter || echo 'not found')"
echo "  java    : ${JAVA_HOME}"
echo "  android : ${ANDROID_HOME}"
echo "  xcode   : ${DEVELOPER_DIR}"
echo "  cache   : ${MOCKMATE_ROOT}/.toolchain"
