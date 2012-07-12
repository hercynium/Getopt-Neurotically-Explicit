#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;

our $CLASS;

BEGIN {
  $CLASS = 'Getopt::Nearly::Everything';
  use_ok($CLASS);
}

my @TEST_SPECS = (
    'foo|f!',
    'foo|f+',
    'foo|f=i',
    'foo|f:i',
    'foo|f:s',
    'foo',
    'foo|f|bar',
    'foo|f',
    'foo|f:+',
    'foo|f:5',
    'foo|f|g|h',
    'foo|b=s@{1,}',
    'foo|b=s@{,5}',
    'foo|b=s%'
);


my $gone = new_ok($CLASS);

for my $orig_spec ( @TEST_SPECS ) {
    $gone->add_opt( spec => $orig_spec, name => 'bar' );
    my $new_spec = $gone->opt( 'bar' )->spec;

    is $new_spec, $orig_spec, "round tripped spec [$orig_spec]";
    #diag Dumper $params;
}

done_testing;

