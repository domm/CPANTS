use Test::More tests => 12;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Eg-C-0.01.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

is($d->{files}, 8,'files');
is($d->{size_packed},2223,'size_packed');
is(ref($d->{modules}),'ARRAY','modules is ARRAY');
is($d->{modules}[0]->{module},'Eg::C','module');
is(ref($d->{prereq}),'ARRAY','prereq is ARRAY');
is(ref($d->{uses}),'HASH','uses is HASH');
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');
is($d->{license}, '', 'has no license');
ok($d->{needs_compiler}, 'need compiler');

