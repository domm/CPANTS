use Test::More tests => 13;

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
ok($d->{metayml_is_parsable},'metayml_is_parsable');
is($d->{license},'perl','LICENSE');
ok(!$d->{needs_compiler}, 'does not need compiler');


