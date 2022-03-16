#! /bin/env bash 

cnBase=/MRI_DATA/coil-noise
# # Copy source files queue defined on scanning console by prep script
# echo -e "\nRetrieving DICOM transfer queue and destination path files."
# rsync -havzpPrti --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' console:~/scripts/qc_*txt ${cnBase}/pipelines >> ./pullQA.log

# src=`cat ${cnBase}/pipelines/qc_queue.txt`
# srcFile=${cnBase}/pipelines/qc_queue.txt
# dst=`cat ${cnBase}/pipelines/qc_dst.txt`
# echo "Moving DICOMs from source: ${src} to destination ${dst}"

# # Create parent dir for data
# #dstParent=$(dirname ${dst})     # grab parent path of dicom files
# mkdir -p $dst             

# # Copy the data- read src paths from file list generated on console
# rsync -hvzPti --no-R --itemize-changes --stats -e 'ssh -o StrictHostKeyChecking=no' --files-from=${srcFile} console:/ ${dst} >> ./pullQA.log

# # Run cqna on copied data and redirect output to logfile
# output=`${cnBase}/pipelines/cnqa $dst`
output="No, we did not detect any coil noise \
We have detected 0 Coil Noise Image Frames (0.00%) at p>=0.99 \
We have detected 0 Other Type Image Frames (0.00%) \
We have detected 15 Clean Type Image Frames (100.00%)"

notCoilNoise="No, we did not detect any coil noise"

if [[ $output == *"$notCoilNoise"* ]]; then 
    curl -X POST -H 'Content-type: application/json' --data '{"text":"cqna detected noise in todays QA."}' https://hooks.slack.com/services/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
fi

# # Parse output, extract if there are 'Other' or 'Noise' frame types

# cleanImageCount=$(echo $output | grep -Po '(?<=We have detected ).*(?= Clean Type)')
# echo Clean images: $cleanImageCount
# cleanImageCount=$(echo $cleanImageCount | grep -Po '(?<=We have detected ).*(?= Clean Type)')
# echo Clean images: $cleanImageCount
# cleanImageCount=$(echo $cleanImageCount | grep -Po '(?<=We have detected ).*(?= Clean Type)')
# echo Clean images: $cleanImageCount
# otherImageCount=$(echo $output | grep -Po '(?<=We have detected ).*(?= Other Type)')
# echo Other images: $otherImageCount
# otherImageCount=$(echo $otherImageCount | grep -Po '(?<=We have detected ).*(?= Other Type)')
# echo Other images: $otherImageCount
# noiseImageCount=$(echo $output | grep -Po '(?<=We have detected ).*(?= Noise Type)')
# echo Noisy images: $noiseImageCount

# # Send slack notification when type other detected
# case $otherImageCount in
#     ''|*[!0-9]*) echo "No 'other' frames detected :)" ;;
#     *)  if [ "$otherImageCount" -gt 0 ]; then
#             curl -X POST -H 'Content-type: application/json' --data '{"text":"cqna detected frames of type "Other" in exam "'"$exam"'" series "'"$series"'". Go to "'"${dst}"'" to view these images."}' https://hooks.slack.com/services/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
#         fi ;;
# esac

# # Send slack notification when noise detected
# case $noiseImageCount in
#     ''|*[!0-9]*) echo "No noise :)" ;;
#     *)  if [ "$noiseImageCount" -gt 0 ]; then
#             curl -X POST -H 'Content-type: application/json' --data '{"text":"cqna detected noise in exam "'"$exam"'" series "'"$series"'". Go to "'"$dst"'" to view these images."}' https://hooks.slack.com/services/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
#         fi ;;
# esac

# # For testing: send slack notification when no noise detected
# case $cleanImageCount in
#     ''|*[!0-9]*) echo "Uh oh!" ;;
#     *)  if [ "$cleanImageCount" -gt 0 ]; then
#             curl -X POST -H 'Content-type: application/json' --data '{"text":"cqna detected NO noise in exam "'"$exam"'" series "'"$series"'". Go to "'"$dst"'" to view these images."}' https://hooks.slack.com/services/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
#         fi ;;
# esac
