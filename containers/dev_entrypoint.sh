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
bundle install --quiet
echo "Installing packages using aube"
aube install --silent

$@
