# VSCode development container repository template for ML projects

This template enables you to use a full-fledged containerized development environment for your machine learning projects - all with VSCode!

The container itself will only take care of running the code, the files/data and your credentials are brought over from and saved to your local workspace, so it all works out of the box.

## Prerequisites

You should have [docker](), [docker-compose]() and [VSCode]() installed - as well as [NVIDIA Docker container runtime]() and [NVIDIA drivers](), unless you
plan run the container ona a [CPU Only](#cpu-only) machine.

Additionally, you need to expose your *user id* as an environmental variable `UID`. If you use bash or zsh, you do this by 
adding the following to your `.bashrc` or `.zshrc` file:
```
export UID
```

## Quickstart

Starting up a development container is easy. First, open the repository (locally) in VSCode, then press  <kbd>Ctrl</kbd> + <kbd>shift</kbd> + <kbd>P</kbd> and type/select "Reopen in Container".

But before you do that, you might consider adjusting this template to your needs, as explained in the next section.

## What's in this template

This template does a few things, and it's useful to know what they are, so you know what to adjust. I'll explain it by describing what is the function of each file in this repo. Here's a directory tree diagram:

```
.
├── .devcontainer
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   ├── env_dev.yml
│   └── jupyter_lab_config.py
├── Dockerfile
├── env.yml
├── sys_requirements.txt
├── README.md
└── .gitignore
```

### The `.devcontainer` folder

This folder contains all the additional development things needed to set up the environment/container. Said another way, things not in this folder (so things in the root directory of the repository) are the barebones requirement for your project (what you would use in "production"), and this folder adds to that things needed to set up a complete development environment

### `.devcontainer/devcontainer.json`

This defines the VSCode development container. It delegates the "base" of the container itself to `docker-compose.yml`, and focuses on:

1. Forwarding ports to your machine - in this case port 8888, which is usually used for Jupyter Lab.
2. Installing VSCode extensions in the container - here these are the Python extension, GitLens, as well as VSCode icons pack and a yaml formatter.
3. Setting up VSCode settings - in this case the location of python (conda) environment, that black formatter and flake8 linter should be used.

### `.devcontainer/docker-compose.yml`

This file mainly takes care of configuring how the docker container connects to the local file system.

First, it sets the current user's username and user id (that you [set up before](#prerequisites)) to be used for the user inside the container - ensuring that there are no permission issues when you interact with local files.

Then, it mounts the repository inside the `~/ws` directory in the container, as well as mounting `~/.ssh` and `~/.aws` directories - so that you can use GitHub (and other SSH-related services) and AWS right out of the box.

It also mounts `opt/dvc/cache` (where your [DVC](https://dvc.org/) cache is located, if you set it up this way), giving you immediate access to your DVC files.

Apart from that, it adds some minor authetincation env vars - in this case, the API key for [WandB](https://wandb.ai/site).

### `.devcontainer/env_dev.yml`

This conda environment file specifies the requirements for development (they will be added to the base environment) that are not part of the "base" `env.yml`. In this case it includes `pytest`, `flake8` and `jupyterlab` with `ipywidgets`.

## CPU Only

If you want to use this on a CPU-only device, you only need to make two minor changes:

1. In `env.yml` change `cudatoolkit=11.0` to `cpuonly`. This should also reduce the size of the container significantly, and speed up the build a lot.
2. In `.devcontainer/docker-compose.yml` remove `runtime: nvidia`

If you wish you may also replace the base image in `Dockerfile`, though that will only save you ~50MB.