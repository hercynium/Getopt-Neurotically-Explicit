package Getopt::Nearly::Everything::SpecBuilder;

### Build a Getopt::Long option specification from 
### the parameters passed in

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
);


sub new {
    my ($class, $params_hash) = @_;

    my $self = bless {}, $class;

    # the user can retrieve the results by calling spec()
    $self->build( $params_hash ) if $params_hash;

    return $self;
}


sub build {
    my ($self, $params_hash) = @_;
    
    my $name_spec = $self->_build_name_spec( $params_hash );

    my $spec_type = $self->_spec_type( $params_hash );

    my $arg_spec = $spec_type =~ /[:=]/ ? 
        $arg_spec = $self->_build_arg_spec( $params_hash ) :
        '';

    $self->{spec} = $name_spec . $spec_type . $arg_spec;
    
    return $self->built_spec();
}

sub _build_name_spec {
    my ($self, $params_hash) = @_;

    croak "missing required option parameter [name]\n" 
        unless $params_hash->{name};

    $params_hash->{aliases} ||= [] unless exists $params_hash->{aliases};
    croak "option parameter [aliases] must be an array ref\n"
        unless ref $params_hash->{aliases} eq 'ARRAY';

    my $name_spec = join( '|', 
        $params_hash->{name}, 
        @{ $params_hash->{aliases}  } );

    return $name_spec;
}

sub _spec_type {
    my ($self, $params_hash) = @_;

    # note: keep in mind - order is important here!
    # yes, I know, this could be written with ternary ?:
    return '=' if $params_hash->{value_required};
    return '!' if $params_hash->{negatable};
    return ''  if $params_hash->{data_type} eq 'flag';
    return ':';
}


sub _build_arg_spec {
    my ($self, $params_hash) = @_;

    my $data_type = $DATA_TYPE_MAP{ $params_hash->{data_type} } or
        croak "invalid data type [$params_hash->{data_type}]\n"
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

    my $repeat = 
        defined $params_hash->{min_rep} || defined $params_hash->{max_rep} ?
        "{$params_hash->{min_rep},$params_hash->{max_rep}}" : '';

    return $data_type . $dest_type . $repeat;
}

sub built_spec {
    my ($self) = @_;

    return $self->{spec};
}



1; # return true
__END__


=head1 NAME

Getopt::Nearly::Everything::SpecBuilder - Build a Getopt::Long option specification

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module builds a Getopt::Long option specification from a hash of option
parameters as would be returned by Getopt::Nearly::Everything::SpecParser->parse($spec)
and/or Getopt::Nearly::Everything->opt_params($opt_name).

Here's an example of use:

    use Getopt::Nearly::Everything::SpecBuilder;

    my %opt_params = (
        value_required => 1,
        data_type      => 'string',
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
        Getopt::Nearly::Everything::SpecBuilder->new( %opt_params )
            ->built_spec();

=head1 METHODS

=head2 new

Create a new builder object, and if passed params, build a spec to 
return with built_spec()

=head2 build

Build a Getopt::Long option specification from the parameters passed in (as 
a hash or hashref) and return the spec as a string

=head2 built_spec

Return a previously built spec as a string. Returns false if no spec has been 
built via new() or build()

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

    perldoc Getopt::Nearly::Everything::SpecBuilder


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


