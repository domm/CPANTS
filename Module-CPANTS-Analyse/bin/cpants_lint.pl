#!/usr/bin/perl -w
use strict;

use Module::CPANTS::Analyse;
use Getopt::Long;
use IO::Capture::Stdout;
use Data::Dumper;
use YAML;
use File::Spec::Functions;

my %opts;
GetOptions(\%opts,qw(dump no_capture! verbose! yaml to_file dir=s ));

my $dist=shift(@ARGV);

die "usage: cpants_lint.pl path/to/Foo-Dist-1.42.tgz\n" unless $dist;
die "Cannot find $dist\n" unless -e $dist;

my $mca=Module::CPANTS::Analyse->new({
    dist=>$dist,
    opts=>\%opts,
});

my $output;

my $cannot_unpack=$mca->unpack;

print $mca->dist,"\n";;
exit;
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
        my (@core_failure,@opt_failure);
        my ($core_kw,$opt_kw)=(0,0);
        my $kwl=$mca->d->{kwalitee};
        
        foreach my $ind (@{$mca->mck->get_indicators}) {
            if ($ind->{is_extra}) {
                next if $ind->{name} eq 'is_prereq';
                if ($kwl->{$ind->{name}}) {
                    $opt_kw++;
                } else {
                    push(@opt_failure,"* ".$ind->{name}."\n".$ind->{remedy});
                }
            } else {
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


        if ($total_kw == $max_kw -1) {  # -1 because of is_prereq
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
        }
    }
}

if ($opts{to_file}) {
    my $dir=$opts{dir} || '.';
    my $outfile=catfile($dir,$

} else {
    print $output;
}


__END__

=head1 NAME

cpants_lint.pl - commandline frontend to Module::CPANTS::Analyse

=head1 SYNOPSIS

  cpants_lint.pl path/to/Foo-Dist-1.42.tgz

=head1 DESCRIPTION

See C<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

=head1 LICENSE

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut


