use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Module::CPANTS::Site',
    license     => 'perl',
    requires    => {
        'Catalyst'                         => '5.7000',
        'DBIx::Class'                      => '0.07000',
        'Module::CPANTS::Analyse'          => '0.60',
        'Module::CPANTS::ProcessCPAN'      => '0.60',
        'Catalyst::Model::DBIC::Schema'    => '0.16',
        'Catalyst::View::TT'               => '0.23',
        'Catalyst::Plugin::Static::Simple' => '0.14',
    },
    create_makefile_pl => 'traditional',
);

$build->create_build_script;

