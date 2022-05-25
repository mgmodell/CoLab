#!/bin/bash

# ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts
echo "Setting the current working directory"
. $HOME/.asdf/asdf.sh

cd $HOME/src/app

git pull
asdf reshim

DRIVER=docker

while getopts "hsnb:f:d:" opt; do
  case $opt in
    d)
      echo "Setting driver to $OPTARG" >&2
      DRIVER=$OPTARG
      ;;
    s)
      echo "Showing Rerun File" >&2
      cat rerun.txt
      exit 0;;
    b)
      echo "Checking out branch $OPTARG" >&2
      git checkout $OPTARG
      ;;
    f)
      echo "Features Specified $OPTARG" >&2
      FEATURE=$OPTARG
      ;;
    n)
      echo "Removing Rerun File" >&2
      rm rerun.txt
      exit 0;;
    r)
      echo "Rerun recent failures" >&2
      # NOOP
      ;;
    h|\?) #Invalid option
      echo "RunCukes: Script to launch automated tests"
      echo "Valid options:"
      echo " -s             Show the failures from previous run"
      echo " -b [branch]    Switch to [branch]"
      echo " -f [features]  Specify specific features"
      echo " -n             Wipe previous runs"
      echo " -r             Rerun previous failed tests with latest code"

      exit 0;;
  esac
done

RAILS_ENV=docker
CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec
#RAILS_MASTER_KEY=4e2027b76f8638d77d05a617c748d877

asdf install
bundle install
yarn install

echo "TEST Execution: rails cucumber:rerun"
rails cucumber:rerun RAILS_ENV=$RAILS_ENV
