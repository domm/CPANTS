#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN::ConfigData;
use Module::CPANTS::ProcessCPAN;
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

print "start\n";
my $lockfile=catfile($home,'cpants_is_analysing');
system("touch $lockfile") && print "error: cant touch $lockfile: $!\n";

print "analyse_cpan.pl\n";
system("$perl $bin/analyse_cpan.pl --cpan $cpan --lint $lint $force") && print "error analyse_cpan.pl $!\n";

print "run_complex_db_stuff.pl\n";
system("$perl $bin/run_complex_db_stuff.pl --cpan $cpan") && print "error run_complex_stuff $!\n";

print "update_authors\n";
system("$perl $bin/update_authors.pl --cpan $cpan") && print "error update_authors $!\n";

print "make_graphs\n";
system("$perl $bin/make_graphs.pl") && print "error make_graphs $!\n";

print "make_distgraph\n";
system("$perl $bin/make_distgraph.pl") && print "error make_distgraph $!\n";

print "dump_sqlite\n";
system("$perl $bin/dump_sqlite.pl") && print "error dump_sqlite $!\n";

Module::CPANTS::ProcessCPAN->stop_run;

unlink($lockfile);
print "done!\n";

