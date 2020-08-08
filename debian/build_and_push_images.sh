#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as sudo ./build_and_push_images.sh"
   exit 1
fi

apt-get -qq --yes --no-install-recommends install whois debootstrap apt-cacher-ng 2>/dev/null

registry='192.168.1.1'
proxy_url='http://192.168.1.1:3142'
linux='debian'
release='bullseye'
variant='slim'
version='latest'
origin=$linux:$release-$variant
base=$release/base:$version

docker build -t $registry/$release/base:$version 00-base/ --build-arg IMAGE=$origin --build-arg http_proxy=$proxy_url --build-arg https_proxy=$proxy_url
docker push $registry/$release/base:$version

docker build -t $registry/$release/disk-wipe:$version 01-disk-wipe/ --build-arg REGISTRY=$registry --build-arg IMAGE=$base
docker push $registry/$release/disk-wipe:$version

docker build -t $registry/$release/disk-partition:$version 02-disk-partition/ --build-arg REGISTRY=$registry --build-arg IMAGE=$base
docker push $registry/$release/disk-partition:$version

docker build -t $registry/$release/install-root-fs:$version 03-install-root-fs/ --build-arg REGISTRY=$registry --build-arg IMAGE=$base
docker push $registry/$release/install-root-fs:$version

docker build -t $registry/$release/cloud-init:$version 04-cloud-init/ --build-arg REGISTRY=$registry --build-arg IMAGE=$base
docker push $registry/$release/cloud-init:$version
