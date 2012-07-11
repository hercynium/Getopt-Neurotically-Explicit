package Getopt::Nearly::Everything::Option::NegatableRole;
# ABSTRACT: for options that can be negated
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);


sub negatable { 1 }

has negations => (
    is => 'ro',
    isa => ArrayRef[Str],
    documentation => q{
        Options which, when present, negate this option.
        Only makes sense for flag options. Same thing as usual about valid characters.
        for exmaple, the option --connect might have a negation of --no-connect
    },
);

has do_auto_negations => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        When constructing this object, negations can be generated from the long
        and alias values. By default, one-char option names do not get negations.
        Generated negations will be added to any negations supplied by the user.
    },
);

has short_negations_ok => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        When constructing this object, negations can be generated from the long
        and alias values. By default, one-char option names do not get negations.
        Setting this to true changes that so foo|f will get nofoo and nof negations.
    },
);

1;
