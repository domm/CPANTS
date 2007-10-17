#!/usr/bin/perl
use strict;
use warnings;
use Module::CPANTS::ProcessCPAN;
use Getopt::Long;
use File::Spec::Functions qw(rel2abs);

my %opts;
GetOptions(\%opts,qw(cpan=s));

die "Usage: analyse_cpan.pl --cpan path/to/minicpan" unless $opts{cpan};

my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan});
$p->force(1) if $opts{force};

$p->start_run->process_yaml;


