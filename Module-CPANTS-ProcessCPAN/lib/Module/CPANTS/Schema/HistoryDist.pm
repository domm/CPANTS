package Module::CPANTS::Schema::HistoryDist;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("history_dist");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('public.history_dist_id_seq'::text)",
    is_nullable => 0,
    size => 4,
  },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "dist",
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
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });
__PACKAGE__->belongs_to("dist", "Module::CPANTS::Schema::Dist", { id => "dist" });


# Created by DBIx::Class::Schema::Loader v0.04002 @ 2007-12-29 23:19:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:faYHj3/YzPQlE1DKlfW5BA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
