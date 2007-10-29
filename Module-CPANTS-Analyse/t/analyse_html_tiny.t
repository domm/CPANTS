use Test::More tests => 10;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/HTML-Tiny-0.904.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

is($d->{files},18,'files');
my $modcount=grep {$_->{module} eq 'HTML::Tiny'} @{$d->{modules}};
is($modcount,1,'module');
is($d->{prereq}->[0]{requires},'Test::More','prereq');
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');
is($d->{license},'perl','license');
ok(!$d->{needs_compiler}, 'does not need compiler');
ok($d->{dir_xt},'dir_xt');

