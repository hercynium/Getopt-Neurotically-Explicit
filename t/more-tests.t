#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Data::Dumper;
use Test::More;

use_ok 'Getopt::Nearly::Everything';

my $go = Getopt::Nearly::Everything->new;

my @opts = (
    {
        name  => 'flag',
        spec  => 'flag|f',
        attrs => {
            long     => 'flag',
            short    => 'f',
            opt_type => 'flag',
        },
    }, {
        name  => 'negatable',
        spec  => 'negatable|n!',
        attrs => {
            long      => 'negatable',
            short     => 'n',
            negatable => 1,
            opt_type  => 'flag',
        },
    }, {
        name  => 'incremental',
        spec  => 'incremental|i+',
        attrs => {
            long     => 'incremental',
            short    => 'i',
            opt_type => 'increment',
        },
    }, {
        name  => 'simple1',
        spec  => 'simple1:s',
        attrs => { long => 'simple1', },
    }, {
        name  => 'simple2',
        spec  => 'simple2=s',
        attrs => {
            long         => 'simple2',
            val_required => 1,
        },
    }, {
        name  => 'simple3',
        spec  => 'simple3=i@',
        attrs => {
            long         => 'simple3',
            dest_type    => 'array',
            val_type     => 'integer',
            val_required => 1,
        },
    }, {
        name  => 'simple4',
        spec  => 'simple4:i@',
        attrs => {
            long      => 'simple4',
            dest_type => 'array',
            val_type  => 'integer',
        },
    }, {
        name  => 'simple5',
        spec  => 'simple5:s@',
        attrs => {
            long      => 'simple5',
            dest_type => 'array',
        },
    }, {
        name  => 'simple6',
        spec  => 'simple6:7',
        attrs => {
            long        => 'simple6',
            default_num => 7,
        },
    }, {
        name  => 'simple7',
        spec  => 'simple7:7',
        attrs => {
            long         => 'simple7',
            val_type     => 'integer',
            val_required => 0,
            default_num  => 7,
        },
    }, {
        name  => 'simple8',
        spec  => 'simple8:s@',
        attrs => {
            long        => 'simple8',
            destination => \my @simple8,
        },
    },
);

$go->add_opts( map { $_->{attrs} } @opts );

for my $opt ( @opts ) {
  my $built_spec = $go->opt($opt->{name})->spec;
  is $built_spec, $opt->{spec}, 'built spec matches expected spec'
    or diag Dumper $opt;
}

#my $opt = $go->getopts( @ARGV );

#print Dumper $opt;
#print Dumper \@ARGV;
done_testing;
