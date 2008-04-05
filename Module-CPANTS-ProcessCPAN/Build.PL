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
        'Module::CPANTS::Analyse'       => '0.77',
        'Module::CoreList'              => '1.98',
        'Parse::CPAN::Authors'          => '2.24',
        'Parse::CPAN::Packages'         => '2.25',
        'DBIx::Class'                   => '0.06002',
        'GD::Graph'                     => '1.00',
        'DBD::Pg'                       => '1.49',
        'version'                       => '0.73',
        'File::HomeDir'                 => '0.66',
    },
    
    create_makefile_pl=>'passthrough',
);

my %prompt_defaults;
eval { require Module::CPANTS::ProcessCPAN::ConfigData };
if ($@) {
    $prompt_defaults{'home'}    = catdir(File::HomeDir->my_home,'cpants'),
    $prompt_defaults{'db_user'} = 'cpants',
    $prompt_defaults{'db_pwd'}  = 'cpants',
} else {
    foreach (qw(home db_user db_pwd)) {
        $prompt_defaults{$_}=Module::CPANTS::ProcessCPAN::ConfigData->config($_);
    }
}


my $home=$build->prompt("Please specify the CPANTS home directory:",$prompt_defaults{'home'});
$build->config_data('home'=>$home);

$build->config_data('db_user'=>$build->prompt("Postgres DB user:",$prompt_defaults{'db_user'}));
$build->config_data('db_pwd'=>$build->prompt("Postgres DB password:",$prompt_defaults{'db_user'}));


$build->notes('uid',$<);

$build->create_build_script;

