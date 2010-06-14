#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

use Getopt::Long qw( GetOptions );

GetOptions( 
    'foo|f=s' => \(my $foo = 'f'),
    'bar|b:s' => \(my $bar = 'b'),
    'cad|c=s%' => \(my $cad),
) or die "Error processing options\n";

print "FOO: $foo\n";
print "BAR: $bar\n";
print "CAD: ", Dumper $cad;

