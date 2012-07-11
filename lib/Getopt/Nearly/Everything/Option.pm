package Getopt::Nearly::Everything::Option;
# ABSTRACT: a GoNE option object
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use Params::Util qw(_HASHLIKE _SCALAR0 _ARRAYLIKE);
use Carp;
use List::MoreUtils qw(uniq);
use Data::Dumper;
use Getopt::Nearly::Everything::SpecBuilder;


# set & validate various args based on the values of others before actually
# invoking the constructor.
sub BUILDARGS {
    my ($class, @args) = @_;

    my %args = _HASHLIKE($args[0]) ? %{$args[0]} : @args;

    if ( !defined $args{name} ) {
        $args{name} = ($args{long} or croak "Can't set name if long is missing!\n");
    }


    if ($args{opt_type} and $args{opt_type} eq 'flag') {

        # build/add-to negations if the user asked
        $args{negations} = [
            uniq
            @{ $args{negations} || [] },
            map  { ("no$_", "no-$_") }
            grep { $args{short_negations} ? 1 : defined $_ and length $_ > 1 }
                $args{long},
                @{ $args{aliases}   || [] }
        ] if $args{auto_negations};
    }
    else {
        # certain args/attrs only apply to flags
        delete @args{qw(negations short_negations auto_negations)};
    }


    if ( !defined $args{default} ) {
        $args{default} =
            _SCALAR0($args{destination}) ? ${$args{destination}} : $args{destination};
    }

    if ( !defined $args{dest_type} ) {
        $args{dest_type} =
            _SCALAR0(   $args{destination} ) ? 'scalar' :
            _ARRAYLIKE( $args{destination} ) ? 'array'  :
            _HASHLIKE(  $args{destination} ) ? 'hash'   :
            'scalar';
    }

    $args{val_type} ||= 'integer' if ($args{opt_type} and $args{opt_type} =~ '^incr');

    if ( !defined $args{multi} ) {
        $args{multi} =
            ($args{opt_type} and $args{opt_type} =~ '^incr') ? 1 :
            $args{dest_type} eq 'array' ? 1 :
            $args{dest_type} eq 'hash'  ? 1 :
            ($args{max_rep} and $args{max_rep} > 1) ? 1 :
            0;
    }

    return \%args;
}


### Stuff all options have or may have

has opt_type => (
    is => 'ro',
    isa => Str,
    required => 1,
    documentation => q{
        The "type" of this option itself. Put simply, must be one of
        'flag', 'incremental', or 'value', which correspond to the
        various ways an option can be interpreted due to the contents
        of a Getopt::Long spec.

        Flag options only have a boolean value - true or false.
        
        Incremental options have an integer value that begins at 0 and
        is incremented each time the option is used.

        Value options have a value that is specified in various ways
        and can be stored as either a scalar, a hash, or an array, but
        on the command line can only be entered as numbers or strings.
    },
);

has name => (
    is => 'ro',
    isa => Str,
    required => 1,
    documentation => q{
        The name of the option. This is not what is used on the
        command-line, but how this option is identified in GoNE.
        If not provided, defaults to the value of "long".
        If neither are provided, an exception will be thrown.
    },
);

has short => (
    is => 'ro',
    isa => Str,
    documentation => q{
        A single-character that can be used to supply this option on the command-line.
        Must only consist of the typical characters used for command-line options.
    },
);

has long => (
    is => 'ro',
    isa => Str,
    documentation => q{
        A "word" that can be used to supply this option on the command-line.
        Must only consist of the typical characters used for command-line options.
    }
);

has aliases => (
    is => 'ro',
    isa => ArrayRef[Str],
    documentation => q{
        A list of short or long names that can serve as aliases for this option
        on the command-line. Again, all must consist only of the typical characters
        used for command-line options.
    },
);

has dest_type => (
    is => 'ro',
    isa => Str,
    documentation => q{
        When multi is true, this is the data type in which the values will be stored.
        It will be one of 'scalar', 'hash', or 'array'.

        Note that 'flag' and 'incremental' options can only use 'scalar'. If you try to\
        use something else things will... happen...
    },
);

