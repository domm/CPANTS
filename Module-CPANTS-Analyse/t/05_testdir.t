use Test::More tests => 3;
use Test::NoWarnings;

use Module::CPANTS::Analyse;

my $a=Module::CPANTS::Analyse->new({dist => 'dummy'});
my $td=$a->testdir;

ok(-e $td,"testdir $td created");

my $td2=$a->testdir;
is($td,$td2,"still the same testdir");


