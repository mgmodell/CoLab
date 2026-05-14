#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_FILE="${ROOT_DIR}/.devcontainer/devcontainer.json"

BASE_COMPOSE="../containers/dev_env/docker-compose.yml"
LINUX_ROOTLESS_COMPOSE="../containers/dev_env/docker-compose.rootless.yml"
MACOS_ROOTLESS_COMPOSE="../containers/dev_env/docker-compose.macos.yml"

if [ ! -f "${DEVCONTAINER_FILE}" ]; then
  echo "ERROR: ${DEVCONTAINER_FILE} not found." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to update ${DEVCONTAINER_FILE}." >&2
  exit 1
fi

OS_NAME="$(uname -s)"
ROOTLESS="false"

if command -v podman >/dev/null 2>&1; then
  ROOTLESS="$(podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null || echo false)"
fi

ROOTLESS="$(echo "${ROOTLESS}" | tr '[:upper:]' '[:lower:]')"

COMPOSE_JSON="\"${BASE_COMPOSE}\""
SELECTION_NOTE="base compose file"

if [ "${ROOTLESS}" = "true" ] && [ "${OS_NAME}" = "Linux" ]; then
  COMPOSE_JSON="[\"${BASE_COMPOSE}\", \"${LINUX_ROOTLESS_COMPOSE}\"]"
  SELECTION_NOTE="Linux rootless override"
elif [ "${ROOTLESS}" = "true" ] && [ "${OS_NAME}" = "Darwin" ]; then
  COMPOSE_JSON="[\"${BASE_COMPOSE}\", \"${MACOS_ROOTLESS_COMPOSE}\"]"
  SELECTION_NOTE="macOS rootless override"
fi

python3 - "${DEVCONTAINER_FILE}" "${COMPOSE_JSON}" <<'PY'
import re
import sys
from pathlib import Path

target = Path(sys.argv[1])
compose_json = sys.argv[2]
original = target.read_text(encoding="utf-8")
pattern = r'("dockerComposeFile"\s*:\s*)(\[[\s\S]*?\]|"[^"]*")(\s*,)'

updated, count = re.subn(
    pattern,
    lambda m: f"{m.group(1)}{compose_json}{m.group(3)}",
    original,
    count=1,
)

if count != 1:
    print("ERROR: Could not locate dockerComposeFile in .devcontainer/devcontainer.json", file=sys.stderr)
    sys.exit(1)

if updated != original:
    target.write_text(updated, encoding="utf-8")
PY
rc=$?
if [ "${rc}" -ne 0 ]; then
  echo "ERROR: Failed to update ${DEVCONTAINER_FILE} (python exit code: ${rc})." >&2
  exit 1
fi

echo "Updated .devcontainer/devcontainer.json dockerComposeFile (${SELECTION_NOTE})."
