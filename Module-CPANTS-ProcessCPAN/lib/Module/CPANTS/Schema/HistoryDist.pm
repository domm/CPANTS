package Module::CPANTS::Schema::HistoryDist;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "InflateColumn", "PK", "Core");
__PACKAGE__->table("history_dist");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('history_dist_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "distname",
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
  "kwalitee",
  { data_type => "numeric", default_value => 0, is_nullable => 0, size => "3,6" },
  "dist",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-06-03 22:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NGc7CJbDtETiz4JKL1EZYQ

__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });


# You can replace this text with custom content, and it will be preserved on regeneration
1;
