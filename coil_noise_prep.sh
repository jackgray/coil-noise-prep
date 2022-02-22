#!/bin/bash

exam=$CURRENT_EXAM_COUNT
series='6'      # 6 is the series number of the first mux sequence in most mux protocols 
headerOutpu=`perl ./extract_GE_dicom_headers.pl ${exam} ${series}`


file_parent=`echo $single_image_path | cut -f 3 -d ' ' | cut -f 1-8 -d '/'`





src=${file_parent}/*
dst="grayjoh@10.20.193.112:/MRI_DATA/coil-noise/scans/${exam}_0${series}_${month_day}"




# scp -pr ${src} ${dst}

export CURRENT_EXAM_COUNT=$((CURRENT_EXAM_COUNT+1))
