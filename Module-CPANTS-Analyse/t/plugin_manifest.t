use Test::More 'no_plan';

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
    is( $a->d->{manifest_matches_dist}, undef, 'manifest does not match dist' );
    is( $a->d->{error_manifest_matches_dist}, 'Cannot find MANIFEST in dist.','proper error message' );

}

# a third with "bad-manifest-0.01"
{
    my $a=Module::CPANTS::Analyse->new({ dist => 't/eg/manifest/bad-manifest-0.01.tar.gz' });
    $a->unpack;
    $a->analyse;
    is( $a->d->{manifest_matches_dist}, 0, 'manifest does not match dist' );
    is( $a->d->{error_manifest_matches_dist},
        "MANIFEST (11) does not match dist (11):\n" .
        "Missing in MANIFEST: TODO\n" .
        "Missing in Dist: eg/demo2.pl", 'proper error message' );
}

