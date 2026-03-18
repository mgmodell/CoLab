#!/bin/bash

dir="$HOME/src/app/"

if [[ $(find ${dir} -type f  | wc -l) -lt 1 ]]; then
  git clone https://github.com/mgmodell/CoLab.git $dir
fi

cd $dir

git checkout .
git pull --all

$HOME/src/app/containers/test_env/run_cukes.sh "$@"

