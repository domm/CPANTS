package Module::CPANTS::Schema::Error;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("error");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('public.error_id_seq'::text)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "prereq",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "build_prereq",
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
  "metayml",
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
  "pod",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "pod_message",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "metayml_parse",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2008-01-09 22:59:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u6pNt4rPnWGBLcGrXW452Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
