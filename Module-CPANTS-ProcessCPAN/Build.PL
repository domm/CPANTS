use strict;
use warnings;
use lib qw(lib);
use Module::CPANTS::MyBuild;
use File::Spec::Functions qw(catdir);
use File::HomeDir;

my $build = Module::CPANTS::MyBuild->new(
    module_name => 'Module::CPANTS::ProcessCPAN',
    license     => 'perl',
    build_requires => {
        'File::HomeDir'                 => '0.66', 
    },
    requires    => {
        'Class::Accessor'               => '0.19',
        'Module::CPANTS::Analyse'       => '0.72',
        'Module::CoreList'              => '1.98',
        'Parse::CPAN::Authors'          => '2.24',
        'Parse::CPAN::Packages'         => '2.25',
        'DBIx::Class'                   => '0.06002',
        'GD::Graph'                     => '1.00',
        'DBD::SQLite'                   => '1.14',
        'version'                       => '0.73',
    },
    
    #root_files=>{
    #    'root/yaml_analysed/README'         => 'yaml/analysed/README',
    #    'root/yaml_processed/README'        => 'yaml/processed/README',
    #    'root/sqlite/cpants_tpl.db'         => 'sqlite/cpants_tpl.db',
    #    'root/sqlite/cpants_history_tpl.db' => 
    #    'sqlite/cpants_history_tpl.db',
    #},

    create_makefile_pl=>'passthrough',
);

my $root=$build->prompt(
    "Please specify the CPANTS root directory:",
    catdir(File::HomeDir->my_home,'cpants')
);
$build->config_data('root'=>$root);
$build->notes('uid',$<);

$build->create_build_script;

