package Module::CPANTS::DBHistory::Run;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('run');
__PACKAGE__->add_columns(qw(id mcanalyse_version mcprocess_version available_kwalitee total_kwalitee date));
__PACKAGE__->set_primary_key('id');


'Listening to: Barbara Hollendonner - BETATEST of: Gender und C.S.I. (http://www.dieangewandte.at/stories/storyReader$1066)';

