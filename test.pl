#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Data::Dumper;
use Getopt::Nearly::Everything;

my $go = Getopt::Nearly::Everything->new;

# flag
$go->add_option(
   long => 'flag',
   short => 'f',
   opt_type => 'flag',
);

# negatable flag
$go->add_option(
   long => 'negatable',
   short => 'n',
   negatable => 1,
   opt_type => 'flag',
);

# incremental
$go->add_option(
   # incremental implies val_type=int, dest_type=scalar
   long => 'incremental',
   short => 'i',
   opt_type => 'increment',
);

# simple scalar string with optional value
$go->add_option(
  long => 'simple1',
  dest_type => 'scalar',
  val_type => 'string',
  opt_type => 'simple',
);

# simple scalar string with required value
$go->add_option(
  long => 'simple2',
  dest_type => 'scalar', # should this be the default for opt_type simple?
  val_type => 'string',  # should be the default for opt_type simple
  value_required => 1,
  opt_type => 'simple',  # should be the default when not specified
);

# simple integer array (therefore multi_use) with required value
$go->add_option(
  long => 'simple3',
  dest_type => 'array',
  val_type  => 'integer', # should shorten to Int
  value_required => 1,
  opt_type => 'simple',
);

# simple integer array with optional value
$go->add_option(
  long => 'simple4',
  dest_type => 'array',
  val_type  => 'integer',
  opt_type => 'simple',
);

# simple string array with optional value
$go->add_option(
  long => 'simple5',
  dest_type => 'array',
  val_type  => 'string', # should shorten to Str
  opt_type => 'simple',
);

# simple scalar integer with optional value
$go->add_option(
    long => 'simple6',
    dest_type => 'scalar',
    val_type => 'integer',
    opt_type => 'simple',
    default_num => 7,
);

# simple scalar string with required value
$go->add_option(
    long => 'simple7',
    dest_type => 'scalar',
    val_type => 'integer',
    val_required => 0, # should fail if default is provided
    opt_type => 'simple',
    default_num => 7,  # should fail if val_type is not integer
);



my $opt = $go->getopts(@ARGV);

print Dumper $opt;
print Dumper \@ARGV;
