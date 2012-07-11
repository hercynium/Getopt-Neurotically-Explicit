package Getopt::Nearly::Everything::Option::MultiValRangeRole;
# ABSTRACT: for options that may consume a range of multiple values
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

sub multi_val { 1 }

has min_vals => (
    is => 'ro',
    isa => Maybe[], # Maybe seems to be broken. Should contain Int.
    documentation => q{
        Some options can consume multiple values. This is the minimum number
        of values to consume. Must be 0, a positive integer, or undefined. If
        undefined, GoNE behaves like GoL, treating it as if it were 0.
    },
);

has max_vals => (
    is => 'ro',
    isa => Maybe[],
    documentation => q{
        Some options can consume multiple values. This is the maximum number of
        values to consume. Must be a positive integer or undefined. If a positive
        integer, it must be greater than min_vals. If undefined, GoNE behaves like
        GoL, consuming the rest of the command-line as values for the option.
    },
);

1;
