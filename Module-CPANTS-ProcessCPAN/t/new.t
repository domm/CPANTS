use Test::More tests => 2;

use Module::CPANTS::ProcessCPAN;

my $p=Module::CPANTS::ProcessCPAN->new('t/fakepan');

isa_ok($p,'Module::CPANTS::ProcessCPAN','object');
like($p->cpan,qr{t/fakepan$},'path to fake cpan');



