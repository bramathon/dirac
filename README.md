# README #

This is the Zepp AI development environment. It's called _dirac_.

# Project Requirements

There is only one requirement to build this project - the Docker engine

Please check https://huami.atlassian.net/wiki/spaces/NTE/pages/325025814/Docker for installation instructions.

# Useful Commands

## Login to docker
If you want to know the password, ask the repo owner.

```bash
docker login --username=zeppai --password=<password>
```

## Build

```bash
docker build --tag zeppai/dirac:latest .
```

## Push the image

```bash
docker push zeppai/dirac:latest
```

## Run 

### Shell

To get a bash shell in the docker iamge, run:

```bash
docker run --rm -it zeppai/dirac:latest bash
```

Note this will stop and remove the container on exit

### Jupyter Lab

To run jupyter lab, do something like this

```bash
docker run --rm -it --publish 8888:8888 --volume $(pwd):/home/zepp/app --volume ~/.aws:/home/zepp/.aws zeppai/dirac:latest jupyter lab --LabApp.token='' --ip=0.0.0.0 --no-browser
```


# Adding a package

Please note that changes to this image will affect ALL USERS. If you think a change might break somethiing, please check. Nonetheless, users are encouraged to add whatever packages they need. The size of this container is not a concern.

As a rule of thumb, major packages like numpy and tensorflow should be updated intentionally and sepcified to only allow compatible versions like `numpy~=1.20.0`. Utilities like plotting can be less strict since we generally want the most recent version, eg `matplotlib >=3.3.4`.

# Docker-compose

A docker compose file is included in this repo as a template
