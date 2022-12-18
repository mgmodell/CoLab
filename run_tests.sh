#!/bin/bash

# MOVE THIS PULL AND RISK STAGNATION
echo "Setting the current working directory"
. $HOME/.asdf/asdf.sh
cd $HOME/src/app
git pull
asdf reshim

print_help ( ) {
  echo "RunCukes: Script to launch automated tests"
  echo "Valid options:"
  echo " -s             Show the failures from previous run only"
  echo "                (Do not run any tests.)"
  echo " -b [branch]    Switch to [branch] and terminate"
  echo " -c             Initialise the database and terminate"
  echo " -l             Clear out the log files"
  echo " -n             Wipe previous runs"
  echo "       Run-specific options:"
  echo " -d [driver]    Set the browser driver for this run"
  echo " -f [features]  Specify specific features to run"
  echo " -r             Rerun previous failed tests with latest"
  echo "                code (default)"
  echo " -t             Run a shell"
  echo " -e             Exit before running tests"
  echo " -h             Show this help and terminate"

  exit 0;

}

TERMINAL=false
while getopts "h" opt; do
  case $opt in
    t) #Invalid option
      TERMINAL=true
      ;;
    h|\?) #Invalid option
      print_help
      exit 0;
      ;;
  esac
done

if [ "$TERMINAL" = true] then
  docker-compose run --rm app $@
else
  docker-compose run --rm -d app $@
fi
