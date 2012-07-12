use strict;
use warnings;
package Getopt::Nearly::Everything::SpecBuilder;
# ABSTRACT: Build a Getopt::Long option spec from a set of attributes
use Carp;
use Data::Dumper;


our %DATA_TYPE_MAP = (
    integer => 'i',
    int     => 'i',
    string  => 's',
    str     => 's',
    float   => 'f',
    extint  => 'o',
    ext     => 'o',
);

our %DEST_TYPE_MAP = (
    'array'  => '@',
    'hash'   => '%',
    'scalar' => '',
);


sub new {
    my ($class, %params) = @_;
    my $self = bless { %params }, $class;
    return $self;
}


sub build {
    my ($self, %params) = @_;
    
    my $name_spec = $self->_build_name_spec( \%params );

    my $spec_type = $self->_spec_type( \%params );

    croak "default only valid when spec type is ':'\n"
      if $params{default_num} and $spec_type ne ':';

    my $arg_spec = ($spec_type =~ /[:=]/) ? 
        $self->_build_arg_spec( \%params ) :
        '';

    my $spec = $name_spec . $spec_type . $arg_spec;
    
    return $spec;
}


sub _build_name_spec {
    my ($self, $params) = @_;

    $params->{aliases} ||= [] unless exists $params->{aliases};
    croak "option parameter [aliases] must be an array ref\n"
        unless ref $params->{aliases} eq 'ARRAY';

    my $name_spec = join( '|', grep { defined $_ and length $_ } 
        $params->{long}, $params->{short},
        @{ $params->{aliases}  } );

    return $name_spec;
}


sub _spec_type {
    my ($self, $params) = @_;

    # note: keep in mind - order is important here!
    return ':' if defined $params->{val_required} and $params->{val_required} == 0;
    return '=' if $params->{val_required};
    return '!' if $params->{negatable};
    return '+' if $params->{opt_type} =~ '^incr';
    return ''  if $params->{opt_type} eq 'flag';
    
    die "Could not determine option type from spec!\n"
}


sub _build_arg_spec {
    my ($self, $params) = @_;

    my $val_type = $DATA_TYPE_MAP{ lc($params->{val_type}) || 'int' } or
        croak "invalid value type [$params->{val_type}]\n";

   # special cases for incremental opts or opts with default numeric value
   $val_type = $params->{default_num} if $params->{default_num};
   $val_type = '+' if $params->{opt_type} =~ /^incr/ and $val_type eq 'i';

    # empty or missing destination type is allowable, so this accounts for that.
    my $dest_type = ! $params->{dest_type} ? '' : $DEST_TYPE_MAP{ $params->{dest_type} };
    croak "invalid destination type [@{[ $params->{dest_type} || '' ]}]\n"
      unless defined $dest_type;
    
    # ah, the little-understood "repeat" clause
    my $repeat = '';
    if ( defined $params->{min_vals} || defined $params->{max_vals} ) {
        croak "repeat spec not valid when using default value\n" if $params->{default_num};
        $repeat .= '{';
        $repeat .= $params->{min_vals} if defined $params->{min_vals};
        $repeat .= "," . (defined $params->{max_vals} ? $params->{max_vals} : '')
            if exists $params->{max_vals};
        $repeat .= '}';
    }
    elsif ( defined $params->{num_vals} ) {
        $repeat .= "{$params->{num_vals}}";
    }

    return $val_type . $dest_type . $repeat;
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



