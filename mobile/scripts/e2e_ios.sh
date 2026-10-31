#!/bin/bash
# iOS simulators only run on macOS, so this runs on the host (not in a container).
# Start the backend first (the containers publish it on localhost:3000), then:
#   mobile/scripts/e2e_ios.sh
# Requires Xcode, Node, and Maestro (https://maestro.mobile.dev).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
export COLAB_API_URL="${COLAB_API_URL:-http://localhost:3000}"
E2E_EMAIL="${E2E_EMAIL:-mobile_e2e@example.com}"
E2E_PASSWORD="${E2E_PASSWORD:-password}"

npm ci --legacy-peer-deps
npx expo run:ios --no-bundler
maestro test -e E2E_EMAIL="$E2E_EMAIL" -e E2E_PASSWORD="$E2E_PASSWORD" .maestro
