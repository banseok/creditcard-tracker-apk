#!/usr/bin/env bash
set -euo pipefail

CMDTOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip"
SDK_ROOT="$HOME/Android/Sdk"

echo "==> [1/4] 필수 패키지 설치 (OpenJDK 17, git, curl, unzip)..."
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk git curl unzip

echo "==> [2/4] Android SDK Command-Line Tools (rev 23.0) 다운로드 중..."
mkdir -p "$SDK_ROOT/cmdline-tools"
rm -rf "$SDK_ROOT/cmdline-tools/latest" /tmp/cmdtools.zip
curl -fL "$CMDTOOLS_URL" -o /tmp/cmdtools.zip
unzip -q /tmp/cmdtools.zip -d "$SDK_ROOT/cmdline-tools"
mv "$SDK_ROOT/cmdline-tools/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"
rm -f /tmp/cmdtools.zip

echo "==> [3/4] 환경 변수 설정 (~/.bashrc)..."
if ! grep -q 'ANDROID_HOME=' "$HOME/.bashrc" 2>/dev/null; then
  cat << 'BRC' >> "$HOME/.bashrc"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
BRC
fi

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo "==> [4/4] 라이선스 동의 및 Android 34 SDK / platform-tools 설치 중..."
yes | "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK_ROOT" --licenses >/dev/null || true
"$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK_ROOT" \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "build-tools;35.0.0"

echo ""
echo "✅ Android SDK 및 adb 설치가 모두 완료되었습니다! (경로: $SDK_ROOT)"
echo "   새 설정 적용을 위해 아래 명령어를 한 번 실행해 주세요:"
echo "   source ~/.bashrc"
