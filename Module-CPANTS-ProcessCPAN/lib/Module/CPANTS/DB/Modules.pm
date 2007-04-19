package Module::CPANTS::DB::Modules;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto::Pg Core));
__PACKAGE__->table('modules');
__PACKAGE__->add_columns(qw(id dist module file in_lib in_basedir));
__PACKAGE__->belongs_to('dist'=>'Module::CPANTS::DB::Dist');

'Listening to: German Perl Workshop';
