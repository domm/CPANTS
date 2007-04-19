#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN;
use Getopt::Long;

my %opts;
GetOptions(\%opts,qw(force cpan=s lint=s));

die "Usage: analyse_cpan.pl --cpan path/to/minicpan --lint path/to/cpants_lint.pl" unless $opts{cpan} && $opts{lint};
die "Cannot find cpants_lint.pl (in ".$opts{lint}.")" unless -e $opts{lint};

my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan},$opts{lint});
$p->force(1) if $opts{force};
$p->start_run->process_cpan;