has default => (
    is => 'ro',
    documentation => q{
        The default value assigned to this option if a value is not supplied
        on the command line.

        If you use a default that doesn't make sense for the opt_type, you get
        to make sense of the errors.
    },
);

has destination => (
    is => 'ro',
    documentation => q{
        A reference to a variable in which this option's value (or values) will be
        stored. If both this attribute and multi_type are set, their types *must*
        match. If this is set and multi_type is not set, multi_type will be set to
        the correct value based on the ref passed to this.

        Any value(s) in the referenced variable will be used as the default value
        of the option, *unless* the 'default' attribute is set, in which case,
        *that* will take precedence and be used instead.
    },
);

has multi => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        Indicates whether or not this option can be used multiple times
        on the command-line. If so, the values will be collected in an
        array (by default) or hash.
    },
);

has min_vals => (
    is => 'ro',
    documentation => q{
        Some options can consume multiple values. This is the minimum number of
        values to consume. Must be an integer greater than 0 or undefined.
    }
);

has max_vals => (
    is => 'ro',
    #isa => Int,
    documentation => q{
        Some options can consume multiple values. This is the maximum number of
        values to consume. Must be an integer greater than 0 or undefined. If
        an integer, must be greater than min_vals.
    }
);

has depends => (
    is => 'ro',
    isa => ArrayRef[Str],
    documentation => q{
        The names of any other options that must also be set when this option is used.
    },
);

has conflicts => (
    is => 'ro',
    isa => ArrayRef[Str],
    documentation => q{
        The names of any other options that must *not* be set when this option is used.
    },
);

has usage => (
    is => 'ro',
    isa => Str,
    documentation => q{
        Short documentation of this option, expected for use when outputting
        usage or help.
    },
);

has info => (
    is => 'ro',
    isa => Str,
    documentation => q{
        Long documentation for this option, can be used when outputting stuff
        like POD or man pages. Is expected to be longer and more comprehensive
        than the text for usage.
    },
);

has error => (
    is => 'ro',
    isa => Str,
    documentation => q{
        Text to display when this option is used in error.
    },
);

has group => (
    is => 'ro',
    isa => Str,
    documentation => q{
        When outputting usage or helptext, it can be useful to group options
        together. This assigns the option to a named group.
    },
);


### Only flag options are negatable with GoL, so these only pertain to flags.

has negatable => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        If this option is negatable with forms like --no-foo, this should be true.
    },
);

has negations => (
    is => 'ro',
    isa => ArrayRef[Str],
    documentation => q{
        Options which, when present, negate this option.
        Only makes sense for flag options. Same thing as usual about valid characters.
        for exmaple, the option --connect might have a negation of --no-connect
    },
);

has auto_negations => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        When constructing this object, negations can be generated from the long
        and alias values. By default, one-char option names do not get negations.
        Generated negations will be added to any negations supplied by the user.
    },
);

has short_negations => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        When constructing this object, negations can be generated from the long
        and alias values. By default, one-char option names do not get negations.
        Setting this to true changes that so foo|f will get nofoo and nof negations.
    },
);



### attributes that only pertain to value options


has val_type => (
    is => 'ro',
    isa => Str,
    documentation => q{
        The Getopt::Long type of the value of this option. Put simply, must
        be one of 'string', 'integer', 'extint', or 'float' which correspond
        to the 's', 'i', 'o', and 'f' characters after an '=' or ':' in a
        Getopt::Long spec.
    },
);


has value_required => (
    is => 'ro',
    isa => Bool,
    documentation => q{
        Indicates that this option's value is required to be set.
    },
);

sub spec {
  my ($self) = @_;
  # this is where I want a MOP, but not bad enough yet, evidently.
  my %params = %$self;
  return Getopt::Nearly::Everything::SpecBuilder->build(%params);
}

1 && q{Moo, motherfuckers!}; #truth
