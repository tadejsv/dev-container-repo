# 🐋 ML Docker containers

These are [easy to use](#quickstart) Ubuntu Docker images that come with [everything you need](#specs-and-versions) for machine learning! And if there's a package you're missing, it's very easy to [extend the container](#extending-the-container).


1. [Installation](#installation)
2. [Quickstart](#quickstart)
    - [Start Jupyter Lab](#start-jupyter-lab)
    - [Run a script](#run-a-script)
4. [Specs and versions](#spec-and-versions)
5. [Extending the container](#extending-the-container)
    - [Installing with pip](#installing-with-pip)


## Installation

First, make sure you have [docker](https://docs.docker.com/engine/install/) and [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker) installed. [WORDS ABOUT CUDA COMPATIBILITY]

## Quickstart

There are two ways to start the container (let's assume it's the `pytorch` container), depending on what you want to do:

1. [Start Jupyter Lab](#start-jupyter-lab)
2. [Run a script](#run-a-script)

### Start Jupyter Lab

To start the container all you need to do is

```
docker run --rm -d --name <NAME> --gpus all -p 8888:8888 -v <SOURCE>:/root/project tadejsv/ml-docker:pytorch
```

Here `SOURCE` is the project directory on your machine. This will make Jupyter Lab availible on port `https://localhost:8888` on your machine.

You can specify [command line options](https://jupyter-notebook.readthedocs.io/en/stable/config.html) to change some default settings -- for example, to change the passowrd.

#### Change Jupyter password

The default password is `getrekt`. You can create a new password following the steps [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password), and you can change it with a command line argument:

```
docker run --rm -d --name <NAME> --gpus all -p 8888:8888 -v <SOURCE>:/home/pyuser/project tadejsv/ml-docker:pytorch --NotebookApp.password='<NEW_PASSWORD>'
```

### Run a script

If you want to run a `.py` or `.sh` script, you would type

```
docker run --rm -d --name <NAME> --gpus all -p 8888:8888 -v <SOURCE>:/home/pyuser/project tadejsv/ml-docker:pytorch my_script.py arg1 arg2
```

You might also want to add ``--rm -d --name <NAME>`` as arguments.

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



## Extending the container

This container contains only the "base" packages. If you need to install other packages, you can do so easily by creating a new image based off this one. For example, if you need to install the Albumenations package, your dockerfile would look like

```docker
FROM tadejsv/ml-docker:pytorch

RUN conda install albumenations && \
    conda clean -yaf
```

You can then build your image and upload it to DockerHub. You would then run the container exactly like this one, just replacing `tadejsv/ml-docker:pytorch` with the name of your image!

### Simply installing with pip



## TODO

- Create a TensorBoard image and intergrate with Docker compose
- Make sure TF works properly (including profiling etc)
- Make the container not run as root
- Split into many images and use multi-stage build to patch together (for Pytorch, TF, Catboost, LGBM...)
- Improve security?
- Remove pytorch-nightly and dev version of TL when torch hits 1.6.0 and TL 0.8.0.
- Up the CUDA version to 10.2 once TF starts supporting it.