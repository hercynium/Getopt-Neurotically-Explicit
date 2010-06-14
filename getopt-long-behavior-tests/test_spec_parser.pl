#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

use lib qw( ../lib lib);

use Getopt::Nearly::Everything::SpecParser;

my $parser = Getopt::Nearly::Everything::SpecParser->new();



my @SPECS = (
    'foo',
    'foo!',
    'foo:i',
    'foo|f=s@{1,5}',
);


for my $spec ( @SPECS ) {
    my $spec_info = $parser->parse( $spec );
    print Dumper $spec, $spec_info;
    print "\n";
}


