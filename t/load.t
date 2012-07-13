#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
	use_ok( 'Getopt::Nearly::Everything' );
	use_ok( 'Getopt::Long::SpecParser' );
}

diag( "Testing Getopt::Nearly::Everything $Getopt::Nearly::Everything::VERSION, Perl $], $^X" );
