use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Module::CPANTS::Analyse',
    license     => 'perl',
    requires    => {
        'Class::Accessor'           => '0.19',
        'Archive::Any'              => '0.06',
        'Archive::Tar'              => '1.48', #depends on IO::Compress without memory leak
        'CPAN::DistnameInfo'        => '0.06',
	'ExtUtils::Manifest'        => '1.33',
        'Pod::Simple::Checker'      => '2.02',
        'YAML::Any'                 => '0.72',
        'Module::ExtractUse'        => '0.18',
        'Module::Pluggable'         => '2.96',
        'IO::Capture'               => '0.05',
        'Array::Diff'               => '0.04',
	'Test::CPAN::Meta::YAML'    => '0.17',
        'version'                   => '0.73',
        'List::MoreUtils'           => '0',
        'File::Find::Rule'          => '0',
        'Readonly'                  => '0',
        'Software::License'         => '0.003',
        'File::Slurp'               => '0',
        'Text::CSV_XS'              => '0.45',
        'LWP::Simple'               => 0,
        'perl'                      => 5.006,
    },
    build_requires => {
	'Module::Build'             => '0.38',
        'Test::More'                => '0',
        'Test::Deep'                => '0',
        'Test::Warn'                => '0.11', #less problems with new Sub::Uplevel
        'Test::NoWarnings'          => '0',
    },
    meta_merge => {
        resources => {
            repository => 'http://github.com/domm/CPANTS/tree',
        },
        keywords => [
            'CPANTS','kwalitee',
        ],
    },
    script_files=>[qw(bin/cpants_lint.pl)],
    create_makefile_pl=>'traditional',
);


$build->add_to_cleanup('Debian_CPANTS.txt');
$build->create_build_script;

