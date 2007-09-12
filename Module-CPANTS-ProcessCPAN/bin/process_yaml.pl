#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN;
use Getopt::Long;
use File::Spec::Functions qw(rel2abs);

my %opts;
GetOptions(\%opts,qw(cpan=s lint=s dir=s));

die "Usage: analyse_cpan.pl --cpan path/to/minicpan --dir path/to/output/dir" unless $opts{cpan} && $opts{dir};

my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan});
$p->process_dir(rel2abs($opts{dir} || '.')); 
$p->force(1) if $opts{force};

$p->start_run->process_yaml;


