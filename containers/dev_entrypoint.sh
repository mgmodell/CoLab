#!/bin/bash

echo "Arguments: $@"

dir="$HOME/src/app/"

#Set up the version managers
echo "Setting the current working directory"

cd $dir
echo "Installing platforms"
mise install
echo "Installing gems"
bundle install --quiet
echo "Installing yarn packages"
yarn install --silent

$@
