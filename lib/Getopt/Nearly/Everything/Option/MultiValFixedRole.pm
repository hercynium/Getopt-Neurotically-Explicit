package Getopt::Nearly::Everything::Option::MultiValFixedRole;
# ABSTRACT: for options that consume a fixed number of multiple values
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);
use Data::Dumper;

sub multi_val { 1 }

has vals => (
    is => 'ro',
    isa => Maybe[], # Maybe seems to be broken. Should contain Int.
    documentation => q{
        Some options can consume multiple values. This is the number of
        values to consume. Must be an integer greater than 0 or undefined. If
        undefined, it will consume all remaining values from the command line.
    }
);

1;
