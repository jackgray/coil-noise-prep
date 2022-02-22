#! /bin/env perl

use strict;
use warnings;

package extractHeaders;

sub new {
    
}

my ($exam, $series) = @ARGV;

my $pathExtract = `pathExtract $exam $series 1`;
my @pathExtractArr = split(' ', $pathExtract);
my $dicomPath = $pathExtractArr[2];
print "$dicomPath";

# Call GE scanner function "dumpDicomHeader" and store output to tmp file
my $headerDump = `/export/home/mx/host/bin/dumpDicomHeader $dicomPath`;
my $dumpFile = '/tmp/header_dump.txt'
open(FH, '>', $dumpFile) or die $!;
print FH $headerDump;
close(FH);

# parse header dump by [i'\t'],[j'\n']
our $exam = `-lane 'print $F[5] if $. == 62' $dumpFile`;
our $project = `-lane 'print $F[5] if $. == 28' $dumpFile`;
our $scanning_protocol = `-lane 'print $F[5] if $. == 89' $dumpFile`;

our $series_desc = `-lane 'print $F[5] if $. == 29' $dumpFile`;
our $pulse_seq_name = `-lane 'print $F[5] if $. == 134' $dumpFile`;

our $subj_id = `-lane 'print $F[5] if $. == 61' $dumpFile`;
our $acqDate = `-lane 'print $F[5] if $. == 16' $dumpFile`;
our $subj_dob = `-lane 'print $F[5] if $. == 63' $dumpFile`;
our $subj_age = `-lane 'print $F[5] if $. == 65' $dumpFile`;
our $subj_gender = `-lane 'print $F[5] if $. == 64' $dumpFile`;
our $subj_weight = `-lane 'print $F[5] if $. == 66' $dumpFile`;
our $sequence_params = `-lane 'print $F[5] if $. == 71' $dumpFile`;
our $total_imgs = `-lane 'print $F[5] if $. == 205' $dumpFile`;

# Print formatted output of only info we care about
1;