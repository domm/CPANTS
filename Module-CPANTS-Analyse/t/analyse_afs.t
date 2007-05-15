use Test::More tests => 12;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/AFS-2.4.0.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

# some operating systems (win32) only report 383 files (maybe a problem with 
# case-insensitive filenames)
ok($d->{files} == 384 || $d->{files} == 383,'files');

is($d->{size_packed},184395,'size_packed');
is(ref($d->{modules}),'ARRAY','modules is ARRAY');
is($d->{modules}[0]->{module},'AFS','module');
is(ref($d->{prereq}),'ARRAY','prereq is ARRAY');
is(ref($d->{uses}),'HASH','uses is HASH');
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');
is($d->{license},'perl','has license');
ok($d->{needs_compiler}, 'needs compiler');

