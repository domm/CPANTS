package Module::CPANTS::Schema::Dist;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("dist");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('dist_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "dist",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "package",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "vname",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "author",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "version",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version_major",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version_minor",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "extension",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "extractable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "extracts_nicely",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "size_packed",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "size_unpacked",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "released",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "files",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "files_list",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "dirs",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "dirs_list",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "symlinks",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "symlinks_list",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "bad_permissions",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "bad_permissions_list",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "file_makefile_pl",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_build_pl",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_readme",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "file_manifest",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_meta_yml",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_signature",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_ninja",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_test_pl",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_changelog",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "file__build",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_build",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_makefile",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_blib",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_pm_to_blib",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "dir_lib",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "dir_t",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "dir_xt",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "broken_module_install",
  { data_type => "text", default_value => 0, is_nullable => 0, size => undef },
  "manifest_matches_dist",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "buildfile_executable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "license",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "metayml_is_parsable",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "file_license",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "needs_compiler",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "got_prereq_from",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "stdin_in_makefile_pl",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "stdin_in_build_pl",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "is_core",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-07 18:47:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YzDpV9Dau/UQkEQlWY+s+Q

__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });
__PACKAGE__->belongs_to("author", "Module::CPANTS::Schema::Author", { id => "author" });
__PACKAGE__->has_one(
  "error",
  "Module::CPANTS::Schema::Error",
  #{ "foreign.dist" => "self.id" },
);
__PACKAGE__->has_many(
  "history_dist",
  "Module::CPANTS::Schema::HistoryDist",
  { "foreign.dist" => "self.id" },
);
__PACKAGE__->has_one(
  "kwalitee",
  "Module::CPANTS::Schema::Kwalitee",
  { "foreign.dist" => "self.id" },
);
__PACKAGE__->has_many(
  "modules",
  "Module::CPANTS::Schema::Modules",
  { "foreign.dist" => "self.id" },
);
__PACKAGE__->has_many(
  "requiring",
  "Module::CPANTS::Schema::Prereq",
  { "foreign.in_dist" => "self.id" },
);
__PACKAGE__->has_many(
  "prereq",
  "Module::CPANTS::Schema::Prereq",
  { "foreign.dist" => "self.id" },
);
__PACKAGE__->has_many(
  "uses",
  "Module::CPANTS::Schema::Uses",
  { "foreign.dist" => "self.id" },
);
__PACKAGE__->has_many(
  "uses_in_dist",
  "Module::CPANTS::Schema::Uses",
  { "foreign.in_dist" => "self.id" },
);


sub uses_in_code {
    return shift->search_related('uses',{in_code=>{'>=',1}},{order_by=>'module'});
}
sub uses_in_tests {
    return shift->search_related('uses',{in_tests=>{'>=',1}},{order_by=>'module'});
}





# You can replace this text with custom content, and it will be preserved on regeneration
1;
