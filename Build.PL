use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Getopt::Nearly::Everything',
    license             => 'perl',
    dist_author         => 'Steve Scaffidi <sscaffidi@cpan.org>',
    dist_version_from   => 'lib/Getopt/Nearly/Everything.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Getopt-Nearly-Everything-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
