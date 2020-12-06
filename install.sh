#!/bin/bash

# TODO: Add 'eda' to args, for more consistent looping
# Conditional add to .bashrc function

# Check arguments
ALLOWED_TAGS=( 'tensorflow' 'boost' )

for arg in $@
do
    if [[ ! " ${ALLOWED_TAGS[@]} " =~ " $arg " ]]; then
       echo "Argument $arg is not on the list of allowed tags."
       exit 1
    else
        BUILD_TAGS+=( $arg )
    fi
done

# Get user name
UNAME=$(whoami)

# Get github repository
echo -e "\n***********************************************"
echo "Cloning tadejsv/ml-docker repository"
echo -e "***********************************************\n"

cd /tmp
git clone --depth=1 git@github.com:tadejsv/ml-docker.git

# cd into the repository
cd ml-docker

# Build base image
echo -e "\n***********************************************"
echo "Begining base image build"
echo -e "***********************************************\n"
sleep 1

docker build --build-arg USERNAME=$UNAME --build-arg UID="$(id -u)" -t ml-dev-base:$UNAME -f Dockerfile.base .

if [[ " ${BUILD_TAGS[@]} " =~ " boost " ]]; then
    docker build --build-arg CUDA_LEVEL=devel --build-arg USERNAME=$UNAME --build-arg UID="$(id -u)" -t ml-dev-cuda:$UNAME -f Dockerfile.base .
fi

# Build other images, if any
for arg in ${BUILD_TAGS[@]}
do
    echo -e "\n***********************************************"
    echo "Begining $arg image build"
    echo -e "***********************************************\n"
    sleep 1

    docker build --build-arg USERNAME=$UNAME --build-arg UID="$(id -u)" -t ml-dev-$arg:$UNAME -f Dockerfile.$arg .
done

# Clean up
echo -e "\n***********************************************"
echo "Cleaning up"
echo -e "***********************************************\n"

cd ..
rm -rf ml-docker

echo -e "✨ Done! ✨"