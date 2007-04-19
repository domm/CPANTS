package Module::CPANTS::DB::Run;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto::Pg Core));
__PACKAGE__->table('run');
__PACKAGE__->add_columns(qw(id version available_kwalitee date));
__PACKAGE__->set_primary_key('id');


'Listening to: Slaven Rezic - Perl und Unicode (German Perl Workshop';
