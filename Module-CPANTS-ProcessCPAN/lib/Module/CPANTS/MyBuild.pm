package Module::CPANTS::MyBuild;
use strict;
use warnings;
use base qw(Module::Build);
use File::Copy;
use File::HomeDir;
use File::Spec::Functions qw(catdir catfile splitdir);
use File::Find;

sub ACTION_install_cpants {
    my $self = shift;
    
    my $home;
    eval { require Module::CPANTS::ProcessCPAN::ConfigData };
    if ($@) {
        $home=$self->prompt("Cannot find CPANTS home dir from Module::CPANTS::ProcessCPAN::ConfigData.\nPlease specify the CPANTS home directory:", catdir(File::HomeDir->my_home,'cpants'));
    }
    else {
        $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');
    }
 
    local $> = $self->notes('uid');

    @MyBuild::dirs_to_copy=('');
    find(\&to_copy,'cpants');

    # make directories
    foreach my $dir (@MyBuild::dirs_to_copy) {
        my $realdir=catdir($home,$dir);
        if (-d $realdir) {
            print "Skipping $realdir\n";
            next;
        }
        print "mkdir $realdir\n";
        mkdir($realdir) || die "Cannot mkdir $realdir: $!";
    }

    # copy files
    foreach  my $file (@MyBuild::files_to_copy) {
        my $source=catdir('cpants',$file);
        my $target=catdir($home,$file);
        print "Copying $source -> $target\n";
        copy($source,$target) || die "Cannot copy $source -> $target: $!";
    }

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

sub to_copy {
    return if /^\.+$/;
    my @dir=splitdir($File::Find::dir);
    shift @dir;       # remove 'cpants/'
    if (-d) {
        push(@MyBuild::dirs_to_copy,catdir(@dir,$_));
    }
    elsif (-f) {
        push(@MyBuild::files_to_copy,catfile(@dir,$_));
    }
}


1;
