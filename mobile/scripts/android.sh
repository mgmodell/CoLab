#!/bin/bash
# Host-side `expo run:android` on a Gradle-compatible JDK. The Gradle used by
# React Native 0.79 fails on JDK 25 ("Unsupported class file major version 69").
# The JDK (temurin 17) is pinned in mobile/mise.toml and installed by mise.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if command -v mise >/dev/null 2>&1; then
  mise trust --all >/dev/null 2>&1 || true
  mise install java
  JAVA_HOME="$(mise where java)"
elif [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || /usr/libexec/java_home -v 21 2>/dev/null || true)"
fi
if [ -z "${JAVA_HOME:-}" ]; then
  echo "ERROR: JDK 17/21 not found. Install mise (https://mise.jdx.dev) or a JDK." >&2
  exit 1
fi
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"
echo "Using JAVA_HOME=$JAVA_HOME"

# Gradle caches the daemon JVM; stop any started under the wrong JDK
[ -x android/gradlew ] && (cd android && ./gradlew --stop >/dev/null 2>&1 || true)
exec npx expo run:android "$@"
