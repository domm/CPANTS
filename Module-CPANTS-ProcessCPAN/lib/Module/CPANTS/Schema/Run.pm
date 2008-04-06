package Module::CPANTS::Schema::Run;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("run");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('run_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "mcanalyse_version",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "mcprocess_version",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "available_kwalitee",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "total_kwalitee",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "date",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-06 18:00:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yGef191jOHdG1MtzuKNt5g

__PACKAGE__->has_many(
  "dists",
  "Module::CPANTS::Schema::Dist",
  { "foreign.run" => "self.id" },
);
__PACKAGE__->has_many(
  "history_authors",
  "Module::CPANTS::Schema::HistoryAuthor",
  { "foreign.run" => "self.id" },
);
__PACKAGE__->has_many(
  "history_dists",
  "Module::CPANTS::Schema::HistoryDist",
  { "foreign.run" => "self.id" },
);
__PACKAGE__->has_many(
  "kwalitees",
  "Module::CPANTS::Schema::Kwalitee",
  { "foreign.run" => "self.id" },
);



# You can replace this text with custom content, and it will be preserved on regeneration
1;
