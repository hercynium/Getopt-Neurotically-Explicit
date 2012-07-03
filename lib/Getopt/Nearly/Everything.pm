use strict;
use warnings;
package Getopt::Nearly::Everything;
# ABSTRACT: Nearly everything you'd ever want from a Getopt module!

# AKA, Getopt::Neurotically::Explicit, or GoNE

use Carp;
use Exporter;
use Data::Dumper;


# Turns a Getopt::Long (GoL) spec into args for GoNE
use Getopt::Nearly::Everything::SpecParser;


# Base Getopt::Long config flags to use for GoNE
use Getopt::Long qw(
  :config
    ignore_case
    gnu_getopt
    bundling_override
    no_auto_abbrev
);


our @ISA = qw(Exporter);


sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;

    return $self;
}


sub add_opt {
    my ($self, %params) = @_;

    my %opt_params = $self->_process_params( %params );

    print Dumper \%opt_params;
    return $self;
}


sub _process_params {
    my ($self, %params) = @_;

    # Extract params from a Getopt::Long option specification
    # and merge into the passed params.
    if ( exists $params{spec} ) {
        my %more_params = 
            Getopt::Nearly::Everything::SpecParser->parse( $params{spec} );

        while ( my ($key, $val) = each %more_params ) {
            if (exists $params{$key}) {
                croak "The parameter [$key] was both passed to add_opt() and "
                    . "parsed from the spec. Please remove one or the other.";
            }
            $params{$key} = $val;
        }    
    }

    %params = $self->_fill_params( %params );

    $params{spec} = $self->_generate_opt_spec( %params )
        unless exists $params{spec};

    return %params;
}


# Generate an option specifier from the given parameters
sub _generate_opt_spec {
    my ($self, %params) = @_;

    croak "Every option requires a name, or a valid Getopt::Long spec.\n"
        unless $params{name};

    my $spec = join '|', grep { $_ } 
        $params{name},
        $params{short},
        $params{long}, 
        @{ $params{aliases} ||= [] };

    if ( ! exists $params{value_required} ) {
        return $spec . '!' if ! defined $params{data_type};
        return $spec . '!' if $params{data_type} eq 'flag';
        return $spec . '+' if $params{data_type} eq 'incr';
    }

    # TODO more stuff
    return;

}


# Fills in various parameters from the ones already known
sub _fill_params {
    my ($self, %params) = @_;
    
    # TODO fill in stuff
    $params{data_type} ||= 'flag';


    return %params;
}


# This sub cribbed from Data::Dump::Streamer to support
# making an alias for this package's name in the symbol table.
sub import {
    my ($pkg) = @_;
    my ($idx, $alias);

    if ($idx = (grep lc($_[$_]) eq 'as', 0..$#_)) {
        #print "found alias at $idx:\n";
        ($idx, $alias) = splice(@_, $idx, 2);
        #print "found alias: $idx => $alias\n";

        no strict 'refs';
        *{$alias.'::'} = *{__PACKAGE__.'::'};
    }
    $pkg->export_to_level(1,@_);
}


1 && q{GoNE, baby GoNE}; # truth

__END__

=head1 SYNOPSIS

  # I'm thinking the acronym GoNE...
  my $opts = Getopt::Nearly::Everything->new();
  my $opts = Getopt::Neurotically::Explicit->new();

  $opts->add_opt(
      name      => "foo"     # name used to refer to this option (default to
                             # the value of the 'long' parameter)
      short     => "f"       # use as -f
      long      => "foo"     # use as --foo
      aliases   => "bar|baz" # use as --bar or --baz
      data_type => "string"  # option type (string|flag|num|hash|etc...)
      multi     => "no"      # allow option to be specified multiple
                             # times (no|yes|group)
      default   => "wibble"  # default value if none specified
  
      depends   => "bar|baz" # option only valid if bar or baz is specified
      conflicts => "buh"     # option conflicts with option buh.
      required  => "yes"     # option is required (if depends are specified, only
                             # check after depends passes)
      help      => "..."     # text to show when -h is used to display help
      error     => "..."     # text to show if option does not validate
      group     => "fooz"    # When showing help, group this option with others
                             # who are assigned to fooz
  );

  # Possible alternative usage (more like Getopt::Long)
  # http://perldoc.perl.org/Getopt/Long.html#Summary-of-Option-Specifications
  # since I now have a working opt-spec parser, this should be *easy!*
  $opts->add_opt(
      spec      => "foo|f=s@" # using a real Getopt::Long spec would eliminate the
                              # need for many of the options in the above example.
      default   => \$foo      # store in this var
      store     => \$foo      # alias for default
  
      depends   => "bar|baz"  # option only valid if bar or baz is specified
      conflicts => "buh"      # option conflicts with option buh.
      required  => "yes"      # option is required (if depends are specified, only
                              # check after depends passes)
      help      => "..."      # text to show when -h is used to display help
      error     => "..."      # text to show if option does not validate
      group     => "fooz"     # When showing help, group this option with others
                              # who are assigned to fooz
  );


  # Another way to do it...
  $opts->add_opt( "foo|f=s@" => \$foo );
  $opts->set_help( foo => "each foo specified on the command line does ..." );
  $opts->set_error( foo => "foo needs to be a valid path, please check ..." );
  
=head1 EXPORT

=head2 GetOptions

=head1 METHODS

=head2 new

create a new option thingie

=head2 add_opt

add an option to handle


