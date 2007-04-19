use Test::More tests => 2;

use Module::CPANTS::ProcessCPAN;

my $p=Module::CPANTS::ProcessCPAN->new('t/fakepan');

$p->start_run();
my $run=$p->run;

isa_ok($run,'Module::CPANTS::DB::Run','class');
is($run->version,$Module::CPANTS::Analyse::VERSION,'kwalitee version');


