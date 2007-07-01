use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Module::CPANTS::ProcessCPAN',
    license     => 'perl',
    requires    => {
        'Class::Accessor'               => '0.19',
        'Module::CPANTS::Analyse'       => '0.72',
        'Module::CoreList'              => '1.98',
        'Parse::CPAN::Authors'          => '2.24',
        'Parse::CPAN::Packages'         => '2.25',
        'DBIx::Class'                   => '0.06002',
        'GD::Graph'                     => '1.00',
        'DBD::Pg'                       => '1.49',
    },
    #script_files=>[qw()],
    create_makefile_pl=>'passthrough',
);


$build->create_build_script;

