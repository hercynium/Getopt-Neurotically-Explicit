#!perl -T

use strict;
use warnings;
use Test::More;

# eventually update plan to calculate test count
# ...see constructor-fail script for what I mean
plan( tests => 12 );

my $CLASS = 'Getopt::Nearly::Everything::SpecParser';

use_ok( $CLASS ) or die "Couldn't compile [$CLASS]\n";

### test constructor - these should succeed:

my @GOOD_PARAMS = (
    [],
    ['foo'],
    [ spec  => 'foo' ],
    [ debug => 1 ],
    [ spec  => 'foo', debug => 1 ],
);

for my $params ( @GOOD_PARAMS ) {
    my $test_descr = "new() succeeds with valid parameters:";
    isa_ok( $CLASS->new( @{$params} ), $CLASS, $test_descr );
}

TODO: {
    local $TODO
        = "Extended param parsing not yet finished, would cause die in tests";

    my @MORE_GOOD_PARAMS = (
        [ 'foo', debug => 1 ],
        [ 'foo', { debug => 1 } ],
        [        { debug => 1 } ],
        [ { spec => 'foo', debug => 1 } ],
        [ {} ],
        [ 'foo', {} ],
    );

    todo_skip $TODO, scalar @MORE_GOOD_PARAMS;

    for my $params ( @MORE_GOOD_PARAMS ) {
        my $test_descr = "new() succeeds with valid parameters";
        isa_ok( $CLASS->new( @{$params} ), $CLASS, $test_descr );
    }
}

