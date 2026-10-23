#!/usr/bin/env bash
# 在受限/沙箱终端里构建并安装 iOS release 到真机。
# 用法：bash tool/build_ios_device.sh [设备UDID] [BundleID]
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -lt 1 ]; then
  echo "用法: bash tool/build_ios_device.sh <设备UDID> [BundleID]"
  exit 2
fi
DEVICE="$1"
BUNDLE_ID="${2:-com.mockmate.mockmate}"

source tool/env.sh >/dev/null
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export XDG_CONFIG_HOME="$PWD/.toolchain/config"
export FLUTTER_SUPPRESS_ANALYTICS=true
mkdir -p "$XDG_CONFIG_HOME"

DERIVED="$PWD/.toolchain/DerivedData"
APP="$DERIVED/Build/Products/Release-iphoneos/Runner.app"

echo "==> Building for $DEVICE (DerivedData: $DERIVED)"
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination "id=$DEVICE" \
  -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates \
  build

echo "==> Installing $BUNDLE_ID"
xcrun devicectl device install app --device "$DEVICE" "$APP"

echo "==> Launching"
xcrun devicectl device process launch --device "$DEVICE" "$BUNDLE_ID"
echo "==> Done"
