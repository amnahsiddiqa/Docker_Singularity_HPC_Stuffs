
## Install on Mac

Reference:
https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/release/latest/html/install_mac_bin.html

1-download Dmg
2- drag it to applications folder
3- run following commands
```
cd /Applications/OpenMS-2.6.0
sudo xattr -r -d com.apple.quarantine *
export OPENMS_TOPP_PATH=/Applications/OpenMS-2.6.0
source ${OPENMS_TOPP_PATH}/.TOPP_bash_profile
```

##Run on Mac

Following bash script
- Perform FeatureFinderMetabo
- compress chrom_mzML files

```
#!/bin/zsh
for file in mzmlfiles/*.mzML
  do FeatureFinderMetabo -in $file -out ${file/.mzML/.featureXML} -out_chrom ${file/.mzML/_chrom.mzML} \
  -algorithm:common:chrom_fwhm 2 -algorithm:mtd:mass_error_ppm 2 -algorithm:mtd:min_trace_length 1
done

rm mzmlfiles/*.featureXML
xz mzmlfiles/*_chrom.mzML
```


## Run using Docker


 - there is this docker of OpenMS by Shuzhao
- pwd is your current working directory pointer for mounting which should be mounted to tmp directory within docker

```
docker pull  shuzhao/openms
docker run -it --mount src="$(pwd)",target=/tmp,type=bind shuzhao/openms
```

Note; Watch there shouldn't be any spaces between source and target



# Run OpenMS on Sumner

(have included small test data  and scripts in there (/projects/sh-li-lab/singularity) as well)

First thing you need to do is:
```
ssh login.******.***.org
#/home/siddia
#/projects/sh-li-lab


#Load singularity module on Sumner
#this is for interactive session ; we use sbatch  for submitting batch jobs I have mentioned in upcoming below cells ;
srun --pty -q batch bash -I
module load singularity

#you might want check if its loaded
which singularity
singularity –version
singularity --help


```

-  for your own workspace ; start with pulling the image from dockerhub first;

- Shuzhao's image has OpenMS 2.5 version which I needed as of yet
- on Lab workspace in Sumner I have all relevant sif files at this location  ; **/projects/sh-li-lab/singularity**

```
#pull  image form dockerhub
singularity pull docker://shuzhao/openms:latest
#you should be able to see the relevant sif file ;Singularity  produces immutable images in the Singularity Image File (SIF) format.

```


There are gonna be two ways which we might want use it;

## Interactive session:
 one is interactive for whatever your reason is ; you can spawn into the shell of your container ;
 Running singularity shell allows you to spawn a new shell within your container and interact with it as though it were a small VM.

no worries about mount volumes etc ;

```
(base) [siddia@sumner098 TestDataOpenMS]$ module load singularity
(base) [siddia@sumner098 TestDataOpenMS]$ singularity shell /projects/sh-li-lab/singularity/openms_latest.sif

```


inside the shell run your script now
```
Singularity openms_latest.sif:/projects/sh-li-lab/singularity/TestDataOpenMS> ./openms_shellscript_AS.sh
Progress of 'loading spectra list':
-- done [took 0.36 s (CPU), 0.36 s (Wall)] --
Progress of 'loading chromatogram list':
-- done [took 0.00 s (CPU), 0.00 s (Wall)] --
Progress of 'mass trace detection':

```
openms_shellscript_AS.sh
```

#!/bin/bash


for file in mzmlfiles/*.mzML
  do FeatureFinderMetabo -in $file -out ${file/.mzML/.featureXML} -out_chrom ${file/.mzML/_chrom.mzML} \
  -algorithm:common:chrom_fwhm 2 -algorithm:mtd:mass_error_ppm 2 -algorithm:mtd:min_trace_length 1
done

rm mzmlfiles/*.featureXML
xz mzmlfiles/*_chrom.mzML
```


## Batch job
```
#The location of image I am gonna use with test data is /projects/sh-li-lab/singularity/TestDataOpenMS

(base) [siddia@sumner098 TestDataOpenMS]$ sbatch runopenms.sh
Submitted batch job 10024088
```


 runopenms.sh
```
#!/bin/bash
#SBATCH --job-name=openms
#SBATCH --mail-type=END
#SBATCH -p compute
#SBATCH -q batch
#SBATCH -t 24:23:00
#SBATCH --mem=2000
#SBATCH -o slurm.messge.%j.out # STDOUT
#SBATCH -e slurm.message.%j.err # STDERR

module load singularity

singularity exec /projects/sh-li-lab/singularity/openms_latest.sif ./openms_script_AS.sh

```

openms_script_AS.sh
```
#!/bin/bash
#SBATCH --job-name=openms
#SBATCH --mail-type=END
#SBATCH -p compute
#SBATCH -q batch
#SBATCH -t 24:23:00
#SBATCH --mem=2000

module load singularity

for file in mzmlfiles/*.mzML
  do FeatureFinderMetabo -in $file -out ${file/.mzML/.featureXML} -out_chrom ${file/.mzML/_chrom.mzML} \
  -algorithm:common:chrom_fwhm 2 -algorithm:mtd:mass_error_ppm 2 -algorithm:mtd:min_trace_length 1
done

rm mzmlfiles/*.featureXML
xz mzmlfiles/*_chrom.mzML

```

Note: Keep resources to your need in batch files.
