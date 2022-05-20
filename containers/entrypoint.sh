#!/bin/bash

#Set up the known hosts
ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts

dir="$HOME/src/app/"

if [[ $(find ${dir} -type f  | wc -l) -lt 1 ]]; then
  git clone git@bitbucket.org:_performance/colab.git $dir
  cd $dir
  git checkout ux
fi

$HOME/src/app/run_cukes.sh "$@"

