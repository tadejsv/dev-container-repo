#!/bin/bash

# Check arguments
ALLOWED_TAGS=( 'pytorch' 'tensorflow' 'boost' )

for arg in $@
do
    if [[ ! " ${ALLOWED_TAGS[@]} " =~ " ${arg} " ]]; then
       echo "Argument $arg is not on the list of allowed tags."
       exit 1
    fi
done

# Check that we can create shortcuts
if [[ ! $PATH =~ '/usr/local/bin' ]]; then
    echo "/usr/local/bin is not on PATH, can not create shortcuts."
    exit 1
fi

# Get github repository
echo -e "\n***********************************************"
echo "Cloning tadejsv/ml-docker repository"
echo -e "***********************************************\n"

git clone --depth=1 git@github.com:tadejsv/ml-docker.git

# cd into the repository
cd ml-docker

# Build base image
echo -e "\n***********************************************"
echo "Begining eda (base) image build"
echo -e "***********************************************\n"
sleep 1

docker build --build-arg USERNAME="$(whoami)" --build-arg UID="$(id -u)" -t ml-dev-eda -f Dockerfile.eda .

# Build other images, if any
for arg in $@
do
    echo -e "\n***********************************************"
    echo "Begining $arg image build"
    echo -e "***********************************************\n"
    sleep 1

    docker build -t ml-dev-$arg -f Dockerfile.$arg .
done

# Create shortcuts
echo -e "\n***********************************************"
echo "Creating shortcuts"
echo -e "***********************************************\n"
sleep 1

echo 'docker run --init --rm -d --name alba --gpus all --ipc=host -p 8888:8888 -v "$(pwd)":/home/"$(whoami)"/workspace ml-dev-eda' | sudo tee /usr/local/bin/ml-dev-eda
echo 'docker run --init --rm -d --name alba --ipc=host -p 8888:8888 -v "$(pwd)":/home/"$(whoami)"/workspace ml-dev-eda' | sudo tee /usr/local/bin/ml-dev-eda-cpu

sudo chmod +x /usr/local/bin/ml-dev-eda /usr/local/bin/ml-dev-eda-cpu

for arg in $@
do
    echo 'docker run --init --rm -d --name alba --gpus all --ipc=host -p 8888:8888 -v "$(pwd)":/home/"$(whoami)"/workspace ml-dev-'$arg | sudo tee /usr/local/bin/ml-dev-$arg
    echo 'docker run --init --rm -d --name alba --ipc=host -p 8888:8888 -v "$(pwd)":/home/"$(whoami)"/workspace ml-dev-'$arg | sudo tee /usr/local/bin/ml-dev-$arg-cpu

    sudo chmod +x /usr/local/bin/ml-dev-$arg /usr/local/bin/ml-dev-$arg-cpu
done

# Clean up
echo -e "\n***********************************************"
echo "Cleaning up"
echo -e "***********************************************\n"

cd ..
rm -rf ml-docker

echo -e "\n✨ Done! ✨"