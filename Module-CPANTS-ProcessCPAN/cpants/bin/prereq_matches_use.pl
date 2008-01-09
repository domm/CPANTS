#!/usr/bin/perl
use strict; 
use warnings;
use Module::CPANTS::ProcessCPAN;
use Module::CPANTS::DB;
use Module::CoreList;
use Parse::CPAN::Authors;
use Getopt::Long;

my %opts;
GetOptions(\%opts,qw(cpan=s));


my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan});
my $k=Module::CPANTS::Kwalitee->new;
my $available_kw=$k->available_kwalitee;
my @ind=$k->get_indicators;

my $dbh=$p->db->storage->dbh;

# build list of module->dist
my %modules;
{
    my $sth=$dbh->prepare("select module,dist from modules");
    $sth->execute;
    while (my ($module,$dist)=$sth->fetchrow_array) {
        $modules{$module}=$dist;
    }
}

# prereq_matches_use
{
    print "prereq_matches_use\n";
    my %uses;
    my %prereq;
    my $sth_uses=$dbh->prepare("select distinct dist,in_dist from uses where in_dist>0 AND in_code>0");
    $sth_uses->execute;
    print "uses\n";
    while (my ($dist,$in)=$sth_uses->fetchrow_array) {
        $uses{$dist}->{$in}=1;
    }
    print "prereq\n";
    my $sth_prereq=$dbh->prepare("select distinct dist,in_dist from prereq where in_dist>0 AND (is_prereq=1 OR is_optional_prereq=1)");
    $sth_prereq->execute;
    while (my ($dist,$in)=$sth_prereq->fetchrow_array) {
        $prereq{$dist}->{$in}=1;
    }
    
    foreach my $dist (keys %uses) {
        my $used=$uses{$dist};
        my $prereq=$prereq{$dist};
        next unless $prereq;
        my @missing;
        foreach my $use (keys %$used) {
            push(@missing,$use) unless $prereq->{$use};
        }
        if (@missing) {
            print "missing in $dist: ".join(', ',@missing),"\n";
        }
        else {
            print "ok $dist\n";
        }
    }
}

