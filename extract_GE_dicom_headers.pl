#!/bin/perl

use strict;
use warnings;

my ($exam, $series) = @ARGV;

my $pathExtract = `pathExtract $exam $series 1`;
my @pathExtractArr = split(' ', $pathExtract);
my $dicomPath = $pathExtractArr[2];
print "$dicomPath";

my $headerDump = `/export/home/mx/host/bin/dumpDicomHeader $dicomPath`;
print "$headerDump";

my $testField = `-lane 'print $F[$j-1] if $. == $i' -- -i=5 -j=3 sample_data.txt`