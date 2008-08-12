use Test::More;
use Test::Deep;
use Test::NoWarnings;

use Module::CPANTS::Kwalitee;

my $CORE = 23;
my $OPTIONAL = 9;
my $EXTRA = 16;
my $METRICS = $CORE + $OPTIONAL + $EXTRA;

plan tests => 8 + 2 * $METRICS;

my $k=Module::CPANTS::Kwalitee->new({});

is($k->available_kwalitee, $CORE, 'available kwalitee');
is($k->total_kwalitee, $CORE + $OPTIONAL, 'total kwalitee');


my $ind=$k->get_indicators_hash;
is(ref($ind),'HASH','indicator_hash');
is(ref($ind->{use_strict}),'HASH','hash element');

{
    my @all=$k->all_indicator_names;
    is(@all, $METRICS, 'number of all indicators');
}

{
    my @all=$k->core_indicator_names;
    is(@all, $CORE, 'number of core indicators');
}

{
    my @all=$k->optional_indicator_names;
    is(@all, $OPTIONAL,'number of optional indicators');
}


foreach my $mod (@{$k->generators}) {
    #$mod->analyse($me);
    foreach my $i (@{$mod->kwalitee_indicators}) {
        like $i->{name}, qr/^\w{3,}$/, $i->{name};
        # to check if someone has put a $var in single quotes by mistake...
        unlike $i->{error}, qr/\$[a-z]/, "error of $i->{name} has no \$ sign";
        # next if $i->{needs_db};
        # print $i->{name}."\n" if $me->opts->{verbose};
        # my $rv=$i->{code}($me->d, $i);
        # $me->d->{kwalitee}{$i->{name}}=$rv;
        # $kwalitee+=$rv;
    }
}

=cut

