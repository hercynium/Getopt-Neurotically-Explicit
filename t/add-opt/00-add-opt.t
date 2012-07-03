#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok( 'Getopt::Nearly::Everything' );
}

my $opts = Getopt::Nearly::Everything->new();

# test setting all opts explicitly
my @foo = qw(wibble wobble);
$opts->add_opt(
  name            => 'foo',
  opt_type        => 'value',
  short           => 'f',
  long            => 'foo',
  aliases         => [qw(bar baz)],
  negations       => [qw(nometa no-bar)],
  auto_negations  => 1, # auto-generate additional negations from long and aliases
  short_negations => 1,
  value_type      => 'string',
  default         => 'wheeee',
  multi           => 1,
  min_rep         => 0,
  max_rep         => 3,
  dest_type       => 'array',
  destination     => \@foo,
  value_required  => 1,
  usage           => q{use once for every metasyntactic word you want},
  info            => q{this would be a larger discussion on what this option is for etc},
  error           => q{foo must be a valid metasyntactic word},
  group           => 'some_group',
);

# test using a spec to set as many implicit opts as possible
my @wacko = (1,2);
$opts->add_opt(
  spec           => 'wacko|wibble|w=i@{1,3}',
  destination    => \@wacko,
  auto_negations => 1, # auto-generate additional negations from long and aliases
  usage          => q{use once for every metasyntactic word you want},
  info           => q{this would be a larger discussion on what this option is for etc},
  error          => q{foo must be a valid metasyntactic word},
  group          => 'some_group',
);

$opts->add_opt(
  spec => 'weeble|e|b+',
);

$opts->add_opt(
  spec => 'fizz|z|buzz|u!',
);

for my $name ($opts->opt_names) {
  my $opt = $opts->opt($name);
  diag Dumper($opt, $opt->spec);
}

done_testing;

