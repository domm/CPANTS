package Module::CPANTS::DB::Prereq;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));
__PACKAGE__->table('prereq');
__PACKAGE__->add_columns(qw(id dist requires version in_dist));
__PACKAGE__->belongs_to('dist'=>'Module::CPANTS::DB::Dist');
__PACKAGE__->belongs_to('in_dist'=>'Module::CPANTS::DB::Dist');

'Listening to: German Perl Workshop';
