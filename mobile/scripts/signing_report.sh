#!/bin/bash
# Prints the SHA-1 of the debug keystore, i.e. the value the Google Cloud
# *Android* OAuth client needs (together with package name com.mmp.colab).
# Uses the same JDK (mise, java 17) and SDK lookup as `npm run android`.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if command -v mise >/dev/null 2>&1; then
  mise trust --all >/dev/null 2>&1 || true
  mise install java
  JAVA_HOME="$(mise where java)"
elif [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || /usr/libexec/java_home -v 21 2>/dev/null || true)"
fi
[ -n "${JAVA_HOME:-}" ] || { echo "ERROR: JDK 17/21 not found" >&2; exit 1; }
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"

# keytool needs no Android SDK; use the debug keystore Expo generated
KEYSTORE=android/app/debug.keystore
if [ ! -f "$KEYSTORE" ]; then
  echo "ERROR: $KEYSTORE not found. Run 'npm run android' once (or 'npx expo prebuild --platform android')." >&2
  exit 1
fi
echo "Package name: $(node -p "require('./app.json').expo.android.package")"
keytool -list -v -keystore "$KEYSTORE" -alias androiddebugkey \
  -storepass android -keypass android | grep -E "SHA1|SHA256"
