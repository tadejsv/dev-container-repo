# 🐋🔥 ML Docker containers 

[![Python](https://img.shields.io/docker/automated/tadejsv/ml-docker?style=for-the-badge)](https://hub.docker.com/r/tadejsv/ml-docker)

These are [easy to use](#quickstart) Ubuntu Docker images that come with [everything you need](#specs-and-versions) for machine learning - full GPU/CUDA support included! And if there's a package you're missing, it's very easy to [extend the container](#extending-the-container).


1. [Installation](#installation)
2. [Quickstart](#quickstart)
    - [Start Jupyter Lab/Notebook](#start-jupyter-lab/notebook)
    - [Run a script](#run-a-script)
4. [Specs and versions](#spec-and-versions)
5. [Extending the container](#extending-the-container)
    - [Creating a new image](#creating-a-new-image)
    - [Installing with pip](#installing-with-pip)


## Installation

First, make sure you have [NVIDIA drivers](https://www.nvidia.com/Download/index.aspx), [docker](https://docs.docker.com/engine/install/) and [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker) installed. The images use CUDA 10.1 (`tf`) or 10.2 (`pytorch` and `boost`), so try to select the most current drivers.

And that's it! No need to install CUDA or anything else, the images takes care of that. Also, no need to download the image before running, `docker run` will download it, if it doesn't already exist. You only need to use `docker pull` if you want to update the images.

## Quickstart

There are two ways to start the container (let's assume it's the `pytorch` container), depending on what you want to do:

1. [Start Jupyter Lab/Notebook](#start-jupyter-lab/notebook)
2. [Run a script](#run-a-script)

### Start Jupyter Lab/Notebook

To start the container, `cd` into the directory from which you want to work and execute the command

```
docker run --rm -d --name <NAME> --gpus all --ipc="host" -p 8888:8888 -v "$(pwd)":/root/project tadejsv/ml-docker:pytorch
```
This command will make Jupyter Lab availible on your machine at [https://localhost:8888](https://localhost:8888).

Let's break down what the options here do:
- `--rm` removes the container after it exits. If you want to inspect container's logs after it exits, remove this part.
- `-d` makes it run in the background. 
- `--name <NAME>` sets the name of the container. Then you can stop it with `docker stop <NAME>`, without having to fetch the id.
- `--gpus all` gives the container access to the GPUs of your machine.
- `--ipc="host"` is needed for `pytorch`, because Docker limits shared memory for processes to only 64MB by default -- and if you will be loading/processing images with multiple workers, this will not be enough. Alternatively, you could adjust `shm-size`.
- `-p 8888:8888` binds the container's 8888 port (where Jupyter will be listening) to port 8888 on your machine. 
- `-v "$(pwd)":/root/project` creates a bind mount from the currend directory on your machine to the container's working directory. This gives the container the ability to read and write in the current directory on your system.  

Since the container will be running in the background, you can use `docker logs` to view the output while it is running. If you want use bash inside the container it's probably easiest to open a terminal in Jupyter Lab, but you could use `docker exec` as well.

You can specify [command line options](https://jupyter-notebook.readthedocs.io/en/stable/config.html) to change some default settings -- for example, to change the passowrd.

#### Jupyter Notebook instead of Jupyter Lab

If you wish to start Jupyter Notebook instead of Jupyter Lab (which you need to do this, for example, if you want the Catboost widgets to work), add `notebook` as the first argument (+ command line options).

#### Jupyter password

The default password is `getrekt`. You can create a new password following the steps [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password), and then change it by passing a command line argument

```
--NotebookApp.password='<NEW_PASSWORD>'
```
to the [default command](#start-jupyter-lab/notebook).

### Run a script

If you want to run a `.py` or `.sh` script, you would add

```
my_script.py arg1 arg2
```
to the [default command](#start-jupyter-lab/notebook). This will simply start running your script, and will not start Jupyter Lab.

## Specs and versions

There are three different versions of the container:
- [`pytorch`]() comes with Pytorch, as well as torchvision, ignite and Pytorch Lightning installed.
- [`tf`]() comes with Tensorflow (v2) installed.
- [`boost`]() comes with the 3 main gradient boosting libraries installed (Catboost, LGBM and XGboost).

All 3 containers already come with CUDA toolkit libraries preinstalled. They all use [conda](https://docs.conda.io/en/latest/conda.html) (miniconda) for python distribution and package management, and come with the following packages installed:
- numpy and pandas
- scipy
- scikit-learn
- matplotlib and seaborn
- Jupyter lab (with widgets enabled) + TOC extension



## Extending the image

### Creating a new image

This container contains only the "base" packages. If you need to install other packages, you can do so easily by creating a new image based off this one. For example, if you need to install the Albumenations package, your dockerfile would look like

```docker
FROM tadejsv/ml-docker:pytorch

RUN conda install albumenations && \
    conda clean -yaf
```

You can then build your image and upload it to DockerHub. You would then run the container exactly like this one, just replacing `tadejsv/ml-docker:pytorch` with the name of your image!

### Installing with pip



## TODO

- Create a TensorBoard image and intergrate with Docker compose
- Make sure TF works properly (including profiling etc)
- Make the container not run as root
- Split into many images and use multi-stage build to patch together (for Pytorch, TF, Catboost, LGBM...)
- Improve security?
- Remove pytorch-nightly and dev version of TL when torch hits 1.6.0 and TL 0.8.0.
- Up the CUDA version to 10.2 once TF starts supporting it.