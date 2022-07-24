
# fgsea R package Docker image 

## Create fgsea R script based Docker Image from scratch  

I had to use GSEA for my own analysis (for multiple data sets) which led me to create docker images for both fgsea R package and Broad java application necessitated by reproducible results.

Both of which are available at https://hub.docker.com/u/asidd13  and --coming soon (for Broad institute)-- and can be used by anybody following the instructions here (or also provided at dockerhub).

Its a three step process:

- We create R script 

- Create a docker file

- Push to docker registry at dockerhub and use it

### The R script
fgsea can be followed along in a pretty straightforward manner using R from the instructions 
at [https://bioconductor.org/packages/release/bioc/vignettes/fgsea/inst/doc/fgsea-tutorial.html] 

- I needed to create a r script that starts from providing a .rnk and a .gmt file as inputs to docker image to run.
- So to begin, We will create three folders inside our docker conatiner out of which one named "Data" will be mounted to our input data directory hosted in our machine. Therefore, when we mount our data directory with Data folder and the files will be copied an made availaible to be manipulated for analysis
- To run fgsea we should have two files ; a gmt file and a rank file (.rnk extension). Description on creation of files provided here https://software.broadinstitute.org/cancer/software/gsea/wiki/index.php/Data_formats. The test files to be used with this image can be downloaded from here https://doi.org/10.6084/m9.figshare.13239512.v1

```
#myScript.R 
#our required r packages 
library(tidyverse)
library(fgsea)

print("Loaded Docker...Now processing results.....")


#Look for gmt file in Data folder
files <- list.files("/Data")
gmt.file <- files[grep(".gmt", files, fixed=T)]
gmt.file<-paste0("/Data/", gmt.file)


#using fgsea gmtPathways function, convert it into list
pathways <- fgsea::gmtPathways(gmt.file)
head(pathways)

#Look for Rank File 

rank.file <- files[grep(".rnk", files, fixed=T)]
rank.file<-paste0("/Data/", rank.file)

#Rank file  consists of two columns . first should be a feature/gene names column(that would be character typpe varaibles) and the second should be any statistic that we want to use for ranking our file and it would be numeric of course.
#making sure that second column is numeric
ranks <- read.table(rank.file, header=TRUE, colClasses = c("character", "numeric"))

#Converting dataframe to named vector of gene-level statistics
ranks <- tibble::deframe(ranks)

#manipulate data fior analysis 
fgseaRes <- fgsea(pathways = pathways, 
                  stats = ranks,
                  minSize=15,
                  maxSize=500)

#write back results in output folder taking into accopunt first seven columns - only lats column having leading edge genes is dropped as I dint needed it  
fgseaRes<-fgseaRes[,1:7]

#fgseaRes is the results file and shalle be copied in Output folder in container 
write.table(fgseaRes, "Output/fgseaRes.tsv", sep="\t", row.names = FALSE)


```
We need another r file i.e. istall_packages.R  holding instructions for installing packages that are required to be installed. Since we are using tidyverse and base r base images already we only need to install fgsea 
```
#istall_packages.R
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("fgsea")

```

### Creating Docker file
This is the docker file used to create fgsea docker image. 

```
# pulling r-base image  from rocker project (maintained by Dirk Eddelbuettel & Carl Boettiger) built on light\ weight debian:9 for versions > 3.4.1. The resson for using a specific rbase version is the reproducibility.\ Mentioning becuase I guess rocker/r-base keep being updated.


FROM rocker/r-base:4.0.0
FROM rocker/tidyverse


#create three directories that we need to mount our input and output data and copy scripts respectively.
RUN mkdir -p /Data
RUN mkdir -p /Output
RUN mkdir -p /Script

#copying the install_packages.R and myScript.R files inside conatiner folder called Script
COPY /Script/install_packages.R /Script/install_packages.R
COPY /Script/myScript.R /Script/myScript.R

# run the install.packeges while building the container 
RUN Rscript /Script/install_packages.R
## run the script from source when conatiner runs 
CMD Rscript /Script/myScript.R

```

### Creating Docker image 
Run following in terminal.

```
#step1: change directory where you have your Rscript file and docker file present
$cd ~/TestProject
#Lets make sure the files are present. Docker file is a txt file but it does not have any extension like .txt.
$ls
Dockerfile  Script
#I have changed script file to install fsgea from bioconductor as I think it did not get installed last time 

#step2 build your docker image. dont forget period in the end of this command.It (.) means it will build the Dockerfile in the current working directory.
docker build -t asidd13/base-r-fgsea .

#Optional: tag your repo if you want else it will have tag latest anyway
#docker tag  aa4228afffb9 asidd13/base-r-tidyverse-fgsea:v1.0.0

#step3: login ; provide docker hub credentials 
docker login


#step4: push image 
docker push asidd13/base-r-tidyverse-fgsea:latest

```
### Using Docker image 

- Download the test (a .rnk file and a .gmt file ) from  https://doi.org/10.6084/m9.figshare.13239512.v1

```
docker pull asidd13/base-r-fgsea

# -it for interactive ; -- rm tag is to remove conatiner afterwrads ; -v is volume mounting your homne directory holding input data (i.e. both gmt and rnk files) and where you want your results to be stored respectively.

docker run -it --rm -v path to data in your home directory:/Data -v path to directory where you want to store the results:/Output asidd13/base-r-fgsea:latest

#For example if you have rank file and gmt file stored in ~/Documents/Data and you have an empty  folder ~/Documents/Output you could use 
docker run -it --rm -v ~/Documents/Data:/Data -v ~/Documents/Output:/Output asidd13/base-r-fgsea:latest

```

## GSEA java application docker image 
coming soon 

