package Module::CPANTS::Kwalitee::Manifest;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Array::Diff;

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my @files=@{$me->d->{files_array}};
    if (my $ignore = $me->d->{ignored_files_array}) {
        push @files, @$ignore;
    }
    my $distdir=$me->distdir;
    my $manifest_file=catfile($distdir,'MANIFEST');

    if (-e $manifest_file) {
        # read manifest
        open(my $fh, '<', $manifest_file) || die "cannot read MANIFEST $manifest_file: $!";
        my @manifest;
        while (<$fh>) {
            chomp;
            next if /^\s*#/; # discard pure comments

            s/\s.*$//; # strip file comments
            next unless $_; # discard blank lines
            push(@manifest,$_);
        }
        close $fh;

        @manifest=sort @manifest;
        my @files=sort @files;

        my $diff=Array::Diff->diff(\@manifest,\@files);
        if ($diff->count == 0) {
            $me->d->{manifest_matches_dist}=1;
        }
        else {
            $me->d->{manifest_matches_dist}=0;
            my @error = ( 
                'MANIFEST ('.@manifest.') does not match dist ('.@files."):",
                "Missing in MANIFEST: ".join(', ',@{$diff->added}), 
                "Missing in Dist: " . join(', ',@{$diff->deleted}));
            $me->d->{error}{manifest_matches_dist} = \@error;
        }
    }
    else {
        $me->d->{manifest_matches_dist}=0;
        $me->d->{error}{manifest_matches_dist}=q{Cannot find MANIFEST in dist.};
    }
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'manifest_matches_dist',
            error=>q{MANIFEST does not match the contents of this distribution. See 'error_manifest_matches_dist' in the dist view for more info.},
            remedy=>q{Use a buildtool to generate the MANIFEST. Or update MANIFEST manually.},
            code=>sub { shift->{manifest_matches_dist} ? 1 : 0 },
        }
    ];
}


q{Listening to: YAPC::Europe 2007};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Manifest - Check MANIFEST

=head1 SYNOPSIS

Check if MANIFEST and dist contents match.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

Check if MANIFEST and dist contents match.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * manifest_matches_dist

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.plix.at

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2006, 2009  Thomas Klausner

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
