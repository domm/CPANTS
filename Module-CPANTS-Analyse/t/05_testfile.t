use strict;
use warnings;

use Test::More tests => 4;
use Test::NoWarnings;

use Module::CPANTS::Analyse;
use File::Basename;

my $a=Module::CPANTS::Analyse->new({
    dist=>'D/DO/DOMM/Foo-Bar-1.05.tgz',
});

my $td=$a->testdir;
ok(-e $td,"testdir $td created");

$td=basename($td);
like($a->testfile,qr/$td/,"testdir in testfile");
like($a->testfile,qr/Foo-Bar/,"filename in testfile");

