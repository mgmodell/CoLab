#/bin/bash

ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts
git pull
asdf reshim

if [[ $OSTYPE == 'darwin'* ]]; then
  echo 'building for arm'
else
  echo 'building for x86'
fi

while getopts "hsnb:f:" opt; do
  case $opt in
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
      # rm rerun.txt
      ;;
    h|\?) #Invalid option
      echo "RunCukes: Script to launch automated tests"
      echo "Valid options:"
      echo " -s             Show the failures from previous run"
      echo " -b [branch]    Switch to [branch]"
      echo " -f [features]  Specify specific features"
      echo " -n             Start fresh"

      exit 1;;
  esac
done

DRIVER=docker
RAILS_ENV=docker

asdf install
bundle install
yarn install

rails cucumber:rerun 
