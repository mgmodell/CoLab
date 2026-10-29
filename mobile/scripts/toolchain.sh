#!/bin/bash
# Installs what is needed to build the Android app and run Maestro inside the
# dev / test containers: a JDK, the Android SDK and Maestro. Everything goes
# under the mise volume (devmise / testmise) so it is only downloaded once.
set -euo pipefail

SDK_ROOT="${ANDROID_HOME:-$HOME/.local/share/mise/android-sdk}"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-11076708_latest.zip"

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"

if ! command -v java >/dev/null 2>&1; then
  echo "Installing JDK 17"
  mise use -g java@temurin-17
fi
eval "$(mise env --shell bash)"

if [ ! -x "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "Installing Android command line tools"
  mkdir -p "$SDK_ROOT/cmdline-tools"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/tools.zip" "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"
  unzip -q "$tmp/tools.zip" -d "$tmp"
  rm -rf "$SDK_ROOT/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"
  rm -rf "$tmp"
fi

SDKMANAGER="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
if [ ! -d "$SDK_ROOT/platform-tools" ] || [ ! -d "$SDK_ROOT/build-tools/35.0.0" ]; then
  echo "Installing Android SDK packages"
  yes | "$SDKMANAGER" --licenses >/dev/null || true
  "$SDKMANAGER" "platform-tools" "platforms;android-35" "build-tools;35.0.0"
fi

if [ ! -x "$HOME/.maestro/bin/maestro" ]; then
  echo "Installing Maestro"
  curl -fsSL "https://get.maestro.mobile.dev" | bash
fi

echo "Toolchain ready"
