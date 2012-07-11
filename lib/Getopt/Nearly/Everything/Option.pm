package Getopt::Nearly::Everything::Option;
# ABSTRACT: a GoNE option object
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use Params::Util qw(_HASHLIKE _SCALAR0 _ARRAYLIKE);
use Carp;
use List::MoreUtils qw(uniq);
use Data::Dumper;
use Getopt::Nearly::Everything::SpecBuilder;


# Before invoking the constructor, figure out what kind of
# option this is, importing whever roles fit the arguments.
# Also set various attributes based on the arguments.
sub BUILDARGS {
    my ($class, @args) = @_;
    my %args = _HASHLIKE($args[0]) ? %{$args[0]} : @args;

    if ( !defined $args{name} ) {
        $args{name} = ($args{long}
          or croak "Can't set name if long is missing!\n");
    }

    if ( !defined $args{default} ) {
        $args{default} =
            _SCALAR0($args{destination}) ? ${$args{destination}} : $args{destination};
    }
    
    $args{val_type} = 'integer'
      if ($args{opt_type} and $args{opt_type} =~ '^incr');

    if ( !defined $args{dest_type} ) {
        $args{dest_type} =
            _SCALAR0(   $args{destination} ) ? 'scalar' :
            _ARRAYLIKE( $args{destination} ) ? 'array'  :
            _HASHLIKE(  $args{destination} ) ? 'hash'   :
            'scalar';
    }

    with 'Getopt::Nearly::Everything::Option::MultiUseRole'
      if ($args{opt_type} and $args{opt_type} =~ '^incr')
      or $args{dest_type} =~ /array|hash/
      or ($args{max_use} and $args{max_use} > 1);

    with 'Getopt::Nearly::Everything::Option::MultiValRangeRole'
      if exists $args{min_vals} or exists $args{max_vals};

    with 'Getopt::Nearly::Everything::Option::MultiValFixedRole'
      if exists $args{vals};

    if ( $args{negatable} ) {
      croak "negatable only makes sense for opt_type = flag\n"
        unless $args{opt_type} eq 'flag';
      with 'Getopt::Nearly::Everything::Option::NegatableRole';
    }

    return \%args;
}

# Doing this because something seems to be broken in Moo???
# TODO: investiagate... I may be Doing It Wrong (tm)
sub BUILD {
  my ($self, $args) = @_;
  # so icky, but my role attributes aren't getting populated without this :(
  @{$self}{$_} = $args->{$_} for keys %$args;
}

sub spec {
  my ($self) = @_;
  # this is where I want a real MOP, but not bad enough yet, evidently.
  # still, it would be nice to be able to convert all object attributes
  # to a hash reliably and including all roles...
  my %params = %$self;
  return Getopt::Nearly::Everything::SpecBuilder->build(%params);
}


### Stuff all options have or may have

has opt_type => (
    is => 'ro',
    isa => Str,
    required => 1,
    documentation => q{
        The "type" of this option itself. Put simply, must be one of
        'flag', 'incremental', or 'simple', which correspond to the
        various ways an option can be interpreted due to the contents
        of a Getopt::Long spec.

        Flag options only have a boolean value - true or false.
        
        Incremental options have an integer value that begins at 0 and
        is incremented each time the option is used.

        Simple options have a value that is specified in various ways
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
        This is the data type in which the values will be stored.
        It will be one of 'scalar', 'hash', or 'array'.

        Note that 'flag' and 'incremental' options can only use 'scalar'. If you
        try to use something else things might... happen...
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
        stored. If both this attribute and dest_type are set, their types *must*
        match. If this is set and dest_type is not set, dest_type will be set to
        the correct value based on the ref passed to this.

        Any value(s) in the referenced variable will be used as the default value
        of the option, *unless* the 'default' attribute is set, in which case,
        *that* will take precedence and be used instead.
    },
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


### attributes that only pertain to simple/value options

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

1 && q{Moo, motherfuckers!}; # truth
