#! /bin/env bash 

cnBase=/MRI_DATA/coil-noise
# Copy source files queue defined on scanning console by prep script
echo -e "\nRetrieving DICOM transfer queue and destination path files."
rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_*txt ${cnBase}/pipelines >> ./pullQA.log

src=`cat ${cnBase}/pipelines/qc_queue.txt`
srcFile=${cnBase}/pipelines/qc_queue.txt
dst=`cat ${cnBase}/pipelines/qc_dst.txt`
echo "Moving DICOMs from source: ${src} to destination ${dst}"

# Create parent dir for data
#dstParent=$(dirname ${dst})     # grab parent path of dicom files
mkdir -p $dst             

# Copy the data- read src paths from file list generated on console
rsync -hvzPti --no-R --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' --files-from=${srcFile} console:/ ${dst} >> ./pullQA.log

# Run cqna on copied data and cappture output
output=`${cnBase}/pipelines/cnqa $dst`
# String to match
notCoilNoise="No, we did not detect any coil noise"
# Send Slack notification if noise detected
if [[ $output == *"$notCoilNoise"* ]]; then 
    curl -X POST -H 'Content-type: application/json' --data '{"text":"cqna detected noise in todays QA."}' $SLACK_TOKEN
fi