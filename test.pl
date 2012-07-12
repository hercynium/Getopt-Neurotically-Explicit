#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Data::Dumper;
use Getopt::Nearly::Everything;

my $go = Getopt::Nearly::Everything->new;

$go->add_opts(
  # flag
  {
    long => 'flag',
    short => 'f',
    opt_type => 'flag',
  },
  # negatable flag
  {
    long => 'negatable',
    short => 'n',
    negatable => 1,
    opt_type => 'flag',
  },
  # incremental
  {
    # incremental implies val_type=int, dest_type=scalar
    long => 'incremental',
    short => 'i',
    opt_type => 'increment',
  },
  # simple scalar string with optional value
  {
    long => 'simple1',
  },
  # simple scalar string with required value
  {
    long => 'simple2',
    value_required => 1,
  },
  # simple integer array (therefore multi_use) with required value
  {
    long => 'simple3',
    dest_type => 'array',
    val_type  => 'integer', # should shorten to Int
    value_required => 1,
  },
  # simple integer array with optional value
  {
    long => 'simple4',
    dest_type => 'array',
    val_type  => 'integer',
  },
  # simple string array with optional value
  {
    long => 'simple5',
    dest_type => 'array',
  },
  # simple scalar integer with optional value
  {
    long => 'simple6',
    val_type => 'integer',
    default_num => 7,
  },
  # simple scalar string with required value
  {
    long => 'simple7',
    val_type => 'integer',
    val_required => 0, # should fail if default is provided
    default_num => 7,  # should fail if val_type is not integer
  },
  {
    long => 'simple8',
    destination => \my @simple8,
  },
);


my $opt = $go->getopts(@ARGV);

print Dumper $opt;
print Dumper \@ARGV;
