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
    
    create_makefile_pl=>'passthrough',
);

my $home=$build->prompt(
    "Please specify the CPANTS home directory:",
    catdir(File::HomeDir->my_home,'cpants')
);
$build->config_data('home'=>$home);
$build->notes('uid',$<);

$build->create_build_script;

