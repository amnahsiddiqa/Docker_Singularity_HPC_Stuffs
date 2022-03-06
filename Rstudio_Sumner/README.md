# Run Rstudio on HPC /Sumner 

1- rstudio.jax.org 

2- builtin image 
> singularity pull docker://rocker/rstudio:4.0.3 --name rstudio.simg

then

> sbatch launch_rstudio.sbatch

with 
```
cat launch_rstudio.sbatch
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

3- create your own 
```
Bootstrap: docker
From: rocker/rstudio:4.0.3


%labels
    Author selcan.aydin@jax.org
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


