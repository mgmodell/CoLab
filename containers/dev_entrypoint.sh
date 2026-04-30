#!/bin/bash

echo "Arguments: $@"

dir="$HOME/src/app/"

#Set up the version managers
echo "Setting the current working directory"

cd $dir

# Activate mise so its managed tools (bundler, aube, etc.) are on PATH.
# This is required because the entrypoint is invoked via `bash` (not zsh),
# so .zshrc (which contains `eval "$(mise activate zsh)"`) is never sourced.
eval "$($HOME/.local/bin/mise activate bash)"

echo "Installing platforms"
mise self-update -y
mise install
echo "Installing gems"
bundle install --quiet
echo "Installing packages using aube"
aube install --silent

$@
