# /bin/env perl 

use strict;
use warnings;
use DateTime;
use Tee;
use Try::Tiny;

sub main {
        # CURRENT_EXAM_COUNT should be an env variable and ideally always be
    # an exam of the current day or day before
    my exam=$CURRENT_EXAM_COUNT     # should be of type int
    my exam_tries = 3;              # Number of exams to check before giving up
    my series = 6       # 6 is the series number of the first mux sequence in most mux protocols 
                        # should be type: int
    my series_tries = 5     # number of series to check MUX sequences before moving to next exam
    my isMux = 'false'

    # Ensure sequence tested is not more than 2 days olde is a MUX dicom
    my $date = DateTime->strftime( '%Y%m%d' )   # date in same format as dicom header
    my $max_age = 2; # Number of days in the past to perform QC

    # Check the next n sequences for a MUX file, before checking the next m sessions and n sequences (YYYYMMdd)
    while ($isMux == 'false') {
    # ~ ~ ~ ~ ~ ~ PATH EXTRACTION ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        # Call GE function "pathExtract" to get the path to what we hope is a MUX dicom
        try {
            my $pathExtract = `pathExtract $exam $series 1`;
        } catch( $e ) {
            print("Error: $e \nCould not extract valid path from exam ${exam}. Moving back to previous exam number.")
            $exam--;
            try {
                my $pathExtract = `pathExtract $exam $series 1`
            } catch ( $err2 ) {
                print("Error: $e \nCould not extract valid path from exam ${exam}. Moving back to previous exam number.")
                $exam--;
                try {
                    my $pathExtract = `pathExtract $exam $series 1`;
                } catch( $err3 ) {
                    die("Path extraction failed for exam ${exam}. Is the CURRENT_EXAM_COUNT correct?")
                }
            }
        }
        my @pathExtractArr = split(' ', $pathExtract);
        my $dicomPath = $pathExtractArr[2];     # return is in the form "PATH EXTRACT </path/>"
        print "$dicomPath";

        # Check if file is from a MUX (hyperband) sequence (series must be MUX)
        # But first we have to:
        # Call GE scanner function "dumpDicomHeader" and store output to tmp file
        my $headerDump = `/export/home/mx/host/bin/dumpDicomHeader $dicomPath`;
        my $dumpFile = '/tmp/header_dump.txt'
        open(FH, '>', $dumpFile) or die $!;
        print FH $headerDump;
        close(FH);

        # Parse header dump by [i('\t')],[j('\n')]
        my $exam = `-lane 'print $F[5] if $. == 62' $dumpFile`;
        my $project = `-lane 'print $F[5] if $. == 28' $dumpFile`;
        my $scanning_protocol = `-lane 'print $F[5] if $. == 89' $dumpFile`;
        my $series_desc = `-lane 'print $F[5] if $. == 29' $dumpFile`;
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
            my $isMux = 'true';
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


    src="${file_parent}/*"
    dst="/MRI_DATA/coil-noise/scans/${exam}_0${series}_${acq_date}"

    `echo "${src} ${dst}"` >> $HOME/qc_queue.txt

    # Frequency to run QA test
    $CURRENT_EXAM_COUNT = $exam
    export my $CURRENT_EXAM_COUNT;

}

tee( $main, @logfile )
