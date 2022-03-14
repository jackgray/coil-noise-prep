#! /bin/perl

use warnings;
use File::Spec::Functions 'catfile';

# Get Current Exam
$currentExamFile = 'current_exam.txt';
open(FH, '<', $currentExamFile) or die $!;
$currentExam = int(<FH>);
close(FH);
print "Starting QC with exam $currentExam\n";

# INITIALIZATION
# $currentExam = 21400;
$exam_tries = 3 + $currentExam;
$currentSeries = 5;
$currentImage = 1;
$series_tries = 10 + $currentSeries;
$isMux = 'false';
$dateCommand = "date +%Y%m%d";
$date = `$dateCommand`;
print "Today's date: $date\n";
$max_age = 1; # don't QC exams more than 2 days old
print "starting loop";

while ($isMux eq 'false') {
    print "\n\n\n\n----------------------------------------------------";
    $pathExtract = "/export/home/service/cclass/pathExtract $currentExam $currentSeries $currentImage";
    print "\nChecking exam $currentExam series $currentSeries ...\n";
    $extractedPath = `$pathExtract`;
    my @extractedArr = split(' ', $extractedPath);
    #print "@extractedArr";
    $dicomPath = $extractedArr[2];
    print "Checking path:\n$dicomPath\n";
    $dirnameCommand = "dirname $dicomPath";
    $dicomParent = `dirname $dicomPath`;
    # $dicomParent = chomp($dicomParent);
    print "Using parent path:\n$dicomParent\n";
    $dumpDicomHeader = "/export/home/mx/host/bin/dumpDicomHeader $dicomPath";
    $dicmCompParser = "/export/home/sdc/bin/dicmCompParser -i $dicomPath";
    $dumpFile = "header_dump.txt";
    $headerDump = `$dicmCompParser`;  # call GE shell command 'dicmCompParser'
    # print $headerDump;


    @headers = split('#', $headerDump);
    my %hash;
    foreach my $pair (@headers) {
        # print "Adding $pair to hash\n";
        ($key, $val) = split('\n', $pair);
        @valLine = split(' ', $val);
        $value = $valLine[-1];
        $key =~ s/^\s+//;
        $key =~ s/\s+$//;
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
        $value =~ tr/[]//dr;
        # $value = $valEl =~ s/^\s+|\s+$//g;
        print "Key: $key\n";
        print "Value: $value\n";
        # $headers{ $key } = $value;
        $hash{$key} = $value;
    }
    print "$hash{'Study Description'}";


    # $fuu = $hash{'Study Description'} ;
    # print "$fuu";
    # $lineOne = $headerLines[20];
    # print "FFFF: $lineOne";
    # $reg = ( $headerDump =~ m/\#([\s\S]*)\(/g );

    # $headerLabels = split('(', $headerLines)
    # $item = $headerLines[9];
    # print "\n\n\n\nmatched: $item";
    # print for @headerLines;
}
#     # WRITE TO FILE
#     open(FH, '>', $dumpFile) or die $!;
#     print FH $headerDump;
#     close(FH);

#     # PARSE HEADER
#     my @dumpArr;
#     open (FH, '<', $dumpFile) or die $!;
#     while (<FH>) {
#         #print "row: $_";
#         chomp;
#         my @row = split("\t+");
#         print "$row[1]"
#         push @dumpArr, $row[1];
#     }
#     close(FH);

    # our $exam_no = $headers{'Study Desc'};
    our $project = $headers{'Study Description'};
#     our $protocol = $dumpArr[88];
#     our $seq_name = $dumpArr[132];
#     our $series_desc = $dumpArr[28];
#     our $subj_id = $dumpArr[59];
#     our $acq_date = $dumpArr[14];
#     our $series_no = $dumpArr[195];
#     our $sequence_params = $dumpArr[70];

    # print "\nProject: $project";
#     print "\nExam : $exam_no";
#     print "\nSeries: $series_no";
#     print "\nSeries Description: $series_desc";
#     print "\nDate Acquired: $acq_date";
#     print "\nSequence Parameters: $sequence_params\n";

#     if ( $acq_date < $date - $max_age ) {
#         if ( $acq_date == 0 ) {
#             print "Exam number doesn't exist yet. There may not be new exams with MUX files. Check back tomorrow.";
#             exit 0;
# 	}
# 	print "Current exam $currentExam collected on $acq_date is too old.\nIncrementing exam number.";
#         $currentExam++;
#         $currentSeries = 6;
#         next;
#     } elsif (index($sequence_params, 'HYPERBAND') != -1) {
#         print "\nSeries $series_no from exam $exam_no is a MUX file. Sending for cnqa.";
#         my $isMux = 'true';
#         $currentExam++;	# increment for next QC check
#         last;
#     } elsif ($currentSeries < $series_tries) {
#         $currentSeries++;
#         print "This series is not multiband. Checking series $currentSeries";
#         next;
#     } elsif ($currentExam == $exam_tries) {
#         print "Exceeded retries looking for exam with MUX files. None found. Exiting";
#         exit 0;
#     } elsif ($currentSeries == $series_tries) {        
#         print "Exceeded max tries for exam $currentExam. Checking next exam.";
#         $currentExam++;
#         $currentSeries = 6;
# 	$series_tries = $currentSeries + 5;
#         next;
#     } else {
#         print "Could not locate MUX file. Exiting.";
# 	exit 0;
#     }
# }

# print "\n\nFound recent MUX series to quality check at $dicomParent Adding path to queue for compute server to pick up.";

# chomp($dicomParent);
# my $src = catfile($dicomParent, "*");
# print "\nSource path:$src\n";
# $exam_no =~ s/^\s+|\s+$//g;
# my $dst = "/MRI_DATA/coil-noise/scans/${exam_no}_0${series_no}_${acq_date}";
# print "Destination path: $dst\n";

# # Write paths to queue file
# my $queueFile = "qc_queue.txt";
# open(FH, '>', $queueFile) or die;
# print FH "$src $dst";
# close(FH);

# # Write updated exam number for next QC
# open(FH, '>', $currentExamFile);
# print FH $currentExam;
# close(FH);
