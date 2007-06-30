use Test::More tests => 6;

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
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');


