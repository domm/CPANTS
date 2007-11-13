use Test::More tests => 2;

use Module::CPANTS::DB;
my $db=Module::CPANTS::DB->connect('dbi:Pg:dbname=cpants');

my $dist=$db->resultset('Module::CPANTS::DB::Dist')->search(dist=>'Class-DBI');
is($dist,1);
my $dist=$dist->first;

is($dist->dist,'Class-DBI');

my $req=$dist->requiring;
while (my $r=$req->next) {
diag($r->dist->dist);
}

