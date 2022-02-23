Sends a multiband/hyperband dicom series to be examined by the coil noise detector

coil_noise_prep.pl -- to be run from GE scanning console, finds new mux sequence daily and exports its path to a text file.

pull_qaScans.sh -- Because the destination does not allow passwordless ssh, a script is run from the destination server to pull the paths defined in coil_noise_prep.pl from the text file, then scp from there.

Set the env variable 'CURRENT_EXAM_COUNT' on the scanning console. For any failures, first check that this value is correct.
Create a cron task on the scanning console machine to run the script 'coil-noise-prep.pl' nightly at 2am
Create a second cron task on the analysis server to run the script 'pull_qaScans.sh' nightly at 3am