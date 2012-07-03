use strict;
use warnings;
package Getopt::Nearly::Everything::SpecBuilder;
# ABSTRACT: Build a Getopt::Long option specification from a GoNE spec

use Carp;
use Data::Dumper;
our @CARP_NOT = qw( Getopt::Nearly::Everything );


our %DATA_TYPE_MAP = (
    integer => 'i',
    string  => 's',
    float   => 'f',
    file    => 's',
);

our %DEST_TYPE_MAP = (
    array => '@',
    hash  => '%',
    'scalar' => '',
);


sub new {
    my ($class, %params) = @_;

    my $self = bless { %params }, $class;

    return $self;
}


sub build {
    my ($self, %params_hash) = @_;
    
    my $name_spec = $self->_build_name_spec( \%params_hash );

    my $spec_type = $self->_spec_type( \%params_hash );

    my $arg_spec = ($spec_type =~ /[:=]/) ? 
        $self->_build_arg_spec( \%params_hash ) :
        '';

    my $spec = $name_spec . $spec_type . $arg_spec;
    
    return $spec;
}


sub _build_name_spec {
    my ($self, $params_hash) = @_;

    croak "missing required option parameter [name]\n" 
        unless $params_hash->{name};

    $params_hash->{aliases} ||= [] unless exists $params_hash->{aliases};
    croak "option parameter [aliases] must be an array ref\n"
        unless ref $params_hash->{aliases} eq 'ARRAY';

    my $name_spec = join( '|', grep { defined $_ and length $_ } 
        $params_hash->{name}, $params_hash->{short},
        @{ $params_hash->{aliases}  } );

    return $name_spec;
}


sub _spec_type {
    my ($self, $params_hash) = @_;

    # note: keep in mind - order is important here!
    # yes, I know, this could be written with ternary ?:
    return '=' if $params_hash->{value_required};
    return '!' if $params_hash->{negations};
    return ':' if ! defined $params_hash->{opt_type};
    return '+' if $params_hash->{opt_type} =~ '^incr';
    return ''  if $params_hash->{opt_type} eq 'flag';
    return ':';
}


sub _build_arg_spec {
    my ($self, $params_hash) = @_;

    my $data_type = $DATA_TYPE_MAP{ $params_hash->{value_type} || 'integer' } or
        croak "invalid value type [$params_hash->{value_type}]\n"
            . "  valid types: ['" 
            . join( "', '", keys %DATA_TYPE_MAP ) 
            . "']\n";

    # empty or missing destination type is allowable, so this accounts for that.
    my $passed_dest_type = ! defined $params_hash->{dest_type} ? 
        '' : $params_hash->{dest_type};

    # This seems really ugly to me, but my brain's fried and it works
    my $dest_type = 
        $passed_dest_type eq '' ? '' :
        exists $DEST_TYPE_MAP{ $passed_dest_type } ? 
            $DEST_TYPE_MAP{ $params_hash->{dest_type} } :
        croak "invalid destination type [$params_hash->{dest_type}]\n"
            . "  valid types: ['" 
            . join( "', '", keys %DEST_TYPE_MAP ) 
            . "']\n";

    # Repetition values are optional, and must be a positive integer...
    # 0 is valid for min, and max must be > min...
    # perhaps that should be validated elsewhere...
    # maybe yet another package.

    my $repeat = '';
    if ( defined $params_hash->{min_rep} || defined $params_hash->{max_rep} ) {
        $repeat .= '{';
        $repeat .= $params_hash->{min_rep} if defined $params_hash->{min_rep};
        $repeat .= "," . (defined $params_hash->{max_rep} ? $params_hash->{max_rep} : '')
            if exists $params_hash->{max_rep};
        $repeat .= '}';
    }

    return $data_type . $dest_type . $repeat;
}


1 && q{this is probably crazier than the last thing I wrote}; # truth
__END__

=head1 SYNOPSIS

This module builds a Getopt::Long option specification from a hash of option
parameters as would be returned by Getopt::Nearly::Everything::SpecParser->parse($spec)
and/or Getopt::Nearly::Everything->opt($opt_name)->params().

Here's an example of use:

    use Getopt::Nearly::Everything::SpecBuilder;

    my %opt_params = (
        opt_type       => 'value'
        value_required => 1,
        value_type     => 'string',
        max_rep        => '5',
        dest_type      => 'array',
        min_rep        => '1',
        aliases        => [ 'f' ],
        name           => 'foo',
        multi          => 1,
    );

    my $builder   = Getopt::Nearly::Everything::SpecBuilder->new();
    my $spec      = $builder->build( %opt_names );
    print $spec;  # output: 'foo|f=s@{1,5}'
    
    # OR...
    
    my $spec = 
        Getopt::Nearly::Everything::SpecBuilder->build( %opt_params );

=head1 METHODS

=head2 new

Create a new builder object, and if passed params, build a spec to 
return with built_spec()

=head2 build

Build a Getopt::Long option specification from the parameters passed in (as 
a hash or hashref) and return the spec as a string

=head1 SEE ALSO

=over 4

=item * Getopt::Long - info on option specifications

=item * Getopt::Nearly::Everything - the module for which this module was created

=back



