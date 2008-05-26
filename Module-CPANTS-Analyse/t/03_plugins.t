use Test::More tests => 9;
use Test::Deep;
use Test::NoWarnings;

use Module::CPANTS::Analyse;

eval {
    my $an=Module::CPANTS::Analyse->new();
};
like($@, qr/need a dist/, 'exception');

my $a=Module::CPANTS::Analyse->new({dist => 'dummy'});

{
	my @plugins=$a->plugins;
	is(@plugins,15,'number of plugins');
}


my $plugins=$a->mck->generators;

is(shift(@$plugins),'Module::CPANTS::Kwalitee::Files','plugin order 1 Files');
is(shift(@$plugins),'Module::CPANTS::Kwalitee::Distname','plugin order 2 Distname');
is(shift(@$plugins),'Module::CPANTS::Kwalitee::MetaYML','plugin order 3 MetaYML');
is(shift(@$plugins),'Module::CPANTS::Kwalitee::FindModules','plugin order 4 FindModules');
is(pop(@$plugins),'Module::CPANTS::Kwalitee::CpantsErrors','plugin order last CpantsErrors');

cmp_deeply($plugins,bag(
        qw( Module::CPANTS::Kwalitee::Pod 
            Module::CPANTS::Kwalitee::Prereq 
            Module::CPANTS::Kwalitee::Uses 
            Module::CPANTS::Kwalitee::BrokenInstaller
            Module::CPANTS::Kwalitee::Manifest
            Module::CPANTS::Kwalitee::License
            Module::CPANTS::Kwalitee::NeedsCompiler
            Module::CPANTS::Kwalitee::Repackageable
            Module::CPANTS::Kwalitee::Version
            Module::CPANTS::Kwalitee::Distros
        )),'plugin the rest');


