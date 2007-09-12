#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN;
use Getopt::Long;
use File::Spec::Functions qw(rel2abs);

my %opts;
GetOptions(\%opts,qw(cpan=s lint=s dir=s force));

die "Usage: analyse_cpan.pl --cpan path/to/minicpan --lint path/to/cpants_lint.pl --dir path/to/output/dir" unless $opts{cpan} && $opts{lint};
die "Cannot find cpants_lint.pl (in ".$opts{lint}.")" unless -e $opts{lint};

my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan},$opts{lint});
$p->process_dir(rel2abs($opts{dir} || '.')); 
$p->force(1) if $opts{force};

$p->process_cpan;


