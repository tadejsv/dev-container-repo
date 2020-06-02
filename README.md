# ML Docker containers

These are Ubuntu based Docker images for Machine Learning. Currently only the Pytorch development version exists, but I plan to add support for "production" and Tensorflow images as well. 

This is an Ubuntu 20.04 based Docker image. It has all the standard ML packages installed (numpy/pandas/scipy/scikit-learn), as well as Pytorch (with CUDA) and Torchvision, plus Pytorch Lightning.

## Starting the container

There are two ways to start the container, depending on what you want to do:

1. [Start Jupyter Lab](#start-jupyter-lab)

2. [Run a script](#run-a-script)

### Start Jupyter Lab

To start the container all you need to do is

```
docker run --gpus all -p 8888:8888 -v <SOURCE>:/root/project tadejsv/ml-dev
```

Here `SOURCE` is the project directory on your machine. This will make Jupyter Lab availible on port `https://localhost:8888` on your machine.

You can specify [command line options](https://jupyter-notebook.readthedocs.io/en/stable/config.html) to change some default settings -- for example, to change the passowrd, as shown below.

#### Jupyter Lab password

The default password is `getrekt`. You can create a new password following the steps [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password), and you can change it (in the example to `gitgud`) with a command line argument:

```
docker run --gpus all -p 8888:8888 -v <SOURCE>:/root/project tadejsv/ml-dev --NotebookApp.password='sha1:101b601a1ef3:b6ec8fcb9947edd47e9568e9cab33af5570c84be'
```

### Run a script

If you want to run a `.py` or `.sh` script, you would type

```
docker run --gpus all -v <SOURCE>:/home/pyuser/project tadejsv/ml-dev my_script.py arg1 arg2
```

## Tensorboard

I plan to use s6 later to simulatenously launch both Tensorboard and Jupyter Lab at start - for now you'll have launch Tensorboard on your own machine.

## Extending the container

This container contains only the "base" packages. If you need to install other packages, you can do so easily by creating a new image based off this one. For example, if you need to install the Albumenations package, your dockerfile would look like

```{docker}
FROM tadejsv/ml-dev

RUN conda install albumenations && \
    conda clean -yaf
```

You can then build your image and upload it to DockerHub. You would then run the container exactly like this one, just replacing `tadejsv/ml-dev` with the name of your image!

## TODO

- Launch Tensorboard simulatensously with s6
- Make the container not run as root
- Improve security?