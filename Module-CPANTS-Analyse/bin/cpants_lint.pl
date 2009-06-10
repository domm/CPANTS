#!/usr/bin/perl -w
use strict;

use Module::CPANTS::Analyse;
use Getopt::Long;
use IO::Capture::Stdout;
use Data::Dumper;
use YAML::Syck;
use File::Spec::Functions;
use Cwd;
use Pod::Usage;

my %opts;
GetOptions(\%opts,qw(help|? man dump no_capture! verbose! yaml to_file dir=s experimental!));
pod2usage(1) if $opts{help};
pod2usage(-exitstatus => 0, -verbose => 2) if $opts{man};

my $cwd=getcwd();

my $dist=shift(@ARGV);
pod2usage(-exitstatus => 0, -verbose => 0) unless $dist;
die "Cannot find $dist\n" unless -e $dist;

$ENV{CPANTS_LINT} = 1;

my $mca=Module::CPANTS::Analyse->new({
    dist=>$dist,
    opts=>\%opts,
});
my $output;

my $cannot_unpack=$mca->unpack;

if ($cannot_unpack) {
    if ($opts{dump}) {
        $output=Dumper($mca->d);
    } elsif ($opts{yaml}) {
        $output=Dump($mca->d);
    } else {
        $output="Cannot unpack \t\t".$mca->tarball."\n";
    }
} 
else {
    $mca->analyse;
    $mca->calc_kwalitee;

    if ($opts{dump}) {
        $Data::Dumper::Sortkeys=1;
        $output=Dumper($mca->d);
    } elsif ($opts{yaml}) {
        $output=Dump($mca->d);
    } else {
    
        # build up lists of failed metrics
        my (@core_failure,@opt_failure,@exp_failure);
        my ($core_kw,$opt_kw)=(0,0);
        my $kwl=$mca->d->{kwalitee};
 
        my @need_db;
        foreach my $ind (@{$mca->mck->get_indicators}) {
            if ($ind->{needs_db}) {
                push(@need_db,$ind);
                next;
            }
            if ($ind->{is_extra}) {
                next if $ind->{name} eq 'is_prereq';
                if ($kwl->{$ind->{name}}) {
                    $opt_kw++;
                } else {
                    push(@opt_failure,"* ".$ind->{name}."\n".$ind->{remedy});
                }
            }
            elsif ($ind->{is_experimental}) {
                next unless $opts{experimental};
                if (!$kwl->{$ind->{name}}) {
                    push(@exp_failure,"* ".$ind->{name}."\n".$ind->{remedy});
                }
            }
            else {
                if ($kwl->{$ind->{name}}) {
                    $core_kw++;
                } else {
                    push(@core_failure,"* ".$ind->{name}."\n".$ind->{remedy});
                }
            }
        }

        # output results 
        $output.="Checked dist \t\t".$mca->tarball."\n";

        my $max_core_kw=$mca->mck->available_kwalitee;
        my $max_kw=$mca->mck->total_kwalitee;
        my $total_kw=$core_kw+$opt_kw;

        $output.="Kwalitee rating\t\t".sprintf("%.2f",100*$total_kw/$max_core_kw)."% ($total_kw/$max_core_kw)\n";
        if (@need_db) {
            $output.="Ignoring metrics\t".join(', ',map {$_->{name} } @need_db);
        }

        if ($total_kw == $max_kw - @need_db) {
            $output.="\nCongratulations for building a 'perfect' distribution!\n";
        } else {
            if (@core_failure) {
                $output.="\nHere is a list of failed Kwalitee tests and\nwhat you can do to solve them:\n\n";
                $output.=join ("\n\n",@core_failure,'');
            }
            if (@opt_failure) {
                $output.="\nFailed optional Kwalitee tests and\nwhat you can do to solve them:\n\n";
                $output.=join ("\n\n",@opt_failure,'');
            }
            if (@exp_failure) {
                $output.="\nFailed experimental Kwalitee tests and\nwhat you can do to solve them:\n\n";
                $output.=join ("\n\n",@exp_failure,'');
            }
        }
    }
}

if ($opts{to_file}) {
    my $dir=$opts{dir} || $cwd ;
    my $extension='.txt';
    $extension='.dmp' if $opts{dump};
    $extension='.yml' if $opts{yaml};
    my $outfile=catfile($dir,$mca->d->{vname}.$extension);
    open (my $fh,'>',$outfile) || die "Cannot write to $outfile: $!";
    print $fh $output;
    close $fh;

} else {
    print $output;
}


__END__

=head1 NAME

cpants_lint.pl - commandline frontend to Module::CPANTS::Analyse

=head1 SYNOPSIS

    cpants_lint.pl path/to/Foo-Dist-1.42.tgz

    Options:
        --help              brief help message
        --man               full documentation
        --verbose           print more info during run
        --no_capture        don't turn on capturing of STDERR and STDOUT
        
        --dump              dump result using Data::Dumper
        --yaml              dump result as YAML
        
        --to_file           dump result to a file
        --dir               directory to dump files to


=head1 DESCRIPTION

C<cpants_lint.pl> checks the B<Kwalitee> of CPAN distributions. More exact, it checks how a given tarball will be ratend on C<http://cpants.perl.org>, without needing to upload it first.

C<cpants_lint.pl> is also used by C<cpants.perl.org> itself to check all dists on CPAN.

For more information on Kwalitee, and the whole of CPANTS, see C<http://cpants.perl.org> and / or C<Module::CPANTS::Analyse>.

=head1 OPTIONS

If neither C<--dump> nor C<--yaml> are used, a short text describing the 
Kwalitee of the distribution and hints on how to raise Kwalitee will be 
displayed. The format of this text can change anytime, so don't use it for any 
automated processing!

=head3 --help 

Print a brief help message.

=head3 --man

Print manpage.

=head3 --verbose

Print some informative messages during testing of dists.

=head3 --no_capture

Turn off capturing of STDOUT and STDERR. Mostly usefull during debugging / development of new features. 

If C<--no_capture> is used, the value of C<cpants_error> might be wrong.

=head3 --dump

Dump the result using Data::Dumper

=head3 --yaml

Dump the result as YAML.

=head3 --to_file

Output the result into a file instead of STDOUT.

The name of the file will be F<Foo-Dist.yaml> (well, the extension depends on the dump format and can be C<.yaml>, C<.dump> or C<.txt>)

=head3 --dir

Directory to dump files to. Defaults to the current working directory.

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2006, 2009  Thomas Klausner

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut


