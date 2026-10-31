#!/bin/bash
# Host-side `expo run:android` that forces a Gradle-compatible JDK. The Gradle
# used by React Native 0.79 fails on JDK 25 ("Unsupported class file major
# version 69"); JDK 17 (or 21) works.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ -z "${JAVA_HOME:-}" ] || ! "$JAVA_HOME/bin/java" -version 2>&1 | grep -Eq 'version "(17|21)\.'; then
  if [ -x /usr/libexec/java_home ]; then
    JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || /usr/libexec/java_home -v 21 2>/dev/null || true)"
  fi
fi
if [ -z "${JAVA_HOME:-}" ]; then
  echo "ERROR: JDK 17 or 21 not found. On macOS: brew install --cask temurin@17" >&2
  exit 1
fi
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"
echo "Using JAVA_HOME=$JAVA_HOME"

# Gradle caches the daemon JVM; stop any started under the wrong JDK
[ -x android/gradlew ] && (cd android && ./gradlew --stop >/dev/null 2>&1 || true)
exec npx expo run:android "$@"
