#!/usr/bin/perl
use strict;
use warnings;
use Parse::CPAN::Authors;
use Module::CPANTS::ProcessCPAN;
use Getopt::Long;
my %opts;
GetOptions(\%opts,qw(cpan=s));


die "Usage: update_authors.pl --cpan path/to/minicpan" unless $opts{cpan};
my $mcp=Module::CPANTS::ProcessCPAN->new($opts{cpan});
my $db=$mcp->db;

my $p = Parse::CPAN::Authors->new($mcp->cpan_01mailrc);

foreach my $auth ($p->authors) {
    my $pauseid=$auth->pauseid;
    my $a=$db->resultset('Author')->find_or_create(pauseid=>$pauseid);
    print "$pauseid\n";
    foreach (qw(name email)) {
        $a->$_($auth->$_);
    }
    $a->update;
}

