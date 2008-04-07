package Module::CPANTS::Schema::Error;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("error");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('error_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "prereq_matches_use",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "build_prereq_matches_use",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "manifest_matches_dist",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "metayml_conforms_to_known_spec",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "cpants",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "no_pod_errors",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "metayml_is_parsable",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "no_generated_files",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "has_version_in_each_file",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "no_stdin_for_prompting",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "easily_repackageable_by_fedora",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "easily_repackageable_by_debian",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "easily_repackageable",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "metayml_conforms_spec_current",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "no_large_files",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-08 01:45:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EqmzdVsiyAT75lpjGJN68g

__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });


# You can replace this text with custom content, and it will be preserved on regeneration
1;
