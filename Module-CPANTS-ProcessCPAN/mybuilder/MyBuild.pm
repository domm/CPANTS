package MyBuild;
use strict;
use warnings;
use base qw(Module::Build);
use File::Copy;
use File::HomeDir;
use File::Spec::Functions qw(catdir catfile);

sub ACTION_install_cpants {
    my $self = shift;
    
    my $root;
    eval { require Module::CPANTS::ProcessCPAN::ConfigData };
    if ($@) {
        $root=$self->prompt("Cannot find CPANTS root dir from Module::CPANTS::ProcessCPAN::ConfigData.\nPlease specify the CPANTS root directory:", catdir(File::HomeDir->my_home,'cpants'));
    }
    else {
        $root=Module::CPANTS::ProcessCPAN::ConfigData->config('root');
    }
  
    local $> = $self->notes('uid');
  
    copy('templates/wrapper',$root.'/foobar');

    return;
}

sub ACTION_install {
    my $self = shift;

    $self->SUPER::ACTION_install;

    print <<EOMSG;

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
If you want to install the CPANTS application, run
  ./Build install_cpants
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOMSG
}


1;
