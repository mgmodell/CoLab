#!/bin/bash

dir="$HOME/src/app/"

if [[ $(find ${dir} -type f  | wc -l) -lt 1 ]]; then
  git clone https://github.com/mgmodell/CoLab.git $dir
  git config --global pull.rebase false
  git config --global push.autoSetupRemote true
  git config --global branch.autoSetupMerge simple
fi

cd $dir

# Make sure we're working with the latest
if grep -q bitbucket .git/config; then
  echo "Migrate from bitbucket"
  git remote rm origin
  git remote add origin https://github.com/mgmodell/CoLab.git
  git pull --all
  git push --mirror

else
#  for branch in $(git branch --all | grep '^\s*remotes' | grep -E --invert-match '(:?HEAD|master)$'); do
#    git branch --track "${branch##*/}" "$branch"
#  done

  git pull --all

fi

$HOME/src/app/containers/test_env/run_cukes.sh "$@"

