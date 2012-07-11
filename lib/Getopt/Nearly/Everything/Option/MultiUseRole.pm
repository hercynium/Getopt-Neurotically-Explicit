package Getopt::Nearly::Everything::Option::MultiUseRole;
# ABSTRACT: for simple/value options that may be used multiple times
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

sub multi_use { 1 }

has min_use => (
    is => 'ro',
    isa => Maybe[], # Maybe seems to be broken. Should contain Int.
    documentation => q{
        Some options can be used multiple times. This is the minimum number
        of times it can be used. Must be 0, a positive integer, or undefined.
        If undefined, GoNE treats it as if it were 0.
    },
);

has max_use => (
    is => 'ro',
    isa => Maybe[],
    documentation => q{
        Some options can consume multiple values. This is the maximum number of
        values to consume. Must be a positive integer or undefined. If a positive
        integer, it must be greater than ir equal to min_vals. If undefined, it
        may be used as many times as the user wants.
    },
);

1;
