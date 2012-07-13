package Getopt::Nearly::Everything;
# ABSTRACT: Nearly everything you'd ever want from a Getopt module!
# AKA, Getopt::Neurotically::Explicit, or GoNE
use Moo;
use Carp;
use Exporter;
use Data::Dumper;


# Turns a Getopt::Long (GoL) spec into args for GoNE
use Getopt::Long::SpecParser;
use Getopt::Nearly::Everything::Option;

## Base Getopt::Long config flags to use for GoNE
use Getopt::Long qw();

#qw(
#  GetOptionsFromArray
#  :config
#    ignore_case
#    gnu_getopt
#    bundling_override
#    no_auto_abbrev
#);

sub add_option { goto &add_opt }

sub add_opt {
    my ($self, %params) = @_;

    my %opt_params = $self->_process_params( %params );
    
    my $opt = Getopt::Nearly::Everything::Option->new(%opt_params);

    $self->{opts}{$opt->name} = $opt;

    return $self;
}

sub add_options { goto &add_opts }

sub add_opts {
  my ($self, @opt_attrs) = @_;
  $self->add_opt(%$_) for @opt_attrs;
  return $self;
}

sub getopts {
    my ($self, @args) = @_;

    my $gol = Getopt::Long::Parser->new(
        config => [qw(
            ignore_case
            gnu_getopt
            bundling_override
            no_auto_abbrev
        )]
    );
    my %opt;
    local @ARGV = @args;
    $gol->getoptions(
        \%opt,
        (map { $self->opt($_)->spec } $self->opt_names),
    );
print Dumper [(map { $self->opt($_)->spec } $self->opt_names)];
    return \%opt;
}


sub _process_params {
    my ($self, %params) = @_;

    # If a GoL spec was used,parse it into GoNE params
    # and merge those into the passed params.
    if ( exists $params{spec} ) {
        my %more_params = 
            Getopt::Long::SpecParser->parse( $params{spec} );

        while ( my ($key, $val) = each %more_params ) {
            next if $key eq 'name';
            if (exists $params{$key}) {
                croak "The parameter [$key] was both passed to add_opt() and parsed "
                    . "from the spec [$params{spec}]. Please change one or the other.";
            }
            $params{$key} = $val;
        }    
    }

    # we no longer need the spec if it was used.
    delete $params{spec};

    return %params;
}

sub opt_names {
  my ($self) = @_;
  return keys %{$self->{opts} || {}}
}

sub opt {
  my ($self, $opt_name) = @_;
  return $self->{opts}{$opt_name};
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
      dest_type => "string"  # option type (string|flag|inte...)
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


