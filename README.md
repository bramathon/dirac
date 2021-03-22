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

# User and Group ID

When you start up the image, you'll see the Tensorflow splash:

```
________                               _______________                
___  __/__________________________________  ____/__  /________      __
__  /  _  _ \_  __ \_  ___/  __ \_  ___/_  /_   __  /_  __ \_ | /| / /
_  /   /  __/  / / /(__  )/ /_/ /  /   _  __/   _  / / /_/ /_ |/ |/ / 
/_/    \___//_/ /_//____/ \____//_/    /_/      /_/  \____/____/|__/


You are running this container as user with ID 1000 and group 1000,
which should map to the ID and group for your user on the Docker host. Great!
```

Pay attention to this message, it's important! Your user id and group id must be 1000.

You can check with the the `id` command:

```bash
id -u <user> # user id
id -g <user> # group id
```

# Installing your local package

Once the container is running, you will probably want to install your local package (if you have one).

This is done with
```bash
pip install -e .
```

# Adding a package

Please note that changes to this image will affect ALL USERS. If you think a change might break somethiing, please check. Nonetheless, users are encouraged to add whatever packages they need. The size of this container is not a concern.

As a rule of thumb, major packages like numpy and tensorflow should be updated intentionally and sepcified to only allow compatible versions like `numpy~=1.20.0`. Utilities like plotting can be less strict since we generally want the most recent version, eg `matplotlib >=3.3.4`.

# Docker-compose

A docker compose file is included in this repo as a template
