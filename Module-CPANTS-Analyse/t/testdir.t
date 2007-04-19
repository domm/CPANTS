use Test::More tests => 2;

use Module::CPANTS::Analyse;

my $a=Module::CPANTS::Analyse->new;
my $td=$a->testdir;

ok(-e $td,"testdir $td created");

my $td2=$a->testdir;
is($td,$td2,"still the same testdir");


