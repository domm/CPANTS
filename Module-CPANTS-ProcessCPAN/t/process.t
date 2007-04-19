use Test::More tests => 1;

use Module::CPANTS::ProcessCPAN;

my $p=Module::CPANTS::ProcessCPAN->new('t/fakepan');

$p->start_run->process_cpan;


