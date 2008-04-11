package Module::CPANTS::Kwalitee::License;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Pod::Simple::TextContent;
use List::MoreUtils qw(all any);


sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;

    # check META.yml
    my $yaml=$me->d->{meta_yml};
    if ($yaml) {
        if ($yaml->{license} and $yaml->{license} ne 'unknown') {
            $me->d->{license} = $yaml->{license};
            return;
        }
    }
    my $files=$me->d->{files_array};

    # check if there's a LICEN[CS]E file
    if (my ($file) = grep {/^LICEN[CS]E$/} @$files) {
        $me->d->{license}="defined in ./LICEN[CS]E";
        $me->d->{external_license_file}=$file;
        #$me->d->{license_from_external_license_file} = Software::LicenseUtils->licens_text(slurp());
        return;
    }

    # check pod
    foreach my $file (grep { /\.p(m|od)$/ } @$files ) {
        my $parser=Pod::Simple::TextContent->new;
        my $out;
        $parser->output_string($out);
        $parser->parse_file( catfile($me->distdir,$file) );
        if ($out=~/LICEN[CS]E/) {
            $me->d->{license}="defined in POD ($file)";
            return;
        }
    }
    
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    my @fedora_licenses = qw(perl apache artistic_2 gpl lgpl mit mozilla);
    # based on: http://fedoraproject.org/wiki/Licensing
    my $fedora_licenses = "Acceptable licenses: (" . join(", ", @fedora_licenses) . ")";

    return [
         {
            name=>'has_humanreadable_license',
            error=>q{This distribution does not have a license defined in the documentation or in a file called LICENSE},
            remedy=>q{Add a section called 'LICENSE' to the documentation, or add a file named LICENSE to the distribution.},
            code=>sub { shift->{license} ? 1 : 0 }
        },
        {
            name=>'has_separate_license_file',
            error=>q{This distribution does not have a LICENSE or LICENCE file in its root directory.},
            remedy=>q{This is not a critical issue. Currently mainly informative for the CPANTS authors. It might be removed later.},
            is_extra=>1,
            is_experimental=>1,
            code=>sub { shift->{external_license_file} ? 1 : 0 }
        },
#        {
#            name=>'has_known_license_in_external_license_file',
#            error=>q{This distribution has a LICENSE or LICENCE file in its root directory but the license in it was not recognized by CPANTS.},
#            remedy=>q{Either CPANTS needs to be fixed or your LICENSE file.},
#            is_extra=>1,
#            is_experimental=>1,
#            code=>sub { 
#                my $d = shift;
#                return 1 if not $d->{external_license_file};
#                return $d->{license_from_external_license_file} ? 1 : 0;
#            },
#        },
        {
            name=>'has_license_in_source_file',
            error=>q{Does not have license information in any of its source files},
            remedy=>q{Add =head1 LICENSE and the text of the license to the main module in your code.},
            is_extra=>1,
            is_experimental=>1,
            code=>sub {
                my $d = shift;
                # data collected in File.pm
                return 0 if not $d->{licenses};
                return 1 if $d->{license_type};
                $d->{error}{has_license_in_source_file} = "Seemingly conflicting licenses in files: "
                    . join ", ", map {"$_ : $->{licenses}{$_}"} keys %{ $d->{licenses} };
                return 0;
            }
        },
        {
            name=>'fits_fedora_license',
            error=>qq{Fits the licensing requirements of Fedora ($fedora_licenses).},
            remedy=>q{Replace the license or convince Fedora to accept this license as well.},
            is_extra=>1,
            is_experimental=>1,
            code=>sub { 
                my $d=shift;
                my $license = $d->{meta_yml}{license};
                return ((defined $license and any {$license eq $_} @fedora_licenses) ? 1 : 0);

            }
        },
 
    ];
}


q{Favourite record of the moment:
  Lili Allen - Allright, still};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::License - Checks if there is a license

=head1 SYNOPSIS

Checks if the disttribution specifies a license.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::License> checks if there's a C<license> field C<META.yml>. Additionally, it looks for a file called LICENSE and a POD section namend LICENSE

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * has_license 

=item * has_license_in_metayml 


=back

=head2 License information

Pleaces wher the licens information is taken from:

Has a LICENSE file   file_license 1|0

Content of LICENSE file matches License X from Software::License

License in META.yml

License in META.yml matches one of the known licenses

License in source files recognized by Software::LicenseUtils
For each file keep where is was it recognized.

Has license or copyright entry in pod (that might not be recognized by Software::LicenseUtils)

# has_license

=cut


=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at
and Gabor Szabo, <gabor@pti.co.il>, http://www.szabgab.com

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
