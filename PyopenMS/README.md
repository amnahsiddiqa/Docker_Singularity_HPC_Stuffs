

# Run pyopenms on sumner


```
ssh login.sumner.jax.org
#/home/siddia
#/projects/sh-li-lab


#Load singularity module on Sumner
srun --pty -q batch bash -I
module load singularity

#you might want check if its loaded
which singularity
singularity –version
singularity --help


#pull an image form dockerhub

singularity pull  docker://openms/pyopenms
#you should be able to see the relevant sif file ;

```
