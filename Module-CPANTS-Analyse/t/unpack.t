use Test::More tests => 5;

use Module::CPANTS::Analyse;
use File::Spec::Functions;

my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Acme-DonMartin-0.06.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

ok(-d catdir($a->testdir,'Acme-DonMartin-0.06'),'dist dir');
ok(-e catfile($a->testdir,'Acme-DonMartin-0.06','META.yml'),'dist meta yaml');
is($a->distdir,catdir($a->testdir,'Acme-DonMartin-0.06'),'$a->distdir');
is($a->d->{size_packed},7736,'size_packed');

