use Test::More tests => 19;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Test-YAML-Meta-0.04.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;
is($d->{files},37,'files');
is(@{$d->{modules}},2,'module');

$a->calc_kwalitee;

my $kw=$a->d->{kwalitee};
is($kw->{has_changelog},1,'has_changelog');
is($kw->{has_version},1,'has_version');
is($kw->{has_tests},1,'has_tests');
is($kw->{proper_libs},1,'proper_libs');
is($kw->{extracts_nicely},1,'extracts_nicely');
is($kw->{no_pod_errors},1,'no_pod_errors');
is($kw->{has_test_pod},1,'has_test_pod');
is($kw->{has_test_pod_coverage},1,'has_test_pod_coverage');
is($kw->{use_strict},1,'use_strict');
is($kw->{has_example},1,'has_example');
is($kw->{buildtool_not_executable},1,'buildtool_not_executable');
is($kw->{no_cpants_errors},1,'no_cpants_errors');
is($kw->{metayml_has_license},1,'has license in META.yml');
is($kw->{metayml_conforms_to_known_spec},1,'META.yml conforms to a known version of the spec.');
is($kw->{metayml_conforms_spec_current},1,'META.yml conforms to v1.3 of the spec.');

is($kw->{kwalitee},27,'some kwalitee points');


