package Module::CPANTS::Schema::Uses;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "InflateColumn", "PK", "Core");
__PACKAGE__->table("uses");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('uses_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "module",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "in_dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "in_code",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "in_tests",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-14 08:44:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j+FxT8r6206cdQ3a7lXsbQ

__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });
__PACKAGE__->belongs_to("in_dist", "Module::CPANTS::Schema::Dist", { id => "in_dist" });


# You can replace this text with custom content, and it will be 
# preserved on regeneration
1;
