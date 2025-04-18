#!/bin/bash

echo "Arguments: $@"

dir="$HOME/src/app/"

#Set up the version managers
echo "Setting the current working directory"
mise reshim
mise self-update
mise cache clean

cd $dir
echo "Installing platforms"
mise install
echo "Installing gems"
bundle install --quiet
echo "Installing yarn packages"
yarn install --silent

$@
