#! /bin/python
# Use python2


from os import path
from datetime import datetime as dt
from os.Popen import Popen

home = path.expanduser("~")
# with open(path.join(home, 'current_exam.txt')) as f:
#     currentExam = f.read()
currentExam = 21400;
print("Starting QC with exam ", currentExam, '\n')

exam_tries = 4;
series_tries = 6;
max_age = 1;    # days old an exam can be to run QC

todaysDate = dt.today().strftime("%Y%m%d")

isMux = False;
currentSeries = 6;
currentImage = 1;

pathExtractCommand = "/export/home/service/cclass/pathExtract"
dumpDicomHeaderCommand = "/export/home/mx/host/biin/dumpDicomHeader"

while (isMux == False):
    print("\nChecking exam ", currentExam, " series ", currentSeries)
    
    try:
        extractedPath = Popen(pathExtractCommand, currentExam, currentSeries, currentImage, shell=True)
    except:
        print("Error: Could not extract valid path from exam ", currentExam, \
            " series ", currentSeries, "\nGoing back one exam.")
        currentExam-- ;
        try:
            extractedPath = Popen(dumpDicomHeaderCommand, currentExam, currentSeries, currentImage, shell=True)
        except:
             print("Error: Could not extract valid path from exam ", currentExam, \
            " series ", currentSeries, "\nGoing back one exam.")
            currentExam-- ;
            try:
                extractedPath = Popen(dumpDicomHeaderCommand, currentExam, currentSeries, currentImage, shell=True)
            except:
                print("Error: Could not extract valid path from exam ", currentExam, \
                " series ", currentSeries, "\nGoing back one exam.")
                currentExam-- ;                
            
    extractedArr = split(extractedPath, ' ')
    dicomPath = extractedArr[2]
    print("Checking path ", dicomPath)
    dicomParent = path.dirname(dicomPath)
    print("Using parent path: ", dicomParent)
    
    headerDump = Popen(dumpDicomHeaderCommand, dicomPath)
    headerArr = headerDump.split("\n")
    
    exam_no = headerArr[5][61]
    project = headerArr[5]
    acq_date = headerArr[5]
    sequence_params = headerArr[5]
    
    print("\nProject: ", project)
    print"\nExam: ", exam_no)
    print("\nDate Acquired: ", acq_date)
    print("\nSequence Parameters: ", sequence_params)
    
    if acq_date < todaysDate - max_age:
        print("\nCurrent exam ", currentExam, " collected on ", acq_date, " is too old. \
            \nIncrementing to next exam")