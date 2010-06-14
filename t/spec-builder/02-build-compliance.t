#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Exception;

### test that the builder always returns the expected spec
### from a set of option parameters and that the constructed
### specs that are always compatible with GoL

my @TEST_DATA = (
    [
        {
            'data_type' => 'flag',
            'aliases'   => [],
            'name'      => 'foo',
        },
        'foo',
    ],
    [
        {
            'name'      => 'bar',
            'aliases'   => ['b'],
            'data_type' => 'flag',
        },
        'bar|b',
    ],
### uncomment below array to see a test fail.
#    [
#        {
#            'name' => 'bar',
#            'aliases' => '',
#            'data_type' => 'flag',
#        },
#        'bar',
#    ],
);

my $tests_per_spec = 3;  ### keep in sync with tests in TEST loop

my $spec_count      = @TEST_DATA;
my $spec_test_count = $spec_count * $tests_per_spec;
my $use_test_count = 2;  # count of use_ok tests, below

plan( tests => $spec_test_count + $use_test_count );

my $CLASS = 'Getopt::Nearly::Everything::SpecBuilder';

use_ok( $CLASS ) or die "Couldn't compile [$CLASS]\n";
use_ok( 'Getopt::Long' ) or die "couldn't use [Getopt::Long]!\n";

# combining both good and bad sets in one loop 'cause I'm lazy...
# will separate if/when somebody needs it.

TEST:
for my $test_datum ( @TEST_DATA ) {

    my ( $opt_params, $expected_spec ) = @{$test_datum};

    my $valid_test_descr = "valid params are accepted by new()";

    my $params_are_valid
        = lives_ok( sub { $CLASS->new( $opt_params ) }, $valid_test_descr );

    SKIP: {
        skip( "additional compliance tests not needed on bad params", 2 )
            unless $params_are_valid;

        my $built_spec = $CLASS->new( $opt_params )->built_spec();
        is( $built_spec, $expected_spec,
            "matches the expected spec [$expected_spec]" );

        # if ! defined $opt_name, err msg is in $orig_opt_name. May throw
        # warnings if duplicate opt names are already in %opctl.
        # (not a problem here, but can be in real-life use)
        my %opctl;
        my ( $opt_name, $orig_opt_name )
            = Getopt::Long::ParseOptionSpec( $built_spec, \%opctl );

        ok( defined $opt_name,
            "built spec is compatible with GoL [$built_spec]" )
            or diag( $orig_opt_name );
    }
}

