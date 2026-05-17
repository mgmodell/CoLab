#!/bin/bash

# This script builds the containers for the Colab project using Podman.
# --format docker produces Docker-compatible image manifests, which is required
# for the VS Code Dev Containers extension to start the dev container correctly.
print_help ( ) {
    echo "buildContainers: Script to build Colab containers using Podman"
    echo "Valid options:"
    echo " -n             Build containers without relying upon the cached layers"
    echo " -d             Build dev containers only"
    echo " -t             Build test containers only"
    echo " -b             Build both sets of containers (default)"
    echo ""
    echo " -h             Show this help and terminate"
    exit 0;
}

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

# Function to test the result of the build command
# Arguments:
#   $1 - Exit status of the build command
#   $2 - Name of the container being built
# If the build is successful it prints a success message.
# If it fails, it prints an error message and exits with status 1.
test_result ( ) {
    if [[ $1 -eq 0 ]]; then
      echo -e "\tbuild $2: succeeded"
    else
      echo -e "\n\t*****\n\tbuilding $2 failed\n\t*****\n"
      exit 1
    fi

}

# --format docker is always included for Dev Containers / Docker-API compatibility.
BUILD_OPTS="--format docker"
DEV_ONLY=false
TEST_ONLY=false
while getopts "nbhdt" opt; do
  case $opt in
    n)
      echo "Building containers without cache"
      BUILD_OPTS="$BUILD_OPTS --no-cache"
      ;;
    b)
      # -b is the default (build both dev and test containers); accepted for clarity.
      ;;
    h)
      print_help
      ;;
    d)
      DEV_ONLY=true
      ;;
    t)
      TEST_ONLY=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      ;;
  esac
done

echo "Configuring .devcontainer/devcontainer.json compose overrides"
bash ./configureDevcontainer.sh
configure_exit_code=$?
if [ "${configure_exit_code}" -ne 0 ]; then
  echo "Failed to configure .devcontainer/devcontainer.json compose overrides." >&2
  exit 1
fi

echo -e '\t*****\n\tbuilding db'
podman build $BUILD_OPTS -f ./containers/agnostic/db/Dockerfile -t colab_db .
test_result $? 'colab_db'

if [ "$DEV_ONLY" != true ]; then
    echo -e '\n\t*****\n\tbuilding app tester'
    podman build $BUILD_OPTS -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
    test_result $? 'colab_tester'
fi

if [ "$TEST_ONLY" != true ]; then
    echo -e '\n\t*****\n\tbuilding app dev'
    podman build $BUILD_OPTS -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
    test_result $? 'colab_dev_server'

    echo -e '\n\t*****\n\tbuilding browser'
    podman build $BUILD_OPTS -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
    test_result $? 'colab_browser'

    echo -e '\n\t*****\n\tbuilding moodle'
    podman build $BUILD_OPTS -f ./containers/agnostic/moodle/Dockerfile -t colab_moodle .
    test_result $? 'colab_moodle'
fi
