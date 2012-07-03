use strict;
use warnings;
package Getopt::Nearly::Everything::SpecParser;
# ABSTRACT: Parse a Getopt::Long option specification

use Carp;
use Data::Dumper;
our @CARP_NOT = qw( Getopt::Nearly::Everything );


# holds the current opt spec, used for error and debugging code...
my $CUR_OPT_SPEC;

# holds the parameters for the current parse
my $CUR_OPTS;


sub new {
    my ($class, %params) = @_;

    my $self = bless { %params }, $class;

    return $self;
}


sub parse {
    my ($self, $spec, $params) = @_;

    $CUR_OPT_SPEC = $spec; # temporary global...
    $CUR_OPTS = { %{$params || {}}, %{ ref($self) ? $self : {} } };

    print "DEBUG: spec: [$spec]\n" if $CUR_OPTS->{debug};
    print "DEBUG: params: " . Dumper $CUR_OPTS if $CUR_OPTS->{debug};

    if ( $spec !~ /^ ([|a-zA-Z_-]+) ([=:!+]?) (.*) /x ) {
        croak "Invalid option specification: [$spec]";
    }

    my $name_spec = $1;
    my $opt_type  = $2 ? $2 : '';
    my $arg_spec  = $3 ? $3 : '';

    my %name_params = $self->_process_name_spec( $name_spec );
    my %arg_params  = $self->_process_arg_spec( $opt_type, $arg_spec );

    # I feel that this block should be relocated... but WHERE?
    if ( $arg_params{negatable} ) {

        my @neg_names = $self->_generate_negation_names( 
            $name_params{name},
            $name_params{short},
            @{ $name_params{aliases} } 
        );
        push @{ $name_params{negations} }, @neg_names;
    }

    undef $CUR_OPT_SPEC; # done with global var.
    undef $CUR_OPTS;     # ditto

    my %result = $self->_fill_params(%name_params, %arg_params);

    return wantarray ? %result : \%result;
}

### if the spec shows that negation is allowed, 
### generate "no* names" for each name and alias.
sub _generate_negation_names {
    my ($self, @names) = @_;
    my @neg_names = map { ("no-$_", "no$_") } grep { length } @names;
    return @neg_names;
}

# Fills in various parameters from the ones already known
sub _fill_params {
    my ($self, %params) = @_;

    # TODO fill in stuff
    $params{opt_type} ||= 'flag';


    return %params;
}


our $NAME_SPEC_QR = qr{
    ( [a-zA-Z_-]+ )            # option name as $1
    (
      (?: [|] [a-zA-Z?_-]+ )*  # aliases as $2 (split on |)
    )
}x;

# About the optiontype...
#   = - option requires an argument
#   : - option argument optional (defaults to '' or 0)
#   ! - option is a flag and may be negated (0 or 1)
#   + - option is a flag starting at 0 and incremented each time specified

our $ARG_SPEC_QR = qr{
    (?:
        ( [siof] )    # arg data type as $1
      | ( \d+ )       # default num value as $2
      | ( [+] )       # increment type as $3
    )
    ( [@%] )?         # destination data type as $4
    (?:
        [{]
        (\d+)?        # min repetitions as $5
        (?:
            [,]
            (\d*)? # max repetitions as $6
        )?
        [}]
    )?
}x;


sub _process_name_spec {
    my ($self, $spec) = @_;

    if ( $spec !~ $NAME_SPEC_QR ) {
        croak "Could not parse the name part of the option spec "
            . "[$CUR_OPT_SPEC]."
    }

    my %params;

    $params{name}     = $1;
    $params{long}     = $1;
    $params{aliases}  = [
        grep { defined $_ }
        map  { (length($_) == 1 and !$params{short}) ? ($params{short} = $_ and undef) : $_ }
        grep { $_ }
        split( '[|]', $2)
    ];

    return %params;
}


sub _process_opt_type {
    my ($self, $opt_type, $arg_spec) = @_;

    my %params;

    # set params and do some checking based on what we now know...
    if ( $opt_type =~ /[+!]|^$/ ) {
        if ( $arg_spec ) {
            croak "Invalid option spec [$CUR_OPT_SPEC]: option type "
                . "[$opt_type] does not take an argument spec.";
        }
        if ( $opt_type eq '+' ) {
           $params{opt_type} = 'incr'; # incrementing number
        }
        if ( $opt_type eq '!' ) {
            $params{opt_type} = 'flag'; # boolean, 
            $params{negatable} = 1; # allow no- for negation
        }
        if ( $opt_type eq '' ) {
            $params{opt_type} = 'flag'; # boolean
        }
        return %params;
    }

    if ( $opt_type eq '=' ) {
        $params{value_required} = 1; # if option present, value required
    }
    elsif ( $opt_type eq ':' ) {
        $params{value_required} = 0; # if option present, no value required
    }
    else {
        croak "Invalid option spec [$CUR_OPT_SPEC]: option type "
            . "[$opt_type] is invalid.\n";
    }

    if( ! $arg_spec ) {
        croak "Invalid option spec [$CUR_OPT_SPEC]: option type "
            . "[$opt_type] requires an argument spec.\n";
    }

    return %params;
}


