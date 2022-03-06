# Run Rstudio on HPC /Sumner 

1- rstudio.jax.org 

2- builtin image 

> singularity pull --name rstudio.simg docker://rocker/rstudio:4.0.3

then

> sbatch launch_rstudio.sbatch

with 
```
>$ cat launch_rstudio.sbatch
#!/usr/bin/env bash
### SLURM HEADER
#SBATCH --job-name=rstudio-flynnb  #!!
#SBATCH --output=/home/flynnb/logs/rstudio-%j.log  #!!
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=bill.flynn@jax.org #!!

#SBATCH --account=compsci  #!!
#SBATCH --partition=compute
#SBATCH --qos=batch
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64GB

#SBATCH --export=ALL
### SLURM HEADER

localcores=${SLURM_CPUS_PER_TASK}

simg_path="/fastscratch/flynnb/rstudio.simg" #!!
work_dir="/fastscratch/flynnb/work" #!!

set -euo pipefail

mkdir -p ${work_dir}
cd ${work_dir}
mkdir -p run tmp

export PASSWORD=$(openssl rand -base64 15)
PORT=$(shuf -i8899-11999 -n1)

hostname_with_port=$(echo $(hostname -A):${PORT} | tr -d " ")

cat 1>&2 <<EOF
Login to ${hostname_with_port} with
  username: ${USER}
  password: ${PASSWORD}
EOF

module load singularity
singularity exec \
    -B $(pwd)/run:/run \
    -B $(pwd)/tmp:/tmp \
    ${simg_path} rserver \
    --www-port ${PORT} \
    --auth-none=0 --auth-pam-helper-path=pam-helper \
    --auth-timeout-minutes=0 \
    --auth-stay-signed-in-days=30 
```

3- Create your own image

"My strategy in running Rstudio from sumner is to have all the packages locally installed. I use renv to manage them and keep the cache with all the packages installed under our lab’s projects directory. Any new project I start uses renv and the cache directs to that original cache folder. I have installed >400 packages and in my experience if sth is failing it is most likely a dependency missing in the unix setup. I am copying below the .def file I have been using successfully with bioconductor and CRAN packages. If R is giving you a lib missing error you can just add it to long list of other lib installs. Using renv has been very helpful in changing R versions too."

```
Bootstrap: docker
From: rocker/rstudio:4.0.3


%labels
    Author amnah.siddiqa@jax.org
    R_VERSION 4.0.3

%runscript
    echo "Container was created $NOW"
    echo "Arguments received: $*"
    exec echo "$@"

%post

  apt-get update \
    && apt-get install -y --no-install-recommends \
    ssh \
    bash \
    pkg-config \
    libjpeg62-dev \
    libz-dev \
    tk \
    libxml2 \
    libxml2-dev \
    libbz2-dev \
    liblzma-dev \
    xterm \
    x11-utils

%help
    This is the container to launch Rstudio using launch_rstudio.sbatch script. 
    
```


