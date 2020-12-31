# VSCode development container repository template for ML projects

## Prerequisites

You should have [docker](), [docker-compose]() and [VSCode]() installed - as well as [NVIDIA Docker container runtime](), unless you
plan run the container ona a [CPU Only]() machine.

Additionally, you need to expose your *user id* as an environmental variable `UID`. If you use bash or zsh, you do this by 
adding the following to your `.bashrc` or `.zshrc` file:
```
export UID
```

## Quickstart

## What's in this template

## CPU Only

If you want to use this on a CPU-only device, you only need to make two minor changes:

1. In `env.yml` change `cudatoolkit=11.0` to `cpuonly`
2. In `.devcontainer/docker-compose.yml` remove `runtime: nvidia`