sub _process_arg_spec {
    my ($self, $opt_type, $arg_spec ) = @_;

    # do some validation and set some params based on the option type
    my %params = $self->_process_opt_type($opt_type, $arg_spec);

    return %params unless $arg_spec;

    # parse the arg spec...
    if ( $arg_spec !~ $ARG_SPEC_QR ) {
        croak "Could not parse the argument part of the option spec "
            . "[$CUR_OPT_SPEC].\n";
    }
    my $value_type    = $1;
    my $default_num  = $2;
    my $incr_type    = $3;
    my $dest_type    = $4 ? $4 : '';
    $params{min_rep} = $5 ? $5 : -1;
    $params{max_rep} = $6;

    if ( $opt_type eq ':' && defined $default_num ) {
        $params{default} = $default_num;
    }
    elsif ( $opt_type eq ':' && defined $incr_type ) {
        $params{opt_type} = 'incr';
    }
    elsif (! $value_type ) {
        croak "Invalid option spec [$CUR_OPT_SPEC]: option type "
            . "[$opt_type] must be followed by a valid data type.\n";
    } else {
        $params{value_type} = $value_type eq 's' ? 'string' 
                            : $value_type eq 'i' ? 'integer'
                            : $value_type eq 'o' ? 'extint'
                            : $value_type eq 'f' ? 'real'
                            : die "This should never happen. Ever.";
        $params{opt_type} = 'value';
    }

    $params{dest_type} = 'hash'  if $dest_type eq '%';
    $params{dest_type} = 'array' if $dest_type eq '@';    

    $params{default} = $default_num if $default_num; 

    $params{value_type} ||= '';
    $params{multi_type} ||= '';
    $params{dest_type} ||= '';
    $params{opt_type} ||= '';
    $params{multi} = 1 if $params{dest_type} eq 'hash'
                       || $params{dest_type} eq 'array'
                       || $params{min_rep} > 1 
                       || (defined $params{max_rep} and $params{max_rep} > 1) 
                       || $params{opt_type} eq 'incr';

    delete $params{min_rep} if $params{min_rep} < 0;
    delete $params{max_rep} if !defined $params{max_rep};

    return %params;
}


1 && q{there's nothing like re-inventing the wheel!}; # truth
__END__

=head1 SYNOPSIS

This module parses an option specification as would normally be used with 
Getopt::Long, and produces a hash showing the meaning/parameters the spec
describes... if that makes any sense at all...

Perhaps a little code snippet.

    use Getopt::Nearly::Everything::SpecParser;

    my $parser = Getopt::Nearly::Everything::SpecParser->new();
    my %spec_info = $parser->parse( 'foo|f=s@{1,5}' );
    
    # OR...
    
    my %spec_info = 
        Getopt::Nearly::Everything::SpecParser->parse( 'foo|f=s@{1,5}' );

%spec_info should be a hash containing info about the parsed Getopt::Long 
option specification

=head1 METHODS

=head2 new

construct a new parser.

    my $parser = Getopt::Nearly::Everything::SpecParser->new();
    # OR...
    my $parser = Getopt::Nearly::Everything::SpecParser->new( 
        debug => 1,
    );

=head2 parse

parse an option specification

    my %spec_info = $parser->parse( 'foo' );
    # OR...
    my $spec_info = $parser->parse( 'foo' );

return the info parsed from the spec as a hash, or hashref, 
depending on context.

In scalar context, returns a hashref, in list context, returns a hash.


=head1 NOTES on PARSING Getopt::Long OPTION SPECIFICATIONS

Described as a grammar:

  opt_spec  ::=  name_spec arg_spec

  name_spec ::=  opt_name ("|" opt_alias)*
  opt_alias ::=  /\w+/
  opt_name  ::=  /\w+/

  arg_spec ::= "="  arg_type                (dest_type)? (repeat)?
             | ":" (arg_type | /\d+/ | "+") (dest_type)? # is repeat legal here?
             | "!"
             | "+"

  arg_type  ::=  "s" | "i" | "o" | "f"
  dest_type ::=  "@" | "%"
  repeat    ::=  "{" (min)? ("," (/\d+/)?)? "}"
  min       ::=  /\d+/
  max       ::=  /\d+/


