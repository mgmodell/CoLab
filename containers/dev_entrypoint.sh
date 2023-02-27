#!/bin/bash

echo "Arguments: $@"

dir="$HOME/src/app/"

#Set up the version managers
echo "Setting the current working directory"
. $HOME/.asdf/asdf.sh
asdf reshim

cd $dir
echo "Installing platforms"
asdf plugin update --all
asdf install
# echo "Installing gems"
# bundle install --quiet
# echo "Installing yarn packages"
# yarn install --silent

$@
