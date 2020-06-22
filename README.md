# 🐋🔥 ML Docker containers

<a href="https://hub.docker.com/repository/docker/tadejsv/ml-docker" alt="Docker hub"><img src="https://img.shields.io/docker/pulls/tadejsv/ml-docker?style=for-the-badge"/></a>

These are [easy to use](#quickstart) Ubuntu Docker images that come with [everything you need](#specs-and-versions) for machine learning - full GPU (CUDA) support included! And if there's a package you're missing, it's very easy to [extend the container](#extending-the-container).

Availible on [Docker Hub](https://hub.docker.com/repository/docker/tadejsv/ml-docker).

1. [Quickstart](#quickstart)
    - [Start Jupyter Lab/Notebook](#start-jupyter-labnotebook)
    - [Run a script](#run-a-script)
2. [Configuration](#configuration)
    - [Docker options](#docker-options)
    - [Jupyter options](#Jupyter-options)
3. [Specs and versions](#specs-and-versions)
4. [Extending the image](#extending-the-image)
    - [Creating a new image](#creating-a-new-image)
    - [Installing with pip](#installing-with-pip)

## Quickstart

First, Make sure you have [NVIDIA drivers](https://www.nvidia.com/Download/index.aspx) (>= 418.39), [docker](https://docs.docker.com/engine/install/) and [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker) installed.

### Start Jupyter Lab/Notebook

- **Step 1**: `cd` into the directory from which you want to work
- **Step 2**: Execute this command

    ``` bash
    docker run --rm -d --name alba --gpus all --ipc=host -u $(id -u) -p 8888:8888 -v "$(pwd)":/workspace tadejsv/ml-docker:pytorch
    ```

    This command will make Jupyter Lab availible on your machine at [https://localhost:8888](https://localhost:8888), with the password `getrekt`.
- **Step 3**: When you want to stop the container, execute
    ``` bash
    docker stop alba
    ````

### Run a script

If you want to run a `.py` or `.sh` script, add the following to the command from Step 2 above:

```bash
my_script.py arg1 arg2
```

This will simply start running your script, and will not start Jupyter Lab. It will terminate the container automatically once your script finishes.

## Configuration

### Docker options

Let's break down what the options in the [default command](#start-jupyter-labnotebook) do:

* `--rm` removes the container after it exits. If you want to inspect container's logs after it exits, remove this part.
* `-d` makes it run in the background. Since the container will be running in the background, you can use `docker logs` to view the output while it is running.
* `--name alba` names the container `alba` - then you can stop it with `docker stop alba` .
* `--gpus all` gives the container access to the GPUs of your machine.
* `--ipc=host` is needed for `pytorch` , because Docker limits shared memory for processes to only 64MB by default -- and if you will be loading/processing images with multiple workers, this will not be enough. Alternatively, you could adjust `shm-size` .
* `-u $(id -u)` runs the container as the current user on your machine - so you can access any documents that the container creates.
* `-p 8888:8888` binds the container's 8888 port (where Jupyter will be listening) to port 8888 on your machine. 
* `-v "$(pwd)":/workspace` creates a bind mount from the currend directory on your machine to the container's mount directory. This gives the container the ability to read and write in the current directory on your system.  

### Jupyter options

You can specify [command line options](https://jupyter-notebook.readthedocs.io/en/stable/config.html) to change some default settings -- for example, to change the passowrd. You can create a new password following the steps [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password), and then change it by passing a command line argument

```
--NotebookApp.password='<NEW_PASSWORD>'
```

to the [default command](#start-jupyter-labnotebook).

#### Jupyter Notebook instead of Jupyter Lab

If you wish to start Jupyter Notebook instead of Jupyter Lab (which you need to do this, for example, if you want the Catboost widgets to work), add `notebook` as the first argument (+ command line options).


## Specs and versions

There are 4 different versions of the images (size means size when extracted):

| Name | Size | Description |
| ---- | ---- | ----------- |
| [`eda`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.eda) | 2.63GB | Based on [`10.1-base-ubuntu18.04`](https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/base/Dockerfile) CUDA image. Uses conda, and comes the following packages installed: <ul><li>numpy, pandas and scipy</li><li>matplotlib and seaborn</li><li>scikit-learn and Pillow</li><li>Jupyter lab + TOC and code formatter extensions (with isort, black and autopep8 formatters)</li></ul>|
| [`pytorch`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.pytorch) | 4.91GB| based on `eda`, comes with pytorch (with its own CUDA), torchvision and pytorch-lightning installed. |
| [`tf`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.tensorflow) | 5.79GB | based on `eda`, comes with tensorflow installed (CUDA installed system-wide) |
| [`boost`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.boost) | 5.78GB | based on `eda`, comes with the 3 main gradient boosting libraries installed (Catboost, LGBM and XGboost). CUDA installed up to [`devel`](https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/ubuntu18.04/10.1/devel/Dockerfile) level. |

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

Luckily, this isn't that hard. The images are based on [ `10.1-base-ubuntu18.04` ](https://hub.docker.com/r/nvidia/cuda/) docker CUDA image, which means you can "upgrade" them to runtime or development CUDA pretty easy - just paste together the [extra commands](https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist/ubuntu18.04/10.2) from these images -- see the [`boost`](https://github.com/tadejsv/ml-docker/blob/master/Dockerfile.boost) dockerfile. This will add a few GB to your images.

### Installing with pip

If all you need to do is to install a package or two, you can just add a line at the beginning of your notebook/script. For example, if you need the [albumenations](https://github.com/albumentations-team/albumentations) package in your notebook, you'd add this line at the beginning:
 
``` 
! pip install albumentations
```

## TODO

* Create a TensorBoard image and intergrate with Docker compose
* Write tests
* Remove pytorch-nightly  when torch hits 1.6.0.
* Up the CUDA version to 10.2 once TF starts supporting it.
