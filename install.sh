#!/usr/bin/env bash
set -euo pipefail

APK_URL="https://github.com/banseok/creditcard-tracker-apk/raw/main/CardTracker-debug.apk"
TMP_APK="/tmp/CardTracker-debug.apk"

echo "==> [1/3] adb 설치 여부 확인 중..."
if ! command -v adb >/dev/null 2>&1; then
  if [ -x "$HOME/Android/Sdk/platform-tools/adb" ]; then
    export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
  else
    echo "adb가 없어 apt로 설치합니다..."
    sudo apt-get update && sudo apt-get install -y adb curl
  fi
fi

echo "==> [2/3] 연결된 안드로이드 기기 확인 중..."
adb start-server >/dev/null 2>&1 || true
DEVICES=$(adb devices | awk 'NR>1 && $2=="device" {print $1}')
if [ -z "$DEVICES" ]; then
  echo ""
  echo "⚠️  인식된 안드로이드 기기가 없습니다!"
  echo "   1) 휴대폰을 USB로 연결하고 크롬북 우측 하단 알림에서 [Linux에 연결]을 눌러주세요."
  echo "   2) 휴대폰 화면에 'USB 디버깅 허용' 창이 뜨면 [허용]을 누른 뒤 다시 실행해 주세요."
  echo ""
  adb devices
  exit 1
fi

echo "==> [3/3] 최신 CardTracker APK 다운로드 및 설치 중..."
curl -fL "${APK_URL}?t=$(date +%s)" -o "$TMP_APK"
adb install -r "$TMP_APK"
rm -f "$TMP_APK"

# 다음부터 명령어 한 줄로 업데이트할 수 있도록 단축 스크립트 생성
cat << 'SHORTCUT' > "$HOME/update-cardtracker.sh"
#!/usr/bin/env bash
curl -fsSL https://raw.githubusercontent.com/banseok/creditcard-tracker-apk/main/install.sh | bash
SHORTCUT
chmod +x "$HOME/update-cardtracker.sh"

echo ""
echo "✅ 안드로이드 기기에 최신 버전 설치가 완료되었습니다!"
echo "💡 다음부터는 터미널에 ~/update-cardtracker.sh 만 입력하면 바로 업데이트됩니다."
