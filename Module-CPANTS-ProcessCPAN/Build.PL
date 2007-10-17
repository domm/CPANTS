use strict;
use Module::Build;
use File::Spec::Functions qw(catdir);

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
    
    root_files=>{
        'root/yaml_analysed/README'         => 'yaml/analysed/README',
        'root/yaml_processed/README'        => 'yaml/processed/README',
        'root/sqlite/cpants_tpl.db'         => 'sqlite/cpants_tpl.db',
        'root/sqlite/cpants_history_tpl.db' => 'sqlite/cpants_history_tpl.db',
    },

    create_makefile_pl=>'passthrough',
);
$build->add_build_element('root');

my $root=$build->prompt("Please specify the CPANTS root directory", "/usr/local/cpants");

$build->config_data('root'=>$root);
$build->install_path->{'yaml'}=catdir($root,'yaml');
$build->install_path->{'sqlite'}=catdir($root,'sqlite');
$build->install_path->{'script'}=catdir($root,'bin');

$build->create_build_script;

