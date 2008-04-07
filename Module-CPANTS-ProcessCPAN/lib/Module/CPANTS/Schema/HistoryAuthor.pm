package Module::CPANTS::Schema::HistoryAuthor;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn", "PK", "Core");
__PACKAGE__->table("history_author");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('history_author_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "run",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "author",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "average_kwalitee",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "num_dists",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rank",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04004 @ 2008-04-07 17:51:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LAia/aNS1bSeJuPHr1Ts4Q

__PACKAGE__->belongs_to("run", "Module::CPANTS::Schema::Run", { id => "run" });



# You can replace this text with custom content, and it will be preserved on regeneration
1;
