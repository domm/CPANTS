#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN::ConfigData;
use File::Spec::Functions;
use Getopt::Long;
use FindBin;
my ($cpan,$lint,$force);
GetOptions(
    'cpan=s' => \$cpan,
    'lint=s' => \$lint,
    'force'  => \$force,
);

die "Usage: run.pl --cpan path/to/minicpan --lint path/to/cpants_lint.pl" unless $cpan && $lint;
die "Cannot find cpants_lint.pl (in $lint)" unless -e $lint;

my $perl=$^X;
my $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');
my $bin=catdir($home,'bin');
$force = $force ? '--force' : '';

my $lockfile=catfile($home,'cpants_is_analysing');
system("touch $lockfile");
system("$perl $bin/analyse_cpan.pl --cpan $cpan --lint $lint $force");
system("$perl $bin/run_complex_db_stuff.pl --cpan $cpan");
system("$perl $bin/update_authors.pl --cpan $cpan");
system("$perl $bin/make_graphs.pl");
system("$perl $bin/make_distgraph.pl");
system("$perl $bin/dump_sqlite.pl");
Module::CPANTS::ProcessCPAN->stop_run;
unlink($lockfile);
