package Module::CPANTS::DBHistory::Dist;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('dist');
__PACKAGE__->add_columns(qw(id run distname kwalitee version));

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('run'=>'Module::CPANTS::DBHistory::Run');
#__PACKAGE__->belongs_to('author'=>'Module::CPANTS::DBHistory::Author');


'Listening to: Mediengruppe Telekommander - Naeher am Menschen';
