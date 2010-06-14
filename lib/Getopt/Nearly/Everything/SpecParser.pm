package Getopt::Nearly::Everything::SpecParser;

use Carp;
use Data::Dumper;
our @CARP_NOT = qw( Getopt::Nearly::Everything );


sub new {
    my ($class, @param_list) = @_;

    my $self = bless {}, $class;

    # if a single param, it's a spec. otherwise,
    # expect a list of key/val pairs
    my ($spec) = scalar @param_list == 1 ? @param_list : '';
    if( ! $spec ) {
        my %params = @param_list;
        $spec = $params{spec} && delete $params{spec};
        $self->{DEBUG} = $params{debug} && delete $params{debug};
        croak "Unknown parameters to new(): [ " . 
            join( ", ", keys %params ) . " ]\n"
                if keys %params;
    }

    # the user can retrieve the results by calling parsed_params()
    $self->parse( $spec ) if $spec;
    
    return $self;
}

# Process the parameters passed to new() and return a hashref or die
#   TODO handle all the following possibilities:
#     new( spec )
#     new( spec, { param => val ... } )
#     new( param => val ... )
#     new( { param => val ... } )
sub _process_params {
    my ($self, @param_list) = @_;
    
    # if a single param, it's a spec. otherwise,
    # expect a list of key/val pairs
    my ($spec) = scalar @param_list == 1 ? @param_list : '';
    if( ! $spec ) {
        my %params = @param_list;
        $spec = $params{spec} && delete $params{spec};
        $self->{DEBUG} = $params{debug} && delete $params{debug};
        croak "Unknown parameters to new(): [ " .
            join( ", ", keys %params ) . " ]\n"
                if keys %params;
    }
    return %params;
}


sub parse {
    my ($self, $spec) = @_;

    print "DEBUG: spec: [$spec]\n" if $self->{DEBUG};

    if ( $spec !~ /^ ([|a-zA-Z_-]+) ([=:!+]?) (.*) /x ) {
        croak "Invalid option specification: [$spec]";
    }

    $name_spec = $1;
    $opt_type  = $2 ? $2 : '';
    $arg_spec  = $3 ? $3 : '';

    $self->{opt_spec}  = $spec;

    my %name_params = $self->_process_name_spec( $name_spec );
    my %arg_params  = $self->_process_arg_spec( $opt_type, $arg_spec );

    # I feel that this block should be relocated... but WHERE?
    if ( $arg_params{negatable} ) {

        my @neg_names = $self->_generate_negation_names( 
            $name_params{name}, 
            @{ $name_params{aliases} } 
        );
        push @{ $name_params{aliases} }, @neg_names;
    }

    my %result = (%name_params, %arg_params);

    $self->{parsed_params} = \%result;

    return $self->parsed_params();
}

sub parsed_params {
    my ($self) = @_;
    
    return unless exists $self->{parsed_params};

    return wantarray ? %{ $self->{parsed_params} } : $self->{parsed_params};
}



my $name_spec_qr = qr{
    ( [a-zA-Z_-]+ )           # option name as $1
    (
      (?: [|] [a-zA-Z?_-]+ )*  # aliases as $2 (split on |)
    )
}x;

# About the optiontype...
#   = - option requires an argument
#   : - option argument optional (defaults to '' or 0)
#   ! - option is a flag and may be negated (0 or 1)
#   + - option is a flag starting at 0 and incremented each time specified

my $arg_spec_qr = qr{
    (?:
        ( [siof] )   # arg data type as $1
      | ( \d+ )       # default num value as $2
      | ( [+] )       # increment type as $3
    )
    ( [@%] )?         # destination data type as $4
    (?:
        [{]
        (\d+)?        # min repetitions as $5
        (?:
            [,]
            (\d+)?    # max repetitions as $6
        )?
        [}]
    )?
}x;



sub _process_name_spec {
    my ($self, $spec) = @_;

    if ( $spec !~ $name_spec_qr ) {
        croak "Could not parse the name part of the option spec "
            . "[$self->{opt_spec}]."
    }

    my %params;

    $params{name}     = $1;
    $params{aliases}  = [ grep { $_ } split( '[|]', $2) ];

    return %params;
}





