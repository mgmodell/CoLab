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
  echo " -o             Show output (if running)"
  echo " -x             Shut down support processes and terminate"
  echo "       Run-specific options:"
  echo " -d [driver]    Set the browser driver for this run"
  echo " -f [features]  Specify specific features to run"
  echo " -r             Rerun previous failed tests with latest"
  echo "                code (recommended)"
  echo " -t             Run a shell"
  echo " -e             Exit before running tests"
  echo " -h             Show this help and terminate"

  exit 0;

}

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

SHOW_FAILS=false
RUN_TERM=false
SHOW_OUTPUT=false
DROP_SUPPORT=false
RUN=false

# Set up a variable for the container
export HOSTNAME=$(hostname -s)

while getopts "soxb:clndf:rteh" opt; do
  case $opt in
    x) # Open up a terminal
      RUN=false
      DROP_SUPPORT=true
      ;;
    s) # Show failures
      RUN=false
      SHOW_FAILS=true
      ;;
    t) # Open up a terminal
      RUN=false
      RUN_TERM=true
      ;;
    r|c|b|n|l|f|d)
      RUN=true
      ;;
    o)
      SHOW_OUTPUT=true
      ;;
    h|\?) #Invalid option
      print_help
      exit 0;
      ;;
  esac
done

pushd containers/test_env/
if [ "$RUN_TERM" = true ]; then
  docker compose run --rm --entrypoint='' app /bin/bash

elif [ "$SHOW_FAILS" = true ]; then
  echo "Show previous run failures"
  docker compose run --rm --entrypoint='' app /bin/cat /home/colab/src/app/rerun.txt
  echo -e "\nEnd failure listing\n"

elif [ "$DROP_SUPPORT" = true ]; then
  docker compose down 

else
  if [ "$RUN" = true ]; then
    DB_COUNT=`mysqlshow -h db -u test -ptest --protocol=TCP --port=31337 | grep colab_test_ | wc -l`
    if [ $(($DB_COUNT)) = 0 ]; then
      echo "Creating the DB"
        docker compose run --rm app -c
      echo "Created the DB"
    fi
    NUM_TESTERS=`docker ps | grep colab_testers | wc -l`
    if [ $NUM_TESTERS -lt 1 ]; then 
      docker compose run --rm -d app $@
    fi
  fi
  if [ "$SHOW_OUTPUT" = true ]; then
      OUTPUT_HASH=`docker ps | grep colab_tester | awk '{print $1;}'`
      docker logs -f $OUTPUT_HASH
  fi
fi
popd
