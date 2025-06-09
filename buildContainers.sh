#!/bin/bash

echo 'building db'
podman-build -f ./containers/agnostic/db/Dockerfile -t colab_db .
echo 'building app tester'
podman build -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
echo 'building app dev'
podman-build -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
echo 'building browser'
podman-build -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
pushd ./containers/agnostic/moodle
echo 'building moodle'
podman-build -f ./Dockerfile -t colab_moodle .
popd

