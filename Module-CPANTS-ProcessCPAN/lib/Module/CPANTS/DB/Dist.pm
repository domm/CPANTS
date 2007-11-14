package Module::CPANTS::DB::Dist;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('dist');
__PACKAGE__->add_columns(qw(
id run
bad_permissions bad_permissions_list cpants_errors dir_lib dir_t dir_xt dirs dirs_list dist vname extension extractable extracts_nicely file_build_pl file_changelog file_makefile_pl file_manifest file_meta_yml file_ninja file_readme file_signature file_test_pl file_license files files_list package author pod_errors released size_packed size_unpacked symlinks symlinks_list version version_major version_minor broken_module_install manifest_matches_dist buildfile_executable pod_errors_msg license metayml_parse_error metayml_is_parsable metayml_error error_manifest_matches_dist needs_compiler got_prereq_from
));

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_one('kwalitee'=>'Module::CPANTS::DB::Kwalitee','dist');
__PACKAGE__->has_many('modules'=>'Module::CPANTS::DB::Modules');
__PACKAGE__->has_many('prereq'=>'Module::CPANTS::DB::Prereq');
__PACKAGE__->has_many('uses'=>'Module::CPANTS::DB::Uses');
__PACKAGE__->has_many('requiring'=>'Module::CPANTS::DB::Prereq','in_dist');
__PACKAGE__->belongs_to('run'=>'Module::CPANTS::DB::Run');
__PACKAGE__->belongs_to('author'=>'Module::CPANTS::DB::Author');
__PACKAGE__->add_unique_constraint(
    dist => [ qw{dist} ]
);

sub uses_in_code {
    return shift->search_related('uses',{in_code=>{'>=',1}},{order_by=>'module'});
}
sub uses_in_tests {
    return shift->search_related('uses',{in_tests=>{'>=',1}},{order_by=>'module'});
}


'Listening to: Attwenger - dog'
