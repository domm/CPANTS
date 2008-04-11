use Test::More tests => 4;

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
my $expected_kwalitee = {
           'extracts_nicely' => 1,
           'has_buildtool' => 1,
           'has_readme' => 1,
           'manifest_matches_dist' => 1,
           'has_example' => 1,
           'has_test_pod_coverage' => 1,
           'metayml_is_parsable' => 1,
           'easily_repackageable' => 1,
           'proper_libs' => 1,
           'has_changelog' => 1,
           'no_pod_errors' => 1,
           'use_strict' => 1,
           'kwalitee' => 38,
           'has_test_pod' => 1,
           'has_tests' => 1,
           'easily_repackageable_by_debian' => 1,
           'fits_fedora_license' => 1,
           'has_manifest' => 1,
           'no_symlinks' => 1,
           'has_version' => 1,
           'extractable' => 1,
           'buildtool_not_executable' => 1,
           'has_working_buildtool' => 1,
           'metayml_has_license' => 1,
           'has_humanreadable_license' => 1,
           'no_generated_files' => 1,
           'has_meta_yml' => 1,
           'easily_repackageable_by_fedora' => 1,
           'metayml_conforms_spec_current' => 1,
           'use_warnings' => 1,
           'no_cpants_errors' => 1,
           'has_version_in_each_file' => 1,
           'has_tests_in_t_dir' => 1,
           'has_proper_version' => 1,
           'metayml_conforms_to_known_spec' => 1,
           'no_stdin_for_prompting' => 1,
           'metayml_declares_perl_version' => 0,
           'no_large_files' => 1,
           'has_license_in_source_file' => 1,
           'metayml_has_provides'=>1,
           'has_separate_license_file', => 0,
         };

is_deeply($kw, $expected_kwalitee, 'metrics are as expected');

#use Data::Dumper;
#diag(Dumper $kw);
#diag(Dumper $a->d);
