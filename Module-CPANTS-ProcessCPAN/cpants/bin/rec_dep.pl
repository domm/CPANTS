#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use Getopt::Long;
use YAML;
$YAML::UseAliases=0;$YAML::UseAliases=0; # f*&^ck warning

my ($dbfile,$dist);
GetOptions('sqlite=s'=>\$dbfile,
            'dist=s'=> \$dist);

my $dbh=DBI->connect('dbi:SQLite:dbname='.$dbfile);
my $dist_id=$dbh->selectrow_array("select id from dist where dist=?",undef,$dist);
if (!$dist_id) {
    print "Cannot find $dist in DB\n";
    exit;
}

my $dists=$dbh->selectall_hashref("select id,dist from dist",'id');

# fetch all prereq
my $sth=$dbh->prepare("select DISTINCT dist,in_dist from prereq where in_dist is not null");
$sth->execute;
my %prereq;
while (my ($id,$req)=$sth->fetchrow_array) {
    if ($prereq{$id}) {
        push(@{$prereq{$id}},$req);
    }
    else {
        $prereq{$id}=[$req];
    }
} 


my $cnt={};
my $result=resolve($dist_id,$cnt);
print Dump $result;
print "Total: ".((scalar keys %$cnt)-1)."\n";


# recursive dependency resolver
sub resolve {
    my ($id,$seen)=@_;
    my $dist=$dists->{$id}{dist};
    my @list;
    if ($seen->{$dist}) {
        return $prereq{$id};
    }
    $seen->{$dist}++;
    if (ref($prereq{$id}) eq 'ARRAY') {
        my %res;
        foreach my $req (@{$prereq{$id}}) {
            my $resolved=resolve($req,$seen);
            push(@{$res{$dist}},$resolved);
        }
        $prereq{$id}=\%res;
        return \%res;
    }
    elsif (ref($prereq{$id}) eq 'HASH') {
       return $prereq{$id};
    }
    else {
        return $dist;
    }
}

