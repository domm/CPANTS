#!/usr/bin/perl
use strict;
use warnings;
use Parse::CPAN::Authors;
use Module::CPANTS::ProcessCPAN;

die "Usage: update_authors.pl path/to/minicpan" unless @ARGV ==1;
my $path_cpan=shift(@ARGV);
my $mcp=Module::CPANTS::ProcessCPAN->new($path_cpan);
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

