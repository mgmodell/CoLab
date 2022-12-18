#!/bin/bash

# MOVE THIS PULL AND RISK STAGNATION
echo "Setting the current working directory"

print_help ( ) {
  echo "run_tests.sh: Script to launch containerized automated tests"
  echo "Valid options:"
  echo " -s             Show the failures from previous run only"
  echo "                (Do not run any tests.)"
  echo " -b [branch]    Switch to [branch] and terminate"
  echo " -c             Initialise the database and terminate"
  echo " -l             Clear out the log files"
  echo " -n             Wipe previous runs"
  echo " -o		Show output (if running)"
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

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

RUN_TERM=false
while getopts "sob:clndfrteh" opt; do
  case $opt in
    t) # Open up a terminal
      RUN_TERM=true
      ;;
    o)
      OUTPUT_HASH=`docker ps | grep colab_tester | awk '{print $1;}'`
      docker logs -f $OUTPUT_HASH
      exit 0;
      ;;
    h|\?) #Invalid option
      print_help
      exit 0;
      ;;
  esac
done

pushd containers/test_env/
if [ "$RUN_TERM" = true ]; then
  docker-compose run --rm --entrypoint='' app /bin/bash
  # docker-compose run --rm app $@
else
  docker-compose run --rm -d app $@
fi
popd
