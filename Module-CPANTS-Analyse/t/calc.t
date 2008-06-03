use Test::More tests => 18;

use Module::CPANTS::Analyse;
use File::Spec::Functions;
use Test::Deep;

my $a=Module::CPANTS::Analyse->new({
    dist=>'t/eg/Acme-DonMartin-0.06.tar.gz',
    _dont_cleanup=>$ENV{DONT_CLEANUP},
});

my $rv=$a->unpack;
is($rv,undef,'unpack ok');

$a->analyse;

my $d=$a->d;

is($d->{files},9,'files');
is($d->{size_packed},7736,'size_packed');
is(ref($d->{modules}),'ARRAY','modules is ARRAY');
is($d->{modules}[0]->{module},'Acme::DonMartin','module');
is(ref($d->{prereq}),'ARRAY','prereq is ARRAY');
is($d->{prereq}[0]->{requires},'Compress::Zlib','prereq');
is(ref($d->{uses}),'HASH','uses is HASH');
is($d->{uses}{'Compress::Zlib'}{module},'Compress::Zlib','uses Compress::Zlib in module');
is($d->{uses}{'Test::More'}{in_tests},1,'uses Test::More in tests');
ok($d->{file_meta_yml},'has_yaml');
ok($d->{metayml_is_parsable},'metayml_is_parsable');
ok(!$d->{metayml_parse_error},'metayml_parse_error was not set');
ok(!$d->{license},'no license in META.yml');


$a->calc_kwalitee;

my $kw=$a->d->{kwalitee};
my $expected_kwalitee =  {
           'extracts_nicely' => 1,
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'has_example' => 1,
           'has_test_pod_coverage' => 1,
           'metayml_is_parsable' => 1,
           'easily_repackageable' => 0,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'no_pod_errors' => 1,
           'use_strict' => 1,
           'kwalitee' => 28,
           'has_test_pod' => 1,
           'has_tests' => 1,
           'easily_repackageable_by_debian' => 1,
           'fits_fedora_license' => 0,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'has_version' => 1,
           'extractable' => 1,
           'buildtool_not_executable' => 1,
           'has_working_buildtool' => 1,
           'metayml_has_license' => 0,
           'has_humanreadable_license' => 0,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'easily_repackageable_by_fedora' => 0,
           'metayml_conforms_spec_current' => 0,
           'use_warnings' => 0,
           'no_cpants_errors' => 1,
           'has_version_in_each_file' => 1,
           'has_tests_in_t_dir' => 1,
           'has_proper_version' => 1,
           'metayml_conforms_to_known_spec' => 0,
           'no_stdin_for_prompting' => 1,
           'metayml_declares_perl_version' => 0,
           'no_large_files' => 1,
           'has_separate_license_file' => 0,
           'has_license_in_source_file' => 0,
           'metayml_has_provides'=>0,
           'distributed_by_debian'=>0,
           'latest_version_distributed_by_debian'=>0,
           'has_no_bugs_reported_in_debian'=>0,
           'has_no_patches_in_debian'=>0,
           'uses_test_nowarnings'=>0,
         };

is_deeply($kw, $expected_kwalitee, 'metrics are as expected');

is $a->d->{size_packed}, 7736, 'size_packed';
is $a->d->{size_unpacked}, 14805, 'size_unpacked';
cmp_bag $a->d->{files_array}, [
          'MANIFEST',
          'META.yml',
          'DonMartin.pm',
          'Changes',
          'README',
          'Makefile.PL',
          't/01-basic.t',
          'eg/freq.pl',
          'eg/hello.pl'
        ], 'files_array';


#use Data::Dumper;
#diag(Dumper $kw);
#diag(Dumper $a);

