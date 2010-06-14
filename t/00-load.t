#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Getopt::Nearly::Everything' );
	use_ok( 'Getopt::Nearly::Everything::SpecParser' );
}

diag( "Testing Getopt::Nearly::Everything $Getopt::Nearly::Everything::VERSION, Perl $], $^X" );
