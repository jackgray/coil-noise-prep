#! /bin/perl

use warnings;
use File::Spec::Functions 'catfile';

# Get Current Exam
$currentExamFile = 'current_exam.txt';
open(FH, '<', $currentExamFile) or die $!;
$currentExam = int(<FH>);
close(FH);
print "\nStarting QC prep with exam $currentExam\n";

# INITIALIZATION
$currentSeries = 5;
$currentImage = 1;
$isMux = 'false';

$exam_ceiling = 3 + $currentExam;
$series_ceiling = 10 + $currentSeries;
$max_age = 1; # don't QC exams more than n days old

$pathExtract = "/export/home/service/cclass/pathExtract $currentExam $currentSeries $currentImage";
$dumpDicomHeader = "/export/home/mx/host/bin/dumpDicomHeader $dicomPath";
$dicmCompParser = "/export/home/sdc/bin/dicmCompParser -i $dicomPath";
$dateCommand = "date +%Y%m%d";
$date = `$dateCommand`;
print "\nToday's date: $date\n";

print "Starting loop to search for a recent MUX sequence.";
while ($isMux eq 'false') {
    print "\n\n\n\n----------------------------------------------------";
    print "\nChecking exam $currentExam series $currentSeries ...\n";
    $extractedPath = `$pathExtract`;    # Returns path with fluff
    my @extractedArr = split(' ', $extractedPath);
    $dicomPath = $extractedArr[2];      # Path without fluff
    print "Checking path:\n$dicomPath\n";
    $dicomParent = `dirname $dicomPath`;
    print "\nUsing parent path:\n$dicomParent\n";
    print "\nRetreiving header dump"
    $headerDump = `$dicmCompParser`;  # call GE shell command 'dicmCompParser'

    # Remove leading/trailing whitespaces -- doesn't work on GE system 
    sub trim($) {
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
    }

    # PARSE HEADER DUMP / CREATE HASH TABLE 
    @headers = split('#', $headerDump);    # Fieldnames start with #
    my %hash;
    foreach my $pair (@headers) {
        ($key, $val) = split('\n', $pair);
        @valLine = split(' ', $val);    # \t+ doesn't play nice here
        $value = $valLine[3];   # human-readable value is 3rd column
        $value =~ y/[]//d;      # Regex to remove brackets
        $hash{$key} = $value;       # Push k:v to hash table
    }
    $exam_no = $hash{' Patient ID'};
    $project = $hash{' Study Description'};
    $protocol = $hash{' Study Name'};
    $seq_name = $hash{' Pulse Sequence Name'};
    $series_desc = $hash{' Series Description'};
    $subj_id = $hash{" Patient's Name"};
    $acq_date = $hash{' Acquisition Date'};
    $series_no = $hash{" Series Number"};
    $sequence_params = $hash{' Scan Options'};

    # PRINT OUTPUT 
    print "``````````````````````HEADER OUTPUT````````````````````````"
    print "\nProject: $project";
    print "\nProtocol: $protocol";
    print "\nExam : $exam_no";
    print "\nSeries: $series_no";
    print "\nSeries Description: $series_desc";
    print "\nDate Acquired: $acq_date";
    print "\nSequence Parameters: $sequence_params\n";
    print "```````````````````````````````````````````````````````````"

    # Ensure exam is recent
    if ( $acq_date < $date - $max_age ) {
        if ( $acq_date == 0 ) {
            print "\nExam number doesn't exist yet. There may not be new exams with MUX files. Check back tomorrow.";
            exit 0;
	    }
	    print "\nCurrent exam $currentExam collected on $acq_date is too old.\nIncrementing exam number.";
        $currentExam++;     # Check next exam until it is recent
        next;
    } elsif (index($sequence_params, 'HYPERBAND') != -1) {
        print "\nSeries $series_no from exam $exam_no is a MUX file. Sending for cnqa.";
        $isMux = 'true';
        $currentExam++;	# increment for next QC check
        last;   # Exit loop if MUX file
    # Try next series for n tries
    } elsif ($currentSeries < $series_ceiling) {
        $currentSeries++;
        print "\nThis series is not multiband. Checking series $currentSeries";
        next;
    } elsif ($currentExam == $exam_ceiling) {
        print "\nExceeded retries looking for exam with MUX files. None found. Exiting";
        exit 0;
    } elsif ($currentSeries == $series_ceiling) {        
        print "\nExceeded max tries for exam $currentExam. Checking next exam.";
        $currentExam++;
        $currentSeries = 6;
	    $series_ceiling = $currentSeries + 5;
        next;
    # Explicitly exit loop on every condition to avoid infinite loop
    } else {
        print "Could not locate MUX file. Exiting.";
	exit 0;
    }
}

# FOUND MUX FILE
print "\n\nFound recent MUX series to quality check at $dicomParent \
\nAdding path to queue for compute server to pick up.";

# Ensure single line
chomp($dicomParent);
my $src = catfile($dicomParent, "*");
print "\nSource path:$src\n";
$exam_no =~ s/^\s+|\s+$//g;
my $dst = "/MRI_DATA/coil-noise/scans/${exam_no}_0${series_no}_${acq_date}";
print "Destination path: $dst\n";

# Write paths to first 100 dicoms to queue file
@allPaths = glob($src)
@nPaths = @allPaths[0..99];
$queueFile = "qc_queue.txt";
$destination = "qc_dst.txt";
open(FH, '>', $queueFile) or die;
    foreach @nPaths {
        print FH "console:$_";
    }
close(FH);

# Write updated exam number for next QC
open(FH, '>', $currentExamFile);
print FH $currentExam;
close(FH);
