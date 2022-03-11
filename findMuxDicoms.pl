#! /bin/perl

use warnings;

# Get Current Exam
$currentExamFile = 'current_exam.txt';
open(FH, '<', $currentExamFile) or die $!;
$currentExam = <FH>;
close(FH);
print "Starting QC with exam $currentExam";

# INITIALIZATION
$currentExam = 21400;
$exam_tries = 3;
$currentSeries = 6;
$currentImage = 1;
$series_tries = 5;
$isMux = 'false';
$date = system("date +%Y%m%d");
$max_age = 2; # don't QC exams more than 2 days old
$pathExtract = "/export/home/service/cclass/pathExtract $currentExam $currentSeries $currentImage";
print "starting loop";

#while ($isMux == 'false') {

$extractedPath = `$pathExtract`;
my @extractedArr = split(' ', $extractedPath);
#print "@extractedArr";
$dicomPath = $extractedArr[2];
print $dicomPath;
$dirnameCommand = "dirname $dicomPath";
$dicomParent = `$dirnameCommand`;
print $dicomParent;
$dumpDicomHeader = "/export/home/mx/host/bin/dumpDicomHeader $dicomPath";
$dumpFile = "header_dump.txt";
$headerDump = `$dumpDicomHeader`;  # call shell command 'dumpDicomHeader'
print $headerDump;

# WRITE TO FILE
open(FH, '>', $dumpFile) or die $!;
print FH $headerDump;
close(FH);

# PARSE HEADER
my @dumpArr;
open (FH, '<', $dumpFile) or die $!;
while (<FH>) {
    #print "row: $_";
    chomp;
    my @row = split("\t+");
    push @dumpArr, $row[1];
}
close(FH);

my $exam_no = $dumpArr[61];
my $project = $dumpArr[27];
my $protocol = $dumpArr[88];
my $seq_name = $dumpArr[132];
my $series_desc = $dumpArr[27];
my $subj_id = $dumpArr[59];
my $acq_date = $dumpArr[14];
my $series_no = $dumpArr[195];
my $sequence_params = $dumpArr[71];

print "Project: $project"
print "Exam : $exam_no";
print "Series: $series_no";
print "Date Acquired: $acq_date";

if ( $acq_date < $date - $max_age ) {
    $currentExam++;
    $currentSeries = 6;
    next;
} elsif (index($sequence_params, 'HYPERBAND') != -1) {
    my $isMux = 'true';
    last;
} elsif ($series < $series_tries + $series) {
    $currentSeries++;
    next;
} elsif ($currentExam > $exam_tries + $currentExam) {
    $exam++;
    $currentSeries = 6;
    next;
} else {
    exit 0;
}

my $src = "${dicomParent}/*.dcm*";
my $dst = "/MRI_DATA/coil-noise/scans/${exam_no}_0${series_no}_${acq_date}";

# Write paths to queue file
my $queueFile = "~/qc_queue.txt";
open(FH, '>', $queueFile) or die;
print FH "$src $dst";
close(FH);

# Write updated exam number for next QC
open(FH, '>', $currentExamFile);
print FH $currentExam;
close(FH);