sub _process_opt_type {
    my ($self, $opt_type, $arg_spec) = @_;

    my %params;

    # set params and do some checking based on what we now know...
    if ( $opt_type =~ /[+!]|^$/ ) {
        if ( $arg_spec ) {
            croak "Invalid option spec [$self->{opt_spec}]: option type "
                . "[$opt_type] does not take an argument spec.";
        }
        if ( $opt_type eq '+' ) {
           $params{data_type} = 'incr'; # incrementing number
        }
        if ( $opt_type eq '!' ) {
            $params{data_type} = 'flag'; # boolean, 
            $params{negatable} = 1; # allow no- for negation
        }
        if ( $opt_type eq '' ) {
            $params{data_type} = 'flag'; # boolean
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
        croak "Invalid option spec [$self->{opt_spec}]: option type "
            . "[$opt_type] is invalid.\n";
    }

    if( ! $arg_spec ) {
        croak "Invalid option spec [$self->{opt_spec}]: option type "
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
    if ( $arg_spec !~ $arg_spec_qr ) {
        croak "Could not parse the argument part of the option spec "
            . "[$self->{opt_spec}].\n";
    }
    my $data_type    = $1;
    my $default_num  = $2;
    my $incr_type    = $3;
    my $dest_type    = $4 ? $4 : '';
    $params{min_rep} = $5 ? $5 : -1;
    $params{max_rep} = $6 ? $6 : -1;

    if ( $opt_type eq ':' && defined $default_num ) {
        $params{default} = $default_num;
    }
    elsif ( $opt_type eq ':' && defined $incr_type ) {
        $params{data_type} = 'incr';
    }
    elsif (! $data_type ) {
        croak "Invalid option spec [$self->{opt_spec}]: option type "
            . "[$opt_type] must be followed by a valid data type.\n";
    } else {
        $params{data_type} = $data_type eq 's' ? 'string' 
                           : $data_type eq 'i' ? 'integer'
                           : $data_type eq 'o' ? 'extint'
                           : $data_type eq 'f' ? 'real'
                           : die "This should never happen. Ever.";
    }

    $params{dest_type} = 'hash'  if $dest_type eq '%';
    $params{dest_type} = 'array' if $dest_type eq '@';    

    $params{default} = $default_num if $default_num; 

    $params{data_type} ||= '';
    $params{dest_type} ||= '';
    $params{multi} = 1 if $params{dest_type} eq 'hash'
                       || $params{dest_type} eq 'array'
                       || $params{min_rep} > 1 
                       || $params{max_rep} > 1 
                       || $params{data_type} eq 'incr';

    return %params;
}

### if the spec shows that negation is allowed, 
### generate "no* names" for each name and alias.
sub _generate_negation_names {
    my ($self, @names) = @_;

    my @neg_names;
    push @neg_names, "no-$_", "no$_" for @names;
    return @neg_names;
}



1; # return true
__END__


=head1 NAME

Getopt::Nearly::Everything::SpecParser - Parse a Getopt::Long option specification

=head1 VERSION

Version 0.01

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
        Getopt::Nearly::Everything::SpecParser->new( 'foo|f=s@{1,5}' )
            ->parsed_params();

%spec_info should be a hash containing info about the parsed Getopt::Long 
option specification

=head1 METHODS

=head2 new

construct a new parser, parse the spec passed in, if any

    my $parser = Getopt::Nearly::Everything::SpecParser->new();
    # OR...
    my $parser = Getopt::Nearly::Everything::SpecParser->new( 'foo' );
    # OR...
    my $parser = Getopt::Nearly::Everything::SpecParser->new( 
        spec  => 'foo',
        debug => 1,
    );

=head2 parse

parse an option specification

    my %spec_info = $parser->parse( 'foo' );
    # OR...
    my $spec_info = $parser->parse( 'foo' );

=head2 parsed_params

return the info parsed from the spec as a hash, or hashref, 
depending on context.

    my %spec_info = $parser->parsed_params();
    # OR...
    my $spec_info = $parser->parsed_params();

In scalar context, returns a hashref, in list context, returns a hash.

If parse() has not yet been called, and/or a spec was not passed to new(), 
then this will simply return false ( undef or () )


=head1 NOTES on PARSING Getopt::Long OPTION SPECIFICATIONS

=head2 Described as a grammar

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


=head2 As a regexen

  qr{
      ( \w+ )           # name as $1
      (
        (?: [|] \w+ )*  # aliases as $2 (split on |)
      )
      ( [=:!+] )        # arg spec type as $3
    }
    # = -> value required
    # : -> value optional (defaults to '' or 0)
    # ! -> option is a flag and may be negated (0 or 1)
    # + -> option is a flag starting at 0 and incremented each time specified
  qr{
      (?: 
          ( [siof] )   # arg data type as $1
        | ( \d+ )      # ??? as $2
        | ( [+] )      # allow multiple-use as $3
      ) 
      ( [@%] )?        # destination data type as $4
      (?: 
          [{] 
          (\d+)?       # min repetitions as $5
          (?: 
              [,] 
              (\d+)?   # max repetitions as $6
          )? 
          [}] 
      )?
    }


=head1 AUTHOR

Steve Scaffidi, C<< <sscaffidi at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to 
C<bug-getopt-nearly-everything at rt.cpan.org>, or through the web interface 
at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Getopt-Nearly-Everything>.
I will be notified, and then you'll automatically be notified of progress on 
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Getopt::Nearly::Everything::SpecParser


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Getopt-Nearly-Everything>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Getopt-Nearly-Everything>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Getopt-Nearly-Everything>

=item * Search CPAN

L<http://search.cpan.org/dist/Getopt-Nearly-Everything/>

=back

=head1 SEE ALSO

=over 4

=item * Getopt::Long - info on option specifications

=item * Getopt::Nearly::Everything - the module for which this module was created

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Steve Scaffidi, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
