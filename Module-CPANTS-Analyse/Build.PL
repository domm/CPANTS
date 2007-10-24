use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Module::CPANTS::Analyse',
    license     => 'perl',
    requires    => {
        'Class::Accessor'           => '0.19',
        'Archive::Any'              => '0.06',
        'Archive::Tar'              => '1.30',
        'CPAN::DistnameInfo'        => '0.06',
        'Pod::Simple::Checker'      => '2.02',
        'YAML::Syck'                => '0.95',
        'Module::ExtractUse'        => '0.18',
        'Module::Pluggable'         => '2.96',
        'IO::Capture'               => '0.05',
        'Array::Diff'               => '0.04',
        'Test::YAML::Meta::Version' => '0.04',
        'version'                   => '0.73',
    },
    script_files=>[qw(bin/cpants_lint.pl)],
    create_makefile_pl=>'traditional',
);


$build->create_build_script;

