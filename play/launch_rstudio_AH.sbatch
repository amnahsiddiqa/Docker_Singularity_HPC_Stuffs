#!/usr/bin/env bash
### SLURM HEADER
#SBATCH --output=/projects/sh-li-lab/share/SiddiqaA_Projects/Sing/ASTest-%j.log  #!!
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=amnah.siddiqa@jax.org #!!
#SBATCH --qos=batch
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20GB
#SBATCH --export=ALL
### SLURM HEADER
localcores=${SLURM_CPUS_PER_TASK}
simg_path="/projects/sh-li-lab/share/SiddiqaA_Projects/Sing/rstudio.simg" #!!
work_dir="/projects/sh-li-lab/share/SiddiqaA_Projects/Sing/work" #!!
set -euo pipefail
#mkdir -p ${work_dir}
cd ${work_dir}
mkdir -p run tmp
export PASSWORD=$(openssl rand -base64 15)
PORT=$(shuf -i8899-11999 -n1)
hostname_with_port=$(echo $(hostname -A):${PORT} | tr -d " ")
echo Login to ${hostname_with_port} with username: ${USER} password: ${PASSWORD}
module load singularity
singularity exec \
    -B $(pwd)/run:/run \
    -B $(pwd)/tmp:/tmp \
	-B /projects/sh-li-lab/share \
    ${simg_path} rserver \
    --www-port ${PORT} \
    --auth-none=0 --auth-pam-helper-path=pam-helper \
    --auth-timeout-minutes=0 \
    --auth-stay-signed-in-days=30
