#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib );
use Getopt::Nearly::Everything;

my $opts = Getopt::Nearly::Everything->new();


#$opts->add_opt( spec => 'foo|f!' );
#$opts->add_opt( spec => 'foo|f+' );
#$opts->add_opt( spec => 'foo|f=i' );
#$opts->add_opt( spec => 'foo|f:i' );
#$opts->add_opt( spec => 'foo|f:+' );
#$opts->add_opt( spec => 'foo|f:5' );
#exit;

$opts->add_opt( name => 'foo' );
$opts->add_opt( name => 'foo', data_type => 'flag' );
exit;

$opts->add_opt( spec => 'foo|f|g|h' );


$opts->add_opt( spec => 'bar|b=s@{1,5}');

$opts->add_opt( spec => 'bar|b=s@{1,}');
$opts->add_opt( spec => 'bar|b=s@{1}');
$opts->add_opt( spec => 'bar|b=s@{,5}');

$opts->add_opt( spec => 'bar|b=s@{,}'); # this *should* be invalid, but meh...





