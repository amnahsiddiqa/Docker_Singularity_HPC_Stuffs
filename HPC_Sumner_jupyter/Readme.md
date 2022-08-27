## SIngularity Reads:
https://readthedocs.org/projects/singularity-userdoc/downloads/pdf/latest/



- Starting with Singularity 3.2, the Bootstrap keyword needs to be the
first entry in the header section. This breaks compatibility with older
versions that allow the parameters of the header to appear in any order.

## First task
- is run python jupyter with Python kernel only ;

```

cd /projects/sh-li-lab/share/SiddiqaA/Singularity_AS

#did not need to be on intearctive node for this ;
builder="singularity run http://s3-far.jax.org/builder/builder"

$builder ./slim.def slim.sif#$ is part of command

srun -p dev -q dev -N 1 -n 1 -c 2 --mem 16G --time 8:00:00 --pty bash

module load singularity

./slim.sif jupyter-lab --no-browser --ip=$(hostname -i) --port=8884

```

```
#slim.def
Bootstrap: docker
From: python:3.9.7-slim-buster

%post
    apt-get update
    apt-get install -y graphviz
    pip install --upgrade pip
    pip install jupyterlab
    pip install asari-metabolomics
    pip install mass2chem
    pip install jms-metabolite-services
    pip install metDataModel

%runscript
    exec "$@"

```


## Second task
- is try my own docker jupyter with R kernel -  to be run in proper order and builded;


```
#slim2.def
Bootstrap: docker
FROM: jupyter/r-notebook

%post

    export PATH=/opt/conda/bin/pip:$PATH


%runscript
    exec "$@"

```

```
cd /projects/sh-li-lab/share/SiddiqaA/Singularity_AS

#did not need to be on intearctive node for this ;
builder="singularity run http://s3-far.jax.org/builder/builder"


$builder ./slim.def slim.sif#$ is part of command


# now have an interactive session on compute node
srun -p dev -q dev -N 1 -n 1 -c 2 --mem 16G --time 8:00:00 --pty bash

module load singularity

./slim2.sif jupyter-lab --no-browser --ip=$(hostname -i) --port=8884


```



Things to do :

- Conda install and Run command was not working at the moment;  possibly related to https://github.com/LLNL/lbann/issues/855#issue-406891784; and https://stackoverflow.com/questions/63619623/problem-to-extend-a-singularity-image-from-an-existing-docker-image; need to come back later ;
