#! /bin/bash

set -e

# grafana git tag to build, or "master" to build master
#VERSION=master-$(date +"%Y%m%d_%H%M")
VERSION=3.0.4

# host dir to copy result to
DIST_DIR=dist-$VERSION
IMAGE_NAME=heziegl/rpi-grafana-build:$VERSION

mkdir -p $DIST_DIR

# build grafana
echo building docker image ...
sudo docker build --build-arg GRAFANA_VERSION=$VERSION -t $IMAGE_NAME .

# copy dist from container to docker host
echo copying results to $DIST_DIR ...
sudo docker run --rm=true -v $(pwd)/$DIST_DIR:/dist $IMAGE_NAME

