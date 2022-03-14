#! /bin/env bash 

basePath=/MRI_DATA/coil-noise

scp sdc@156.111.80.20:~/scripts/qc_queue.txt ${basePath}/pipelines

src=`cat ${basePath}/pipelines/qc_queue.txt | cut -d' ' -f1`
dst=`cat ${basePath}/pipelines/qc_queue.txt | cut -d' ' -f2`
echo "Moving DICOMs from source: ${src} to destination ${dst}"

# Create parent dir for data
#dstParent=$(dirname ${dst})     # grab parent path of dicom files
mkdir -p $dst             

# Copy the data
scp sdc@156.111.80.20:$src $dst

# Run cqna on copied data and redirect output to logfile
${basePath}/pipelines/cnqa $dst 2>&1 $basePath/auto_cnqa.log

# Remove data if no error
