#!/bin/bash

# TODO: Add 'eda' to args, for more consistent looping
# Conditional add to .bashrc function

# Check arguments
ALLOWED_TAGS=( 'pytorch' 'tensorflow' 'boost' )
BUILD_TAGS=( 'eda' )

for arg in $@
do
    if [[ ! " ${ALLOWED_TAGS[@]} " =~ " $arg " ]]; then
       echo "Argument $arg is not on the list of allowed tags."
       exit 1
    else
        BUILD_TAGS+=( $arg )
    fi
done

# Check that we can create shortcuts
if [ "$SHELL" = "/bin/bash" ]; then
    SHFILE=~/.bashrc
elif [ "$SHELL" = "/bin/zsh" ]; then
    SHFILE=~/.zshrc
else
    echo "Neither ~/.bashrc or ~/.zshrc found, can not create aliases."
    exit 1
fi

# Get user name
UNAME=$(whoami)

# Get github repository
echo -e "\n***********************************************"
echo "Cloning tadejsv/ml-docker repository"
echo -e "***********************************************\n"

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
    docker build --build-arg USERNAME=$UNAME --build-arg UID="$(id -u)" -t ml-dev-cuda-base:$UNAME -f Dockerfile_cuda_dev.base .
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

# Create shortcuts
echo -e "\n***********************************************"
echo "Creating shortcuts"
echo -e "***********************************************\n"
sleep 1

DOCKER_COM="docker run --init --rm -d --name alba --gpus all --ipc=host -p 8888:8888 -v \"\$(pwd)\":/home/ws "
DOCKER_COM_CPU="docker run --init --rm -d --name alba --ipc=host -p 8888:8888 -v \"\$(pwd)\":/home/ws "

function logifnew {
    echo $1
    if grep -Fxq "$1" $SHFILE
    then
        return 0
    else
        echo "$1" >> $SHFILE
    fi
}

echo -e '\n'
logifnew '# Docker ML development images aliases'

for arg in ${BUILD_TAGS[@]}
do
    logifnew "alias ml-dev-$arg='$DOCKER_COM ml-dev-$arg:$UNAME'"
    logifnew "alias ml-dev-$arg-cpu='$DOCKER_COM_CPU ml-dev-$arg:$UNAME'"
done

# Clean up
echo -e "\n***********************************************"
echo "Cleaning up"
echo -e "***********************************************\n"

cd ..
rm -rf ml-docker

echo -e "✨ Done! ✨"