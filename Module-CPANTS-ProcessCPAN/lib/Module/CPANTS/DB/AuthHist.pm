package Module::CPANTS::DB::AuthHist;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto::Pg Core));
__PACKAGE__->table('author_history');
__PACKAGE__->add_columns(qw(id run author average_kwalitee num_dists rank));
__PACKAGE__->set_primary_key('id');
#__PACKAGE__->has_many('dists'=>'Module::CPANTS::DB::Dist');

__PACKAGE__->belongs_to('run'=>'Module::CPANTS::DB::Run');


'Listening to: Mediengruppe Telekommander - Naeher am Menschen';
