use Test::More tests => 3;
use Test::Warn;

use Module::CPANTS::Analyse;
use File::Spec::Functions;

my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/not_extractable.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv;
warnings_are {$rv=$a->unpack} [
            'Invalid header block at offset unknown',
            'Invalid header block at offset unknown',
            'No data could be read from file',
            ]
            , 'unpack warns';

like($rv,qr/Can.t call method .extract./,'unpack failed');
is($a->d->{extractable},0,'extractable');

