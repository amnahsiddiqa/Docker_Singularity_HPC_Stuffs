# Slurm run with Conda env

create R conda env and install necessary libraries for xcms installations - /Users/siddia/Documents/GitHub/MasterRepos/Docker_Singularity_HPC_Stuffs/HPC_Conda_R_Slurm/log_xcms_conda.txt

```
#!/bin/bash
#SBATCH --job-name=PerformancetestASARI190
#SBATCH --mail-type=END
#SBATCH -p compute
#SBATCH -q batch
#SBATCH --mem=10000
#SBATCH -o PerformancetestASARI190.%j.out # STDOUT
#SBATCH -e PerformancetestASARI190.%j.err # STDERR

source  activate home/siddia/anaconda3/envs/r-environment
Rscript /projects/sh-li-lab/share/SiddiqaA_Projects/Maheshwor_tests/test_terminal.R

```

#### Resources

https://sumner.verhaaklab.com/conda/s01_conda/


https://hpctalk.jax.org/t/running-first-r-pipeline-on-sumner/73/1


####

conda info --envs
