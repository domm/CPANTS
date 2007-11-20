package Module::CPANTS::DB::Kwalitee;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('kwalitee');
__PACKAGE__->add_columns(qw(
id
dist
run
kwalitee abs_kw rel_core_kw abs_core_kw
extractable
extracts_nicely
 has_version
 has_proper_version
 no_cpants_errors
 has_readme
 has_manifest
 has_meta_yml
 has_buildtool
 has_changelog
 no_symlinks
 has_tests
 proper_libs
 is_prereq
 use_strict
 use_warnings
 has_test_pod
 has_test_pod_coverage
 no_pod_errors    
 has_working_buildtool
 manifest_matches_dist
 buildtool_not_executable
 has_example
 has_humanreadable_license
 metayml_is_parsable
 metayml_conforms_spec_current
 metayml_has_license
 metayml_conforms_to_known_spec
 has_license
 prereq_matches_use
 build_prereq_matches_use
 ));

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('dist'=>'Module::CPANTS::DB::Dist');

'Listening to: Attwenger - dog'
