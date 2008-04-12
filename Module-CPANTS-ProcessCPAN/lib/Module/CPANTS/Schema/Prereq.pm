package Module::CPANTS::Schema::Prereq;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("prereq");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('prereq_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "requires",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "version",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "in_dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "is_prereq",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "is_build_prereq",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "is_optional_prereq",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-12 10:37:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PybtDaV7gYpamc7FubaCFA

__PACKAGE__->belongs_to("in_dist", "Module::CPANTS::Schema::Dist", { id => "in_dist" });
__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });


# You can replace this text with custom content, and it will be preserved on regeneration
1;
