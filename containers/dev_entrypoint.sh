#!/bin/bash

echo "Arguments: $@"

dir="$HOME/src/app/"

#Set up the version managers
echo "Setting the current working directory"

cd $dir

# Add mise shims and bin to PATH so managed tools (bundle, aube, etc.) are
# accessible in this non-interactive bash script.  `mise activate bash` relies
# on PROMPT_COMMAND, which is never fired in non-interactive scripts, so we
# set PATH directly instead.
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

echo "Installing platforms"
mise self-update -y
mise install
echo "Installing gems"
# Ensure the exact bundler version required by Gemfile.lock is installed.
# When BUNDLED WITH is present, bundler auto-upgrades itself at runtime to that
# version — but that auto-install can produce a partial gem (missing rubygems_ext)
# if the devmise volume has stale state.  Installing explicitly here is reliable.
BUNDLER_VERSION=$(grep -A1 "BUNDLED WITH" Gemfile.lock 2>/dev/null | tail -1 | tr -d ' ')
if [ -n "$BUNDLER_VERSION" ]; then
  gem install bundler -v "$BUNDLER_VERSION" --no-document
fi
bundle install --quiet
echo "Installing packages using aube"
aube install

$@
