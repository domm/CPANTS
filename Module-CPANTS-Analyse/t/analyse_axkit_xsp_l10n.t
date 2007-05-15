use Test::More tests => 15;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/AxKit-XSP-L10N-0.03.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

is($d->{files},28,'files');
is($d->{size_packed},14486,'size_packed');
is(ref($d->{modules}),'ARRAY','modules is ARRAY');
is($d->{modules}[0]->{module},'AxKit::XSP::L10N','module');
is(ref($d->{prereq}),'ARRAY','prereq is ARRAY');
is($d->{prereq}[0]->{requires},'mod_perl','prereq');
is(ref($d->{uses}),'HASH','uses is HASH');
is($d->{uses}{'Test::More'}{in_tests},6,'uses');
ok($d->{file_meta_yml},'has_yaml');
ok(!$d->{metayml_is_parsable},'metayml_is_parsable is false');
ok($d->{metayml_parse_error},'metayml_parse_error was set');
is($d->{license},'defined in ./LICEN[CS]E','LICENSE defined in file');
ok(!defined($d->{metayml_has_license}),'no license in META.yml');
ok(!$d->{needs_compiler}, 'does not need compiler');

#use Data::Dumper;
#diag(Dumper $d);

