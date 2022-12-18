#!/bin/bash

#Set up the known hosts
ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts

dir="$HOME/src/app/"

if [[ $(find ${dir} -type f  | wc -l) -lt 1 ]]; then
  git clone git@bitbucket.org:_performance/colab.git $dir
fi

cd $dir
# Make sure we're working with the latest
git pull

$HOME/src/app/run_cukes.sh "$@"

