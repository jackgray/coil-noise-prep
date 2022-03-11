#! /bin/env bash 

basePath=/MRI_DATA/coil-noise

scp sdc@156.111.80.30:$HOME/qc_queue.txt ${basePath}/scans > ${basePath}/scans/qcXfr.log

src=`cat ${basePath}/scans/qc_queue.txt | cut -d' ' -f1`
dst=`cat ${basePath}/scans/qc_queue.txt | cut -d' ' -f2`

# Create dirs for data
dstParent=$(dirname ${dst})
mkdir -p $dstParent

# Copy the data
scp sdc@156.111.80.30:$src $dst

# Run cqna on copied data
${basePath}/pipelines/cqna $dst 2>&1 $basePath/auto_cqna.log

# Remove data if no error