#! /bin/env bash 

cnBase=/MRI_DATA/coil-noise
# Copy source files queue defined on scanning console by prep script
rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_queue.txt ${cnBase}/pipelines >> ./pullQA.log
# Copy destination path defined on scanning console by prep script
rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_queue.txt ${cnBase}/pipelines >> ./pullQA.log

src=`cat ${basePath}/pipelines/qc_queue.txt`
srcFile=${cnBase}/pipelines/qc_queue.txt
dst=`cat ${basePath}/pipelines/qc_dst.txt`
echo "Moving DICOMs from source: ${src} to destination ${dst}"

# Create parent dir for data
#dstParent=$(dirname ${dst})     # grab parent path of dicom files
mkdir -p $dst             

# Copy the data- read src paths from file list generated on console
rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' --files-from=${srcFile} ${dst} >> ./pullQA.log

# Run cqna on copied data and redirect output to logfile
${basePath}/pipelines/cnqa $dst 2>&1 $basePath/auto_cnqa.log

# Remove data if no error
