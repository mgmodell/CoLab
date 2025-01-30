#!/bin/bash

echo 'building db'
docker build -f ./containers/agnostic/db/Dockerfile -t colab_db .
echo 'building app tester'
docker build -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
echo 'building app dev'
docker build -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
echo 'building browser'
docker build -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
pushd ./containers/agnostic/moodle
echo 'building moodle'
docker build -f ./Dockerfile -t colab_moodle .
popd

