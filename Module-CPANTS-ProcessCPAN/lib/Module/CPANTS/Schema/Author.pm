package Module::CPANTS::Schema::Author;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("author");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('author_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "pauseid",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "email",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "average_kwalitee",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "3,6",
  },
  "num_dists",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "rank",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "prev_av_kw",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "3,6",
  },
  "prev_rank",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-12 11:22:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xBa2GiNvrJSbZi7K/hFcCw

__PACKAGE__->has_many(
  "dists",
  "Module::CPANTS::Schema::Dist",
  { "foreign.author" => "self.id" },
);
__PACKAGE__->has_many(
  "history_authors",
  "Module::CPANTS::Schema::HistoryAuthor",
  { "foreign.author" => "self.id" },
);


# You can replace this text with custom content, and it will be preserved on regeneration
1;
