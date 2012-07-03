#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

use lib qw( ../lib lib);

use Getopt::Nearly::Everything::SpecBuilder;

my $builder = Getopt::Nearly::Everything::SpecBuilder->new();

my @OPTION_PARAMS = (
        {
          'data_type' => 'flag',
          'aliases' => [],
          'name' => 'foo',
        },
        {
          'data_type' => 'flag',
          'negatable' => 1,
          'aliases' => [
                         'no-foo',
                         'nofoo'
                       ],
          'name' => 'foo',
        },
        {
          'value_required' => 0,
          'data_type' => 'integer',
          'dest_type' => '',
          'aliases' => [],
          'name' => 'foo',
        },
        {
          'value_required' => 1,
          'data_type' => 'string',
          'max_rep' => '5',
          'dest_type' => 'array',
          'min_rep' => '1',
          'aliases' => [
                         'f'
                       ],
          'name' => 'foo',
          'multi' => 1,
        },
);


for my $params ( @OPTION_PARAMS ) {
    my $spec = $builder->build( %$params );
    print Dumper $params, $spec;
    print "\n";
}


