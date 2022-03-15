#! /bin/env bash 

cnBase=/MRI_DATA/coil-noise
# Copy source files queue defined on scanning console by prep script
echo -e "\nRetrieving DICOM transfer queue file."
rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_*txt ${cnBase}/pipelines >> ./pullQA.log
# Copy destination path defined on scanning console by prep script
# echo -e "\nRetrieving destination path defined by console's QA prep."
# rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_dst.txt ${cnBase}/pipelines >> ./pullQA.log

src=`cat ${cnBase}/pipelines/qc_queue.txt`
srcFile=${cnBase}/pipelines/qc_queue.txt
dst=`cat ${cnBase}/pipelines/qc_dst.txt`
echo "Moving DICOMs from source: ${src} to destination ${dst}"

# Create parent dir for data
#dstParent=$(dirname ${dst})     # grab parent path of dicom files
mkdir -p $dst             

# Copy the data- read src paths from file list generated on console
rsync -hvzPti --no-R --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' --files-from=${srcFile} console:/ ${dst} >> ./pullQA.log

# Run cqna on copied data and redirect output to logfile
${cnBase}/pipelines/cnqa $dst 2>&1 $cnBase/pipelines/auto_cnqa.log

# Remove data if no error
