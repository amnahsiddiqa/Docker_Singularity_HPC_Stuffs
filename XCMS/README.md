




### Run XCMS on Sumner


```
ssh login.******.**.org
#/home/siddia
#/projects/sh-li-lab

cd /path/to/your/script/files --> /projects/sh-li-lab/singularity/TestDataXCMS for testing

ls -la

```
drwxr-sr-x 3 siddia sh-li-lab    204 Aug  3 19:36 .
drwxr-sr-x 4 siddia sh-li-lab    184 Aug  3 18:05 ..
drwxr-sr-x 2 siddia sh-li-lab    190 Aug  3 18:55 Data
-rw-r--r-- 1 siddia sh-li-lab    506 Aug  3 19:13 df.metadatav2.csv
-rw-r--r-- 1 siddia sh-li-lab  47656 Aug  3 19:34 test_diagnostic.pdf
-rw-r--r-- 1 siddia sh-li-lab 513437 Aug  3 19:34 test_featureTable.csv
-rwxr-xr-x 1 siddia sh-li-lab    388 Aug  3 19:29 xcms_script_AS.sh
-rwxr-xr-x 1 siddia sh-li-lab   1590 Aug  3 19:02 xcms_test_script.R


## To run batch job:

```
#pull xcms  image form dockerhub on your workspace; right now we do have it in lab workspace on Sumner  **/projects/sh-li-lab/singularity/**
singularity pull docker://yufree/xcmsrocker
#you should be able to see the relevant sif file ;Singularity  produces immutable images in the Singularity Image File (SIF) format.

```


```
sbatch xcms_script_AS.sh
```

 xcms_script_AS.sh :
Right now allocated time is 24 hours ; change to your needs

```
#!/bin/bash
#SBATCH --job-name=xcmsTest
#SBATCH --mail-type=END
#SBATCH --mail-user=amnah.siddiqa@jax.org#to notify the status of job
#SBATCH -p compute
#SBATCH -q batch
#SBATCH -t 24:23:00 # maximum time allocated to job
#SBATCH --mem=2000 #chanage mem to your needs
#SBATCH -o slurm.messge.%j.out # STDOUT
#SBATCH -e slurm.message.%j.err # STDERR


module load singularity

singularity exec /projects/sh-li-lab/singularity/xcmsrocker_latest.sif Rscript  xcms_test_script.R

```

- Key here  in Script is : register(SerialParam())

- xcms_test_script.R
```
library(xcms)
library(tidyverse)
library(stringi)
library(stringr)
register(SerialParam())
setwd("/projects/sh-li-lab/singularity/TestDataXCMS")
df.metadata<-read.csv("/projects/sh-li-lab/singularity/TestDataXCMS/df.metadatav2.csv")
df.metadata
fls<-df.metadata$NewFileName
fls

raw_data <- readMSData(files=fls,
                           pdata = new("NAnnotatedDataFrame", df.metadata),
                           mode = "onDisk")

raw_data
print(object.size(raw_data ), units = "Mb")


cwp <- CentWaveParam(peakwidth = c(1, 30), ppm = 1,  noise = 1000, prefilter = c(3, 1000))
xdata <- findChromPeaks(raw_data, param = cwp)

#' for merging peaks
mpp <- MergeNeighboringPeaksParam(expandRt = 5, ppm = 1, minProp = 0.5)
xdata <- refineChromPeaks(xdata, mpp)

#' RT alignment. Sample #1 is a pooled sample,
#' binSize = 1, no need to be smaller, performance critical
xdata <- adjustRtime(xdata, param = ObiwarpParam(centerSample = 1))

#' save diagnostic figure, optional
bpis_adj <- chromatogram(xdata, aggregationFun = "max", include = "none")
pdf('test_diagnostic.pdf', width=32, height=16)
par(mfrow = c(2, 1), mar = c(4.5, 4.2, 1, 0.5))
plot(bpis_adj)
plotAdjustedRtime(xdata)
dev.off()

pdp <- PeakDensityParam(sampleGroups = rep(1,length(fls)), minSamples=3, minFraction = 0.1, bw = 3, binSize=0.001)
xdata <- groupChromPeaks(xdata, param = pdp)

ftDef <- featureDefinitions(xdata)
ftValues <- featureValues(xdata, value = "into", method = "sum")

# Use first 7 cols in featureDefinitions
write.csv(cbind(ftDef[,1:7],ftValues), "test_featureTable.csv")
```


## To run an interactive job  follow this :

```
#Load singularity module on Sumner  ; only if want to run interactive job ; not required for batch scheduling
srun --pty -q batch bash -I
module load singularity

#you might want check if its loaded
#which singularity
#singularity –version


#run the container
# Running singularity shell allows you to spawn a new shell within your container and interact with it as though it were a small VM.
singularity shell /projects/sh-li-lab/singularity/xcmsrocker_latest.sif


(base) [siddia@sumner093 TestDataXCMS]$ singularity shell /projects/sh-li-lab/singularity/xcmsrocker_latest.sif
Singularity xcmsrocker_latest.sif:/projects/sh-li-lab/singularity/TestDataXCMS> Rscript xcms_test_script.R
Loading required package: BiocParallel
Loading required package: MSnbase
Loading required package: BiocGenerics


```
