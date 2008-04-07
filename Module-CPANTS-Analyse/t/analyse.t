use Test::More tests => 1;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Acme-DonMartin-0.06.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;
$a->calc_kwalitee;

#use Data::Dumper;
#diag(Dumper $d);

