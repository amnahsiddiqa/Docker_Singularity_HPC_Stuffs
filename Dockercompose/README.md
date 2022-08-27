# Docker compose guidelines to run


## How to run for locally built  images
- `cd path/to/directory containing yaml and Dockerfile`
- Build: `docker-compose build`
- Start: `docker-compose up`
- Stop: `docker-compose down`

where the `Dockerfile` is the current docker image for running the analyses and yaml is the configuration file.


```
# docker stacks jupyter/r-notebook uses minimal notebook image as base
# which  in turn uses jupyter's base image
# conda is being used as package manager for both python
# and R therefore we use it for all relevant installations as well
# tidyverse and few other necessary packages are already
# there; don't need anything else fancy
# AS: July232021 ; for MS data analysis; ms_jupyter_r; v0.0.0

FROM jupyter/r-notebook

RUN conda install -c conda-forge r-ncdf4
RUN conda install -c bioconda bioconductor-msnbase
RUN conda install -c bioconda bioconductor-mzr
RUN conda install -c bioconda bioconductor-xcms\
    && conda clean --all --yes
    
```
```
version: '3.9'
services:
  R-notebook:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: test
    image: docker.io/amnahsid/test
    ports:
      - '8888:8888'
    volumes:
      - ~:/home/jovyan/

```

and yaml file looks like tthis

```
version: '3.9'
services:
  R-notebook:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: test
    image: docker.io/amnahsid/test
    ports:
      - '8888:8888'
    volumes:
      - ../../:/home/jovyan/
```

## How to run for keeping updates on registry

```
cd path/to/directory containing yaml and Dockerfile
#Build
$docker-compose build
$docker login
# Do not forgrt to append the domain name of your Docker registry
# if you are not using Docker Hub; for example:
# docker login quay.io

#because I ran into problem https://github.com/amnahsiddiqa/Docker_Singularity_HPC_Stuffs/issues/2
$export COMPOSE_HTTP_TIMEOUT=380
$export DOCKER_CLIENT_TIMEOUT=380

$ docker-compose push
# and optionally:
$ docker logout
```

## references :
- https://docs.docker.com/engine/reference/commandline/compose_push/
- https://stackoverflow.com/questions/53416685/docker-compose-tagging-and-pushing


## Docker restart if needed
osascript -e 'quit app "Docker"'
open -a Docker



### Appendix by MG
- Kill all processes `docker container kill $(docker container ls -q)`
- Remove images `docker rmi -f 3c28caa55afe`
- BUild docker from Dockerfile `docker build <path2dockerFileFolder>`
  - retag your docker image `tag 059b73abd843 gongm/me-cfs-r-jupyter:latest`
- To push your docker image to docker hub `docker push gongm/me-cfs-r-jupyter:latest`
- If you have a file name of the yaml file which is not as default `docker-compose.yaml`
  - Start: `docker-compose -f ./me-cfs-r-docker-compose.yaml up`
  - Stop: `docker-compose -f ./me-cfs-r-docker-compose.yaml down`
  - It is somehow difficult to use this with `docker-compose build` so I still use default name in the current practice.
