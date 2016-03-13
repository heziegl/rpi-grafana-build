#! /bin/bash

#sudo docker build -t rpi-grafana-build --rm=true .

# grafana git tag to build
TAG=v2.6.0

# host dir to copy result to
DIST_DIR=dist-$TAG
IMAGE_NAME=rpi-grafana-build:$TAG

mkdir -p $DIST_DIR

# build grafana
sudo docker build --build-arg GRAFANA_TAG=$TAG -t $IMAGE_NAME .

# copy dist from container to docker host
echo copying results to $DIST_DIR ...
sudo docker run --rm=true -v $(pwd)/$DIST_DIR:/dist $IMAGE_NAME

