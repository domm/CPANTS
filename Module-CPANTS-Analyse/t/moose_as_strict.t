use strict;
use warnings;

use Test::More tests => 4;
use Test::NoWarnings;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/DBIx-SchemaChecksum-0.06.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;
$a->calc_kwalitee;

my $d=$a->d;
is($d->{uses}{'Moose'}{in_code},1,'uses Moose');
is($d->{kwalitee}{use_strict},1,'uses strict via Moose');

