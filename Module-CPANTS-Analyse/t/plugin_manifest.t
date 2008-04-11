use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper qw(Dumper);

# for testing the Manifest plugin

use Module::CPANTS::Analyse;

use File::Path qw(rmtree);

{
    my $a=Module::CPANTS::Analyse->new({ dist => 't/eg/manifest/Good-Dist-0.01.tar.gz' });
    $a->unpack;
    $a->analyse;
    is($a->d->{manifest_matches_dist}, 1, 'manifest matches dist');
}

{
    my $a=Module::CPANTS::Analyse->new({ dist => 't/eg/manifest/no-manifest-0.01.tar.gz' });
    $a->unpack;
    $a->analyse;
    is( $a->d->{manifest_matches_dist}, 0, 'manifest does not match dist' );
    is( $a->d->{error}{manifest_matches_dist}, 'Cannot find MANIFEST in dist.','proper error message' )
        or diag Dumper $a->d->{error};

}

# a third with "bad-manifest-0.01"
{
    my $a=Module::CPANTS::Analyse->new({ dist => 't/eg/manifest/bad-manifest-0.01.tar.gz' });
    $a->unpack;
    $a->analyse;
    is( $a->d->{manifest_matches_dist}, 0, 'manifest does not match dist' );
    is_deeply( $a->d->{error}{manifest_matches_dist}, [
        "MANIFEST (11) does not match dist (11):",
        "Missing in MANIFEST: TODO",
        "Missing in Dist: eg/demo2.pl"], 'proper error message');
}

