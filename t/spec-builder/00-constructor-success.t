#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# eventually update plan to calculate test count
# ...see constructor-fail script for what I mean
plan( tests => 7 );

my $CLASS = 'Getopt::Nearly::Everything::SpecBuilder';

use_ok( $CLASS ) or die "Couldn't compile [$CLASS]\n";

### test constructor - these should succeed:

my $spec_info = { name => 'foo', data_type => 'flag' };
my @GOOD_PARAMS = (
    [],
    [ $spec_info ],
);

for my $params ( @GOOD_PARAMS ) {
    my $test_descr = "new() succeeds with valid parameters:";
    isa_ok( $CLASS->new( @{ $params } ), $CLASS, $test_descr );
}

TODO: {
    local $TODO = "Extended param parsing not yet finished, would cause die in tests";

    my @MORE_GOOD_PARAMS = (
        [ $spec_info, debug => 1 ],
        [ debug => 1, $spec_info ],
        [ spec => $spec_info, debug => 1 ],
        [ debug => 1, spec => $spec_info ],
    );

    todo_skip $TODO, scalar @MORE_GOOD_PARAMS;

    for my $params ( @MORE_GOOD_PARAMS ) {
        my $test_descr = "new() succeeds with valid parameters";
        isa_ok( $CLASS->new( @{ $params } ), $CLASS, $test_descr );
    }
}

