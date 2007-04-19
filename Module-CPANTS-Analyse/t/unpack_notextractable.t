use Test::More tests => 2;

use Module::CPANTS::Analyse;
use File::Spec::Functions;

my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/not_extractable.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;

like($rv,qr/Can.t call method .extract./,'unpack failed');
is($a->d->{extractable},0,'extractable');

