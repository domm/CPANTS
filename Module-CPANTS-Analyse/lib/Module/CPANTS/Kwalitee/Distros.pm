package Module::CPANTS::Kwalitee::Distros;
use warnings;
use strict;
#use File::Spec::Functions qw(catfile);
#use List::MoreUtils qw(all any);
use LWP::Simple qw(mirror);
use Data::Dumper qw(Dumper);
use Text::CSV_XS 0.45;

sub order { 800 }

##################################################################
# Analyse
##################################################################
my $debian;

sub analyse {
    my $class=shift;
    my $me=shift;

    if (not $debian) {
        $debian = get_debian_data();
    }
   
    return;
}

sub get_debian_data {
    my $local_file = 'Debian_CPANTS.txt';
    mirror('http://pkg-perl.alioth.debian.org/CPANTS.txt', $local_file);

    my %debian;

    return {} if not open my $fh ,'<', $local_file;
    # TODO other error reporting in this case?

    my $csv = Text::CSV_XS->new({ allow_whitespace => 1 });
    # header looks like the following though we don't rely on this order
    # TODO: maybe we should check if the file really contains the expected columns and if
    # all the rows are well formatted so we have some alert if the Debian people 
    # break this format.
    # We should also alert if the file is not new enough...

    # debian_pkg, CPAN_dist, CPAN_vers, N_bugs, N_patches
    my $header = <$fh>;
    chomp $header;
    $csv->parse($header) or die "Could not parse header:\n$header\n";

    my @header = $csv->fields;
    #die Dumper \@header;
    while (my $row = <$fh>) {
        chomp $row;
        if ($csv->parse($row)) {
            my @values = $csv->fields;
            my %h;
            #die Dumper \@values;
            @h{@header} = @values;
            #(my $dist = $h{CPAN_dist}) =~ s/-/::/g;
            #$debian{$dist} = \%h;
            $debian{ $h{CPAN_dist} } = \%h;
        #} else {
        #    warn "Invalid row in Debian file:\n$row\n";
        }
    }
    return \%debian;
}



##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
         {
            name=>'distributed_by_debian',
            error=>qq{The module is not distributed by Debian},
            remedy=>q{Make your package easily repackagable by Debian and convince the Debian-Perl team to package your module},
            is_experimental=>1,
            code=> sub {
                    my $d = shift;
                    my $metric=shift;
                    return $debian->{ $d->{dist} } ? 1 : 0;
                },
         },
         {
            name=>'latest_version_distributed_by_debian',
            error=>qq{The version distributed by Debian is NOT the latest from CPAN},
            remedy=>q{Give the Debian-Perl people some time to repackage your module. After that talk to the to see if
there is a problem with the latest version?},
            is_experimental=>1,
            code=> sub {
                    my $d = shift;
                    my $metric=shift;
                    my $deb = $debian->{ $d->{dist} };
                    return 1 if $deb && $deb->{CPAN_vers} eq $d->{version};
                    if ($deb) {
                        my $error = "Seen on CPAN: '$d->{version}'. Reported by Debian: '$deb->{CPAN_vers}'";
                        $error .= " See: <a href=http://packages.debian.org/src:$deb->{debian_pkg}>Basic homepage</a>";
                        $d->{error}{ $metric->{name} } = $error;
                    } else {
                        #$d->{error}{ $metric->{name} } = 'First get your module in Debian';
                    }
                    return 0;
                },
         },
         {
            name=>'has_no_bugs_reported_in_debian',
            error=>qq{There is a bug reported in Debian},
            remedy=>q{Give the Debian-Perl people some time to repackage your module. After that talk to the to see if
there is a problem with the latest version?},
            is_experimental=>1,
            code=> sub {
                    my $d = shift;
                    my $metric=shift;
                    my $deb = $debian->{ $d->{dist} };
                    return 1 if $deb && !$deb->{N_bugs};
                    if ($deb) {
                        my $error = "Number of bugs reported: $deb->{N_bugs}.";
                        $error .= " See: <a href=http://packages.debian.org/src:$deb->{debian_pkg}>Basic homepage</a>";
                        $d->{error}{ $metric->{name} } = $error;
                    } else {
                        #$d->{error}{ $metric->{name} } = 'First get your module in Debian';
                    }
                    return 0;
                },
         },
         {
            name=>'has_no_patches_in_debian',
            error=>qq{There is a patch in Debian},
            remedy=>q{Go to the Debian repository apply their patch to the version maintained on CPAN and ask the Debian
team to upgrde.},
            is_experimental=>1,
            code=> sub {
                    my $d = shift;
                    my $metric=shift;
                    my $deb = $debian->{ $d->{dist} };
                    return 1 if $deb && !$deb->{N_patches};
                    if ($deb) {
                        my $error = "Number of patches reported: $deb->{N_patches}.";
                        $error .= " See: <a href=http://packages.debian.org/src:$deb->{debian_pkg}>Basic homepage</a>";
                        $d->{error}{ $metric->{name} } = $error;
                    } else {
                        #$d->{error}{ $metric->{name} } = 'First get your module in Debian';
                    }
                    return 0;
                },
         },
    ];
}

q{Favourite record of the moment:
  Lili Allen - Allright, still};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Distros - Information retrieved from the various Linux and other distributions

=head1 SYNOPSIS

The metrics here are based on data provided by the various downstream packaging systems.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

=head3 analyse

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * distributed_by_debian

True if the module (package) is repackaged by the Debian-Perl team and 
you can install it using the package management system of Debian.

=item * latest_version_distributed_by_debian

True if the latest version of the module (package) is repackaged by Debian

=item * has_no_bugs_reported_in_debian

True for if the module is distributed by Debian and no bugs were reported.

=item * has_no_patches_in_debian

True for if the module is distributed by Debian and no patches applied.

=back

=head1 Caveats

CPAN_dist, the name of CPAN distribution is inferred from the download location,
for Debian packages. It works 99% of the time, but it is not completely reliable.
If it fails to detect something, it will spit out the known download location.

CPAN_vers, the version number reported by Debian is inferred from the debian version.
This fails a lot, since Debian has a mechanism for "unmangling" upstream versions which
is non-reversible. We have to use that many times to fix versioning problems, 
and those packages will show a different version (e.g. 1.080 vs 1.80)

The first problem is something the Debian people like to solve by adding 
metadata to the packages, for many other useful stuff 
(like automatic upstream bug tracking and handling). About the second... well, 
it's a difficult one.

CPANTS does not yet handle the second issue.

=head1 LINKS

Basic homepage: http://packages.debian.org/src:$pkgname

Detalied homepage: http://packages.qa.debian.org/$pkgname

Bugs report: http://bugs.debian.org/src:$pkgname

Public SVN repository: http://svn.debian.org/wsvn/pkg-perl/trunk/$pkg

From that last URL, you might be interested in the debian/ and
debian/patches subdirectories.

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at
and Gabor Szabo, <gabor@pti.co.il>, http://www.szabgab.com
with the help of Martín Ferrari and the Debian Perl packaging team.

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
