#!/bin/bash

if [[ $OSTYPE == 'darwin'* ]]; then
  echo 'building for arm'
  docker build -f ./containers/arm/db/Dockerfile -t colab_db .
  docker build -f ./containers/arm/tester_server/Dockerfile -t colab_tester .
  docker build -f ./containers/arm/dev_server/Dockerfile -t colab_dev_server .
  docker build -f ./containers/arm/browser/Dockerfile -t colab_browser .
else
  echo 'building for x86'
  docker build -f ./containers/x86/db/Dockerfile -t colab_db .
  docker build -f ./containers/x86/tester_server/Dockerfile -t colab_tester .
  docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -f ./containers/x86/dev_server/Dockerfile -t colab_dev_server .
  docker build -f ./containers/x86/browser/Dockerfile -t colab_browser .
fi
pushd ./containers/agnostic/moodle
docker build -f ./Dockerfile -t colab_moodle . 
popd

