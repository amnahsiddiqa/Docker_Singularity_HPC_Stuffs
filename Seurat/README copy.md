

#### Seurat: 

Seurat:
https://jaxreg.jax.org/containers/569


In particular, I have taken a rocker image (with bioconductor and rstudio) and added seurat to it. This involved a lot of headaches and I hope others will benefit. I have attached the slurm script I used (simply run on HPC with sbatch sbatch-rstudio-seurat-large). I don’t understand the script (modified from the rocker singularity site) and you shouldn’t need to either — just modify the few variables between ‘Begin customization’ / ‘End customization’. 

--
## Acknowledgements 

- Brian White