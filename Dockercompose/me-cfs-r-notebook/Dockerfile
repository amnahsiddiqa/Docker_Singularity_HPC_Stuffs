# docker stacks jupyter/r-notebook uses minimal notebook image as base
# which  in turn uses jupyter's base image
# conda is being used as package manager for both python
# and R therefore we use it for all relevant installations as well
# tidyverse and few other necessary packages are already
# there; don't need anything else fancy
# AS: July232021 ; for MS data analysis; ms_jupyter_r; v0.0.0

FROM jupyter/r-notebook

RUN conda install -c bioconda bioconductor-variancepartition 
RUN conda install -c conda-forge r-hmisc
RUN conda install -c r r-car
RUN conda install -c odsp-test/label/test r-nmf
RUN conda install -c conda-forge r-ggpubr
RUN conda install -c bioconda r-factominer
RUN conda install -c conda-forge r-factoextra
RUN conda install -c bioconda r-pheatmap
RUN bconda install -c bioconda r-ggbiplot
RUN conda clean --all --yes

RUN pip install --upgrade pip
ADD requirements_py.md .
RUN pip install -r requirements_py.md