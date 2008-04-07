use strict;
use warnings;

use Module::CPANTS::MyBuild;
use File::Spec::Functions qw(catdir catfile);
use File::Find;

my $build = Module::CPANTS::MyBuild->new(
    module_name => 'Module::CPANTS::Site',
    license     => 'perl',
    build_requires => {
        'File::HomeDir'                    => '0.66', 
    },
    requires    => {
        'Catalyst'                         => '5.7000',
        'DBIx::Class'                      => '0.07000',
        'DBD::SQLite'                      => '1.14', 
        'Module::CPANTS::Analyse'          => '0.75',
        'Module::CPANTS::ProcessCPAN'      => '0.70',
        'Catalyst::Model::DBIC::Schema'    => '0.16',
        'Catalyst::View::TT'               => '0.23',
        'Catalyst::Plugin::ConfigLoader'   => '0.11', 
        'Catalyst::Plugin::Static::Simple' => '0.14',
        'version'                          => '0.73', 
        'Template::Plugin::Number::Format' => '1.02',
    },
    create_makefile_pl => 'traditional',

);

$build->notes('uid',$<);

$build->create_build_script;



