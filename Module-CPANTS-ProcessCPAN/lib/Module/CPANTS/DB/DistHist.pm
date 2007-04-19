package Module::CPANTS::DB::DistHist;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto::Pg Core));
__PACKAGE__->table('dist_history');
__PACKAGE__->add_columns(qw(id run distname kwalitee version));

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('run'=>'Module::CPANTS::DB::Run');

#__PACKAGE__->has_many('kwalitee'=>'Module::CPANTS::DB::Kwalitee');
#__PACKAGE__->has_many('modules'=>'Module::CPANTS::DB::Modules');
#__PACKAGE__->has_many('prereq'=>'Module::CPANTS::DB::Prereq');
#__PACKAGE__->has_many('uses'=>'Module::CPANTS::DB::Uses');
#__PACKAGE__->has_many('requiring'=>'Module::CPANTS::DB::Prereq','in_dist');

'Listening to: Mediengruppe Telekommander - Naeher am Menschen';
