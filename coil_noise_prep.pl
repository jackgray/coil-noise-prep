#! /bin/perl 

use strict;
use warnings;
# use Tee;
use Try::Tiny;

my @logfile = "~/coil_noise_prep.log";
sub main {
    # CURRENT_EXAM_COUNT should be an env variable and ideally always be
    # an exam of the current day or day before
    my  $pathExtract='/export/home/service/cclass/pathExtract';
    $exam=`echo $CURRENT_EXAM_COUNT`;     # should be of type int
    print $exam;
    $exam_tries = 3;              # Number of exams to check before giving up
    my $series = 6;       # 6 is the series number of the first mux sequence in most mux protocols 
                        # should be type: int
    my $series_tries = 5;     # number of series to check MUX sequences before moving to next exam
    my $isMux = 'false';

    # Ensure sequence tested is not more than n days old 
    my $date = `date +%Y%m%d`;   # date in same format as dicom header
    my $max_age = 2; # Number of days in the past to perform QC

    print "starting loop";
    # Check the next n sequences for a MUX file, before checking the next m sessions and n sequences (YYYYMMdd)
    while ($isMux == 'false') {
    # ~ ~ ~ ~ ~ ~ PATH EXTRACTION ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
    
        # Call GE function "pathExtract" to get the path to what we hope is a MUX dicom
        try {
            $extractedPath = `$pathExtract $exam $series 1`;
        # This command will fail if the exam number doesn't exist; assume that the env variable $CURRENT_EXAM_COUNT is too far ahead and rewind
        } catch {
            print("Error: \nCould not extract valid path from exam ${exam}. Moving back to previous exam number.");
            $exam--;
            try {
                $extractedPath = `$pathExtract $exam $series 1`;
            } catch {
                print("Error: \nCould not extract valid path from exam ${exam}. Moving back to previous exam number.");
                $exam--;
                try {
                    my $extractedPath = `$pathExtract $exam $series 1`;
                } catch {
                    die("Path extraction failed for exam ${exam}. Is the CURRENT_EXAM_COUNT correct?");
                }
            }
        }

        my @pathExtractArr = split(' ', $pathExtract);
        our $dicomPath = $pathExtractArr[2];     # return is in the form "PATH EXTRACT </path/>"
        print "dicom path: $dicomPath";                     # should be path of a single dicom file of a larger series
        our $file_parent=`dirname ${dicomPath}`;
        print "Found mux scans to quality check at $file_parent\n";


        # Check if file is from a MUX (hyperband) sequence (series must be MUX)
        # But first we have to:
        # Call GE scanner function "dumpDicomHeader" and store output to tmp file
        our $headerDump = `/export/home/mx/host/bin/dumpDicomHeader $dicomPath`;
        our $dumpFile = '/tmp/header_dump.txt';
        print $headerDump;
        open(FH, '>', '/tmp/header_dump.txt') or die $!;
        print FH ${headerDump};
        close(FH);

        # Parse header dump by [i('\t')],[j('\n')]
        $exam_no = `-lane 'print $F[5] if $. == 62' /tmp/header_dump.txt`;
        $project = `-lane 'print $F[5] if $. == 28' ${dumpFile}`;
        our $scanning_protocol = `-lane 'print $F[5] if $. == 89' ${dumpFile}`;
        our $series_desc = `-lane 'print $F[5] if $. == 29' ${dumpFile}`;
        my $pulse_seq_name = `-lane 'print $F[5] if $. == 134' $dumpFile`;
        my $subj_id = `-lane 'print $F[5] if $. == 61' $dumpFile`;
        my $acq_date = `-lane 'print $F[5] if $. == 16' $dumpFile`;
        my $subj_dob = `-lane 'print $F[5] if $. == 63' $dumpFile`;
        my $subj_age = `-lane 'print $F[5] if $. == 65' $dumpFile`;
        my $subj_gender = `-lane 'print $F[5] if $. == 64' $dumpFile`;
        my $subj_weight = `-lane 'print $F[5] if $. == 66' $dumpFile`;
        my $sequence_params = `-lane 'print $F[5] if $. == 71' $dumpFile`;
        my $total_imgs = `-lane 'print $F[5] if $. == 205' $dumpFile`;
        my $series_no = `-lane 'print $F[5] if $. == 196' $dumpFile`;
    
        # Retry on next exam if older than x days, reset series count
        if ( $acq_date < $date - $max_age )  {
            $exam++;
            $series = 6;
            next;
        # Is sequence MUX/Hyperband?
        } elsif (index($sequence_params, 'HYPERBAND') != -1) {
            print "$sequence_params contains 'HYPERBAND'. Using sequence $series_no : $series_desc "
            our $isMux = 'true';
            last;       # if not too old, and is Mux, break from while loop
        } elsif ($series < $series_tries + $series) {
            # if not too old but not MUX, increment series, skip to beginning of loop
            $series++;  # increment series and retry
            next;
        } elsif ($exam > $exam_tries + $exam) {
            $exam++;
            $series = 6;    # Reset series count if moving to next exam
            next;
        } else {
            print "Tried $series_tries series from $exam_tries exams and found no MUX data to check. Skipping this round of QC."
            exit 0;     # Exit after exceeding retries
        }
    }
    # Loop exits once MUX sequence is found or after max tries to find one

    # If we made it to this point, we successfully located a recent mux sequence to QC
    print "Found mux scans to quality check at $file_parent\n";

    # Set transfer paths
    my $src="${file_parent}/*.dcm";
    my $dst="/MRI_DATA/coil-noise/scans/${exam_no}_0${series}_${acq_date}";

    # Store src + dst paths to file to be discovered by server
    `echo "${src} ${dst}"` > '~/qc_queue.txt';

    # Increment exam count for next QC
    my $CURRENT_EXAM_COUNT = $exam++;
    `bash export $CURRENT_EXAM_COUNT`;

}

main();
