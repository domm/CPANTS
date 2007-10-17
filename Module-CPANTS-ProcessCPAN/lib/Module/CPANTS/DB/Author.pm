package Module::CPANTS::DB::Author;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('author');
__PACKAGE__->add_columns(qw(id pauseid name email average_kwalitee num_dists rank prev_av_kw prev_rank));

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('dists'=>'Module::CPANTS::DB::Dist');



'Listening to: German Perl Workshop';
