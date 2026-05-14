#!/bin/bash

set -euo pipefail

echo "Arguments: $*"

dir="${HOME}/src/app"
mise_dir="${HOME}/.local/share/mise"

extract_mise_version() {
  local tool="$1"
  if [ ! -f mise.toml ]; then
    echo "ERROR: mise.toml not found in ${PWD}." >&2
    return 1
  fi
  local version
  version="$(awk -F'"' -v t="${tool}" '$0 ~ ("^[[:space:]]*" t "[[:space:]]*=[[:space:]]*\"") { print $2; exit }' mise.toml)"
  if [ -z "${version}" ]; then
    echo "ERROR: ${tool} is not configured in mise.toml." >&2
    return 1
  fi
  echo "${version}"
}

extract_bundler_version() {
  if [ ! -f Gemfile.lock ]; then
    echo "ERROR: Gemfile.lock not found in ${PWD}." >&2
    return 1
  fi
  local version
  version="$(awk '/^BUNDLED WITH$/ { getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit }' Gemfile.lock)"
  if [ -z "${version}" ]; then
    echo "ERROR: Could not find a bundler version in Gemfile.lock (BUNDLED WITH)." >&2
    return 1
  fi
  echo "${version}"
}

# Set up the version managers
echo "Setting the current working directory"
cd "${dir}"

# Add mise shims and bin to PATH so managed tools (bundle, yarn, etc.) are
# accessible in this non-interactive bash script. `mise activate bash` relies
# on PROMPT_COMMAND, which is never fired in non-interactive scripts, so we
# set PATH directly instead.
export PATH="${HOME}/src/app/node_modules/.bin:${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"

if [ ! -w "${dir}" ]; then
  echo "ERROR: ${dir} is not writable by $(id -un)."
  echo "If using rootless Podman, enable the correct compose override:"
  echo "  - Linux: ../containers/dev_env/docker-compose.rootless.yml"
  echo "  - macOS: ../containers/dev_env/docker-compose.macos.yml"
  echo "Then rebuild the devcontainer."
  exit 1
fi

if [ ! -w "${mise_dir}" ]; then
  echo "ERROR: ${mise_dir} is not writable by $(id -un)."
  echo "If this is a stale dev_env_devmise volume with incorrect ownership, remove it:"
  echo "  podman volume rm dev_env_devmise"
  echo "Then run: Dev Containers: Rebuild and Reopen in Container"
  exit 1
fi

ruby_version="$(extract_mise_version ruby)"
node_version="$(extract_mise_version node)"
yarn_version="$(extract_mise_version yarn)"

if [ -z "${ruby_version}" ] || [ -z "${node_version}" ] || [ -z "${yarn_version}" ]; then
  echo "ERROR: Could not read ruby/node/yarn versions from mise.toml"
  exit 1
fi

echo "Installing platforms"
if ! mise self-update -y; then
  echo "WARN: mise self-update failed; continuing with the existing mise version."
fi
mise install "ruby@${ruby_version}" "node@${node_version}" "yarn@${yarn_version}"

echo "Installing gems"
# Ensure the exact bundler version required by Gemfile.lock is installed.
# When BUNDLED WITH is present, bundler auto-upgrades itself at runtime to that
# version — but that auto-install can produce a partial gem (missing rubygems_ext)
# if the devmise volume has stale state. Installing explicitly here is reliable.
bundler_version="$(extract_bundler_version)"
if [[ ! "${bundler_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-.+][0-9A-Za-z.-]+)?$ ]]; then
  echo "ERROR: Could not parse a valid bundler version from Gemfile.lock (got '${bundler_version}')."
  exit 1
fi
mise exec -- gem install bundler -v "${bundler_version}" --no-document
mise exec -- bundle install --quiet

echo "Installing packages using yarn"
mise exec -- yarn install

if [ "$#" -gt 0 ]; then
  "$@"
fi
