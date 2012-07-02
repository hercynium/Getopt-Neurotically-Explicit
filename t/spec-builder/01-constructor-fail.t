#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
  
BEGIN {
    eval "use Test::Exception";
    plan( skip_all => "Test::Exception needed" ) if $@;
}

my $bad_spec_info = { name => 'foo', aliases => '' };
my @BAD_PARAMS = (
    [ $bad_spec_info ],
    [ 'foo' ],
    [ debug => '1', bar => 'baz' ],
    [ 'foo', $bad_spec_info ],
);

### each param list is a test, plus use_ok()
plan( tests => scalar @BAD_PARAMS + 1 );


my $CLASS = 'Getopt::Nearly::Everything::SpecBuilder';

use_ok( $CLASS ) or die "Couldn't compile [$CLASS]\n";

### make sure constructor dies when given invalid params
for my $params ( @BAD_PARAMS ) {
    my $test_descr = "new() dies with invalid parameters";
    dies_ok( sub { $CLASS->new( @{ $params } ) }, $test_descr );
}


