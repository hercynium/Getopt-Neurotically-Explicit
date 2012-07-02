#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use Test::Exception";
    plan( skip_all => "Test::Exception needed" ) if $@;
}

my @BAD_PARAMS = (
    [ 'foo', 'bar' ],
    [ 'foo', bar => 'baz' ],
### These currently do not cause a failure, but should
#    [ { bar => 'baz' } ],
#    [ 'foo', { bar => 'baz' } ],
    [ debug => '1', bar => 'baz' ],
    [ 'foo', { spec => 'bar' } ],
);

### each param list is a test, plus use_ok()
plan( tests => @BAD_PARAMS + 1 );

my $CLASS = 'Getopt::Nearly::Everything::SpecParser';

use_ok( $CLASS ) or die "Couldn't compile [$CLASS]\n";

### make sure constructor dies when given invalid params
for my $params ( @BAD_PARAMS ) {
    my $test_descr = "new() dies with invalid parameters";
    dies_ok( sub { $CLASS->new( @{$params} ) }, $test_descr );
}

