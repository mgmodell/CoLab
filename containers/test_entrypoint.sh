#!/bin/bash

dir="$HOME/src/app/"

if [ "$(id -u)" -eq 0 ]; then
  dir="/home/colab/src/app/"
  chown -R colab:colab "${dir}reports" || exit 1
  exec su colab -s /bin/bash -c 'exec "$@"' -- bash "$0" "$@"
fi

if [[ $(find "$dir" -path "${dir%/}/reports" -prune -o -type f -print | wc -l) -lt 1 ]]; then
  clone_dir=$(mktemp -d "$HOME/src/colab-clone.XXXXXX") || exit 1
  if ! git clone https://github.com/mgmodell/CoLab.git "$clone_dir" ||
     ! cp -a "$clone_dir/." "$dir"; then
    rm -rf "$clone_dir"
    exit 1
  fi
  rm -rf "$clone_dir"
fi

cd $dir

git checkout .
git pull --all

$HOME/src/app/containers/test_env/run_cukes.sh "$@"
