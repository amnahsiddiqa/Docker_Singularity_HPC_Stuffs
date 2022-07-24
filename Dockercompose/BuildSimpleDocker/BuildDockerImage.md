
## Creating Docker file

Dockerfile
```

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


## Building Docker images

With Dockerfile written, you can build the image using the following command:

`$ docker build .`

We can see the image we just built using the command docker images.

```
$ docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
<none> <none> 7b341adb0bf1 2 minutes ago 83.2MB
```

## Tagging a Docker image

When you have many images, it becomes difficult to know which image is what. 
Docker provides a way to tag your images with friendly names of your choosing. 
This is known as tagging.

Let’s proceed to tag the Docker image we just built.

```
$ docker build -t yourusername/example-node-app

```
If you run the command above, you should have your image tagged already. 
Running docker images again will show your image with the name you’ve chosen.

```
$ docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
abiodunjames/example-node-app latest be083a8e3159 7 minutes ago 83.2MB
```
## Running a Docker image

You run a Docker image by using the docker run API. The command is as follows:

$ docker run -p80:3000 yourusername/example-node-app

## Pushing a Docker image to Docker repository

$ docker login


`docker tag yourusername/example-node-app yourdockerhubusername/example-node-app:v1`

Then push with the following

`$ docker push abiodunjames/example-node-app:v1`



You can list Docker containers:

`$ docker ps`

And you can inspect a container:

`$ docker inspect <container-id>`

You can view Docker logs in a Docker container:

`$ docker logs <container-id>`

And you can stop a running container:

`$ docker stop <container-id>`



## How to delete a Docker image tag from Docker Hub registry


Remove image/tag from Docker Hub using a Docker image

docker run --rm -it lumir/remove-dockerhub-tag --user user \
 --password pass org/image_1:tag_1 org/image_2:tag_2 ...


 ## remove local images 

 List your Docker images and/or find a specific tag from your local Docker registry:

docker images

# or a newer version
```
$ docker image list

# search for a specific docker tag to remove
$ docker image list | grep nginx
nginx                        1.17-alpine          aaad4724567b
#And remove the Docker image by name/repo and tag:

# docker remove image:tag
$ docker rmi {image}:{tag}

# docker remove nginx image with tag 1.17-alpine
$ docker rmi nginx:1.17-alpine
```


## references
https://jsta.github.io/r-docker-tutorial/04-Dockerhub.html