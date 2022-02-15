# /bin/env perl 

use strict;
use warnings;

my exam=$CURRENT_EXAM_COUNT
my series='6'      # 6 is the series number of the first mux sequence in most mux protocols 

# Call GE function "pathExtract" to get the path to what we hope is a MUX dicom
my $pathExtract = `pathExtract $exam $series 1`;
my @pathExtractArr = split(' ', $pathExtract);
my $dicomPath = $pathExtractArr[2];
print "$dicomPath";

# Check if file is from a MUX (hyperband) sequence (series must be MUX)
# Call GE scanner function "dumpDicomHeader" and store output to tmp file
my $headerDump = `/export/home/mx/host/bin/dumpDicomHeader $dicomPath`;
my $dumpFile = '/tmp/header_dump.txt'
open(FH, '>', $dumpFile) or die $!;
print FH $headerDump;
close(FH);

# Parse header dump by [i'\t'],[j'\n']
my $exam = `-lane 'print $F[5] if $. == 62' $dumpFile`;
my $project = `-lane 'print $F[5] if $. == 28' $dumpFile`;
my $scanning_protocol = `-lane 'print $F[5] if $. == 89' $dumpFile`;

my $series_desc = `-lane 'print $F[5] if $. == 29' $dumpFile`;
my $pulse_seq_name = `-lane 'print $F[5] if $. == 134' $dumpFile`;

my $subj_id = `-lane 'print $F[5] if $. == 61' $dumpFile`;
my $acqDate = `-lane 'print $F[5] if $. == 16' $dumpFile`;
my $subj_dob = `-lane 'print $F[5] if $. == 63' $dumpFile`;
my $subj_age = `-lane 'print $F[5] if $. == 65' $dumpFile`;
my $subj_gender = `-lane 'print $F[5] if $. == 64' $dumpFile`;
my $subj_weight = `-lane 'print $F[5] if $. == 66' $dumpFile`;
my $sequence_params = `-lane 'print $F[5] if $. == 71' $dumpFile`;
my $total_imgs = `-lane 'print $F[5] if $. == 205' $dumpFile`;

src=${file_parent}/*
dst="grayjoh@10.20.193.112:/MRI_DATA/coil-noise/scans/${exam}_0${series}_${month_day}"

# scp -pr ${src} ${dst}
# increase count by 5 to jump to roughly the next day (QA to be done daily)
export CURRENT_EXAM_COUNT=$((CURRENT_EXAM_COUNT+1))
