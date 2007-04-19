use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Module::CPANTS::Site' }
BEGIN { use_ok 'Module::CPANTS::Site::Controller::Kwalitee' }

ok( request('/kwalitee')->is_success, 'Request should succeed' );


