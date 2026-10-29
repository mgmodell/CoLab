#!/bin/bash
# Runs the Maestro flows against the Android emulator container ("android"
# service) and a CoLab backend started (and seeded) by this script.
#
# Run from inside the dev or test container:
#   mobile/scripts/e2e_android.sh
# Optional environment:
#   ANDROID_EMULATOR_HOST  emulator adb endpoint        (default android:5555)
#   RAILS_ENV              backend environment          (default development;
#                          the test container sets 'test')
#   E2E_EMAIL / E2E_PASSWORD  seeded login              (default mobile_e2e@example.com / password)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export ANDROID_EMULATOR_HOST="${ANDROID_EMULATOR_HOST:-android:5555}"
export RAILS_ENV="${RAILS_ENV:-development}"
export COLAB_DB="${COLAB_DB:-db}"
export E2E_EMAIL="${E2E_EMAIL:-mobile_e2e@example.com}"
export E2E_PASSWORD="${E2E_PASSWORD:-password}"
# The emulator reaches the backend through `adb reverse`, so it sees it on localhost
export COLAB_API_URL="http://localhost:3000"

"$ROOT/mobile/scripts/toolchain.sh"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/.local/share/mise/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$HOME/.maestro/bin:$PATH"
eval "$(mise env --shell bash)"

RAILS_PID=""
cleanup() { [ -n "$RAILS_PID" ] && kill "$RAILS_PID" 2>/dev/null || true; }
trap cleanup EXIT

echo "Connecting to the emulator at $ANDROID_EMULATOR_HOST"
for _ in $(seq 1 60); do
  adb connect "$ANDROID_EMULATOR_HOST" >/dev/null 2>&1 || true
  adb -s "$ANDROID_EMULATOR_HOST" get-state >/dev/null 2>&1 && break
  sleep 5
done
adb -s "$ANDROID_EMULATOR_HOST" get-state >/dev/null || {
  echo "ERROR: cannot reach the emulator. Is the 'android' service running (needs /dev/kvm)?" >&2
  exit 1
}
echo "Waiting for the emulator to finish booting"
until [ "$(adb -s "$ANDROID_EMULATOR_HOST" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 5
done
export ANDROID_SERIAL="$ANDROID_EMULATOR_HOST"

cd "$ROOT"
echo "Seeding the backend ($RAILS_ENV)"
bundle exec rails mobile:seed_e2e

echo "Starting the backend"
mkdir -p tmp log
bundle exec rails server -p 3000 -b 0.0.0.0 -P tmp/pids/mobile_e2e.pid >log/mobile_e2e_server.log 2>&1 &
RAILS_PID=$!
for _ in $(seq 1 60); do
  curl -fs http://localhost:3000/endpoints.json >/dev/null 2>&1 && break
  sleep 2
done
curl -fs http://localhost:3000/endpoints.json >/dev/null || {
  echo "ERROR: backend did not start; see log/mobile_e2e_server.log" >&2
  exit 1
}
adb reverse tcp:3000 tcp:3000

cd "$ROOT/mobile"
npm ci --legacy-peer-deps
[ -d android ] || npx expo prebuild --platform android --no-install
(cd android && ./gradlew assembleDebug)
adb install -r android/app/build/outputs/apk/debug/app-debug.apk

maestro test -e E2E_EMAIL="$E2E_EMAIL" -e E2E_PASSWORD="$E2E_PASSWORD" \
  --format junit --output "$ROOT/reports/mobile_e2e.xml" .maestro
