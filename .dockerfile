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