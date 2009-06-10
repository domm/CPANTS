package Module::CPANTS::Analyse;
use strict;
use warnings;
use base qw(Class::Accessor);
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catfile catdir splitpath);
use File::Copy;
use Archive::Any;
use Carp;
use Module::CPANTS::Kwalitee;
use IO::Capture::Stdout;
use IO::Capture::Stderr;
use YAML::Syck qw(LoadFile);

use version; our $VERSION=version->new('0.83');

# setup logger
if (! main->can('logger')) {
    *main::logger = sub {
        print "## $_[0]\n" if $main::logging;
    };
}

use Module::Pluggable search_path=>['Module::CPANTS::Kwalitee'];

__PACKAGE__->mk_accessors(qw(dist opts tarball distdir d mck capture_stdout capture_stderr));
__PACKAGE__->mk_accessors(qw(_testdir _dont_cleanup _tarball));


sub new {
    my $class=shift;
    my $opts=shift || {};
    $opts->{d}={};
    $opts->{opts} ||= {};
    my $me=bless $opts,$class;
    $main::logging = 1 if $me->opts->{verbose};
    Carp::croak("need a dist") if not defined $opts->{dist};
    main::logger("distro: $opts->{dist}");

    $me->mck(Module::CPANTS::Kwalitee->new);
    
    unless ($me->opts->{no_capture} or $INC{'Test/More.pm'}) {
        my $cserr=IO::Capture::Stderr->new;
        my $csout=IO::Capture::Stdout->new;
        $cserr->start;
        $csout->start;
        $me->capture_stderr($cserr);
        $me->capture_stdout($csout);
    }
    return $me; 
}

sub unpack {
    my $me=shift;
    return 'cant find dist' unless $me->dist;

    copy($me->dist,$me->testfile);
    $me->d->{size_packed}=-s $me->testfile;
    
    my $archive;
    eval {
        $archive=Archive::Any->new($me->testfile);
        $archive->extract($me->testdir);
    };

    if (my $error=$@) {
        if (not $INC{'Test/More.pm'}) {
            $me->capture_stdout->stop;
            $me->capture_stderr->stop;
        }
        $me->d->{extractable}=0;
        $me->d->{error}{cpants}=$error;
        $me->d->{kwalitee}{extractable}=0;
        my ($vol,$dir,$name)=splitpath($me->dist);
        $name=~s/\..*$//;
        $name=~s/\-[\d\.]+$//;
        $me->d->{dist}=$name;
        return $error;
    }
    
    $me->d->{extractable}=1;
    unlink($me->testfile);
   
    opendir(my $fh_testdir,$me->testdir) || die "Cannot open ".$me->testdir.": $!";
    my @stuff=grep {/\w/} readdir($fh_testdir);
    my $di=CPAN::DistnameInfo->new($me->dist);

    if (@stuff == 1) {
        $me->distdir(catdir($me->testdir,$stuff[0]));
        $me->d->{extracts_nicely}=1 if $di->distvname eq $stuff[0];
        
    } else {
        $me->distdir(catdir($me->testdir));
        $me->d->{extracts_nicely}=0;
    }
    return;
}

sub analyse {
    my $me=shift;

    foreach my $mod (@{$me->mck->generators}) {
        main::logger("analyse $mod");
        $mod->analyse($me);
    }
}

sub calc_kwalitee {
    my $me=shift;

    my $kwalitee=0;
    $me->d->{kwalitee}={};
    foreach my $mod (@{$me->mck->generators}) {
        foreach my $i (@{$mod->kwalitee_indicators}) {
            next if $i->{needs_db};
            main::logger($i->{name});
            my $rv=$i->{code}($me->d, $i);
            $me->d->{kwalitee}{$i->{name}}=$rv;
            $kwalitee+=$rv;
        }
    }
    $me->d->{'kwalitee'}{'kwalitee'}=$kwalitee;
    main::logger("done");
}

#----------------------------------------------------------------
# helper methods
#----------------------------------------------------------------

sub testdir {
    my $me=shift;
    return $me->_testdir if $me->_testdir;
    if ($me->_dont_cleanup) {
        return $me->_testdir(tempdir());
    } else {
        return $me->_testdir(tempdir(CLEANUP => 1));
    }
}

sub testfile {
    my $me=shift;
    return catfile($me->testdir,$me->tarball); 
}

sub tarball {
    my $me=shift;
    return $me->_tarball if $me->_tarball;
    my (undef,undef,$tb)=splitpath($me->dist);
    return $me->_tarball($tb);
}



q{Favourite record of the moment:
  Jahcoozi: Pure Breed Mongrel};

__END__

=pod

=head1 NAME

Module::CPANTS::Analyse - Generate Kwalitee ratings for a distribution

=head1 SYNOPSIS
    
    use Module::CPANTS::Analyse;

    my $analyser=Module::CPANTS::Analyse->new({
        dist=>'path/to/Foo-Bar-1.42.tgz',
    });
    $analyser->unpack;
    $analyser->analyse;
    $analyser->calc_kwalitee;
    # results are in $analyser->d;
  
=head1 DESCRIPTION

=head2 Methods

=head3 new

  my $analyser=Module::CPANTS::Analyse->new({dist=>'path/to/file'});

Plain old constructor.

=head3 unpack

Unpack the distribution into a temporary directory.

Returns an error if something went wrong, C<undef> if all went well.

=head3 analyse

Run all analysers (defined in C<Module::CPANTS::Kwalitee::*> on the dist.

=head3 calc_kwalitee

Check if the dist conforms to the Kwalitee indicators. 

=head2 Helper Methods

=head3 testdir

Returns the path to the unique temp directory.

=head3 testfile

Returns the location of the unextracted tarball.

=head3 tarball

Returns the filename of the tarball.

=head3 read_meta_yml

Reads the META.yml file and returns its content.

=head1 WEBSITE

http://cpants.perl.org/

=head1 BUGS

Please report any bugs or feature requests, or send any patches, to
bug-module-cpants-analyse at rt.cpan.org, or through the web interface at
http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-CPANTS-Analyse.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

Please use the perl-qa mailing list for discussing all things CPANTS:
http://lists.perl.org/showlist.cgi?name=perl-qa

Based on work by Leon Brocard <acme@astray.com> and the original idea
proposed by Michael G. Schwern <schwern@pobox.com>

=head1 LICENSE

This code is Copyright (c) 2003-2006 Thomas Klausner.
All rights reserved.

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut

