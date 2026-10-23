#!/usr/bin/env bash
# 构建 macOS release 并打包 ad-hoc DMG（T-072）
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "${CI:-}" != "true" ]; then
  source tool/env.sh >/dev/null
fi

VERSION=$(awk '/^version:/ {print $2}' pubspec.yaml | cut -d+ -f1)
APP="build/macos/Build/Products/Release/BaguInterviewSimulator.app"
OUT="dist/BaguInterviewSimulator-${VERSION}.dmg"

flutter build macos --release

echo "Ad-hoc 签名…"
codesign --force --deep --sign - "$APP"

echo "生成 DMG…"
rm -rf build/dmg-staging "$OUT"
mkdir -p build/dmg-staging
cp -R "$APP" build/dmg-staging/BaguInterviewSimulator.app
ln -s /Applications build/dmg-staging/Applications
mkdir -p dist
hdiutil create -volname "Bagu Interview Simulator" -srcfolder build/dmg-staging -ov -format UDZO "$OUT" >/dev/null
rm -rf build/dmg-staging

echo "完成：$OUT"
echo "首次打开如被拦截：xattr -d com.apple.quarantine \"/Applications/BaguInterviewSimulator.app\""
