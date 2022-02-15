#!/bin/bash

# Utilize the GE tool at /export/home/mx/host/bin/dumpDicomHeader

# Assign the following: isMux(bool), studyDate, project, seriesNo, exam, imageCount, protocolDesc, irb, coilType, subjID, patientSex, patientAge, patientDOB)

dump=`echo /export/home1/sdc`

dicomPath=$(pathExtract 21293 6 1)

awk -v dump="$(/export/home/mx/host/bin/dumpDicomHeader $(pathExtract 21293 6 1))" 'BEGIN {print dump}'