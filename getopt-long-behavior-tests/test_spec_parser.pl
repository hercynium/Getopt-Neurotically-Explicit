#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

use lib qw( ../lib lib);

use Getopt::Nearly::Everything::SpecParser;
use Getopt::Nearly::Everything::SpecBuilder;

my $parser = Getopt::Nearly::Everything::SpecParser->new();
my $builder = Getopt::Nearly::Everything::SpecBuilder->new();

my @SPECS = (
    'foo',
    'foo!',
    'foo+',
    'foo:5',
    'foo:+',
    'foo:i',
    'foo:s',
    'foo=i@',
    'foo:s@',
    'foo|f|bar=s@{1,5}',
    'foo=i@{3}',
);

for my $spec ( @SPECS ) {
    my $attrs = $parser->parse( $spec );
    my $new_spec = $builder->build( %$attrs );
    print '' . Dumper { spec => $spec, attrs => $attrs, new_spec => $new_spec, OK => $spec eq $new_spec };
    print "\n";
}


