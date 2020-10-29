# 🐋🔥 ML Docker containers

These are [easy to use](#quickstart) Ubuntu Docker images that come with [everything you need](#specs-and-versions) for machine learning - full GPU (CUDA) support included! And if there's a package you're missing, it's very easy to [extend the container](#extending-the-container).

1. [Quickstart](#quickstart)
    - [Installation](#installation)
    - [Running the container](#running-the-container)
2. [Configuration](#configuration)
    - [Docker options](#docker-options)
    - [Jupyter options](#Jupyter-options)
3. [Specs and versions](#specs-and-versions)
4. [Extending the image](#extending-the-image)
    - [Creating a new image](#creating-a-new-image)
    - [Installing with pip](#installing-with-pip)

## Quickstart

First, Make sure you have [docker](https://docs.docker.com/engine/install/) installed. If you plan to use your GPU, you also need [NVIDIA drivers](https://www.nvidia.com/Download/index.aspx) (>= 440.33) and [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker).

### Installation

You can create the images on your computer and the shortcuts to use them (see below) with the following command

```bash
wget -qO- https://raw.githubusercontent.com/tadejsv/ml-docker/master/install.sh | bash /dev/stdin ARGS
```

Here `ARGS` can be either empty of any number of arguments from `pytorch`, `tensorflow` or `boost`. This command will do the following (as you can see if you check the `install.sh` script):

- Create `ml-dev-eda` and `ml-dev-TAG` docker images (for each `TAG` in `ARGS`)
- Create `ml-dev-eda` and `ml-dev-TAG` commands (shortcuts) in `/usr/local/bin/`

See [Docker options](#docker-options) for more details on this.

### Running the container

To run the container, follow these steps:

- **Step 1**: `cd` into the directory from which you want to work
- **Step 2**: Execute this command

    ``` bash
    ml-dev-pytorch
    ```

    >  If you run this on a CPU-only machine, use `ml-dev-pytorch-cpu`

    In this example we are starting a Pytorch container, but you can change that by changing `ml-dev-pytorch` to something else (e.g. `ml-dev-tensorflow`).

    By default this will start a Jupyter Lab with `jupyter lab`, but you can change this by passing a different command.

- **Step 3**: When you want to stop the container, execute

    ``` bash
    docker stop alba
    ````

## Configuration

### Docker options

#### Installation

The installation script creates the images using

```bash
docker build --build-arg USERNAME="$(whoami)" --build-arg UID="$(id -u)" -t ml-dev-TAG -f Dockerfile.TAG .
```

This creates a Docker image where the user has your username and user id. This is very helpful, as when the docker container will write to your local directories, there won't be any permission issues (if you have the permission so does the docker container and vice versa).

#### Running the container

The default command executed by `ml-dev-TAG` is

```bash
docker run --init --rm -d --name alba --gpus all --ipc=host -p 8888:8888 -v "$(pwd)":/home/"$(whoami)"/workspace ml-dev-TAG
```

> If using `ml-dev-TAG-cpu`, the `--gpus all` option is removed

Let's break down what the options here do:

- `--init` does the proper [init](https://github.com/krallin/tini) and takes care of process reaping
- `--rm` removes the container after it exits. If you want to inspect container's logs after it exits, remove this part.
- `-d` makes it run in the background. Since the container will be running in the background, you can use `docker logs` to view the output while it is running.
- `--name alba` names the container `alba` - then you can stop it with `docker stop alba` .
- `--gpus all` gives the container access to the GPUs of your machine.
- `--ipc=host` is needed for `pytorch` , because Docker limits shared memory for processes to only 64MB by default -- and if you will be loading/processing images with multiple workers, this will not be enough. Alternatively, you could adjust `shm-size` .
- `-p 8888:8888` binds the container's 8888 port (where Jupyter will be listening) to port 8888 on your machine.
- `-v "$(pwd)":/home/$(whoami)/workspace` creates a bind mount from the current directory on your machine to the container's mount directory. This gives the container the ability to read and write in the current directory on your system. 

If you want to modify this command, just modify `/usr/local/bin/ml-dev-TAG[-cpu]`

### Jupyter options

You can specify [command line options](https://jupyter-notebook.readthedocs.io/en/stable/config.html) to change some default settings -- for example, to change the password. You can create a new password following the steps [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password), and then change it by passing the command

```bash
jupyter lab --NotebookApp.password='<NEW_PASSWORD>'
```

to the [default command](#quickstart).

## Specs and versions

There are 4 different versions of the images (size means size when extracted):

| Name | Size | Description |
| ---- | ---- | ----------- |
| [`eda`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.eda) | 2.08GB | Based on [`10.2-base-ubuntu18.04`](https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/10.2/ubuntu18.04-x86_64/base/Dockerfile) CUDA image. Uses conda, and comes with the following packages installed: <ul><li>**Basic**: numpy, pandas and scipy</li><li>**Plotting**: matplotlib, seaborn and plotly</li><li>**ML**: statsmodels, scikit-learn, eli5, spacy</li><li>**Jupyter lab** + TOC + code formatter extensions</li><li>**Utilities**: Click, hydra, pytest</li></ul>|
| [`pytorch`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.pytorch) | 5.18GB| based on `eda`, comes with pytorch (with its own CUDA), torchvision, torchtext, pytorch-lightning  and 🤗transformers installed. |
| [`tf`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.tensorflow) | 6.04GB | based on `eda`, comes with tensorflow and 🤗transformers installed (CUDA installed system-wide) |
| [`boost`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.boost) | 5.39GB | based on `eda`, comes with the 3 main gradient boosting libraries installed (Catboost, LGBM and XGboost). CUDA installed up to [`devel`](https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/devel/Dockerfile) level. |

## Extending the image

You can extend the image in two ways, depending what you need:

1. [Create a new image](#creating-a-new-image): if you want to install packages you will use often and/or are hard (take a long time) to install.
2. [Install with pip](#installing-with-pip): if you have just a few small packages to install, or if you just need to try something once.

### Creating a new image

This method is more complicated, but will save you time in the long run, especially if the installation is more involved, or if it's something you use a lot.

As an example, say that you want to add [fairseq](https://github.com/pytorch/fairseq) to the `pytorch` image. Following the instructions, your Dockerfile would like like this:

``` docker
FROM tadejsv/ml-docker:pytorch

# Install fairseq
RUN cd / && git clone https://github.com/pytorch/fairseq && \
    cd fairseq && \
    pip install --editable ./ && \
    pip install fastBPE sacremoses subword_nmt && \
    rm -rf /home/.cache
```

You would then build this image, and run it exactly like the `pytorch` one.

#### Using CUDA

If you attempt to install anything that requires CUDA, things could get messy. For example, pytorch installs its own CUDA toolkit, which can not be used with other programs. This means you'd have to install CUDA yourself.

Luckily, this isn't that hard. The images are based on [10.2-base-ubuntu18.04](https://hub.docker.com/r/nvidia/cuda/) docker CUDA image, which means you can "upgrade" them to runtime or development CUDA pretty easy - just paste together the [extra commands](https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.2) from these images -- see the [`boost`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.boost) dockerfile. This will add a few GB to your images.

### Installing with pip

If all you need to do is to install a package or two, you can just add a line at the beginning of your notebook/script. For example, if you need the [albumenations](https://github.com/albumentations-team/albumentations) package in your notebook, you'd add this line at the beginning:

```python
! pip install albumentations
```

## TODO

- Write tests
