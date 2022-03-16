Sends a multiband/hyperband DICOM series from GE MRI scanning console to be examined by the coil noise detector container.  
  
## Requires:   
  
    - dicmCompParser: built-program to extract header information from DICOMs.  
    - pathExtract: built-in program to locate the real path of a series by exam and sequence number arguments.  
    - slack_token.txt containing your slack webhook app URL/auth token
  
## cnqaPrep.pl (set to run on cron before cnqaPull below)  
  
    - To be run from GE scanning console, finds new mux sequence daily and exports paths to first n DICOM files in that series to qc_queue.txt. A separate file, qc_dst.txt, is used to store the directory structure for the sample data to go in.  
    - Uses exam number stored in current_exam.txt to keep track of exam number to check for MUX DICOMs. In theory, date checking logic should keep this number accurate, but check the accuracy of this number if the automation breaks.  
  
## cnqaPull.sh  (ensure cron runs after cnqaPrep)  
  
    - Because the destination does not allow passwordless ssh, this script will run on the destination server and use RSA authentication to rsync qc_queue.txt and qc_dst.txt.  
    - Then another rsync is run using  the --file-from=qc_queue.txt flag and the path extracted from qc_dst.txt as the destination.  
    - The command cnqa (wrapper for Docker container) is run using path from qc_dst.txt as the argument.