package Module::CPANTS::DB::Uses;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('uses');
__PACKAGE__->add_columns(qw(id dist module in_dist in_code in_tests));

__PACKAGE__->belongs_to('dist'=>'Module::CPANTS::DB::Dist');
__PACKAGE__->belongs_to('in_dist'=>'Module::CPANTS::DB::Dist');



'Listening to: German Perl Workshop';
