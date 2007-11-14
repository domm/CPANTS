use Test::More tests => 7;
use Test::Deep;

use Module::CPANTS::Kwalitee;

my $k=Module::CPANTS::Kwalitee->new({});

is($k->available_kwalitee,26,'available kwalitee');
is($k->total_kwalitee,30,'total kwalitee');


my $ind=$k->get_indicators_hash;
is(ref($ind),'HASH','indicator_hash');
is(ref($ind->{use_strict}),'HASH','hash element');

{
    my @all=$k->all_indicator_names;
    is(@all,30,'number of indicators');
}

{
    my @all=$k->core_indicator_names;
    is(@all,26,'number of indicators');
}

{
    my @all=$k->optional_indicator_names;
    is(@all,4,'number of indicators');
}

