use Test::More tests => 1;

use DBD::Pg;

# maybe better to dropdb, createdb & fill in schema

my $dbh=DBI->connect('dbi:Pg:dbname=test_cpants');
$dbh->do("delete from run");
$dbh->do("delete from kwalitee");
$dbh->do("delete from modules");
$dbh->do("delete from uses");
$dbh->do("delete from prereq");
$dbh->do("delete from dist");
is(1,1,'purged db'); # should check db status  


