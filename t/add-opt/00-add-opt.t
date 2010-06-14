#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok( 'Getopt::Nearly::Everything' );
}

my $opts = Getopt::Nearly::Everything->new();



