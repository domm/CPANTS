package Module::CPANTS::Kwalitee::MetaYML;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use YAML::Syck qw(LoadFile);
use Test::YAML::Meta::Version;

sub order { 20 }

my $CURRENT_SPEC = '1.3';

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;

    my $files=$me->d->{files_array};
    my $distdir=$me->distdir;
    if (grep {/^META\.yml$/} @$files) {
        eval {
            $me->d->{meta_yml}=LoadFile(catfile($distdir,'META.yml'));
            $me->d->{metayml_is_parsable}=1;
        };
        if ($@) {
            $me->d->{metayml_parse_error}=$@;
        }
    }    
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
        {
            name=>'metayml_is_parsable',
            error=>q{The META.yml file of this distributioncould not be parsed by the version of YAML.pm CPANTS is using. See 'metayml_parse_error' in the dist view for more info.},
            remedy=>q{Upgrade your YAML.pm or convince the maintainer of CPANTS that he has to upgrade.},
            code=>sub { shift->{metayml_is_parsable} ? 1 : 0 }
        },
        {
            name=>'metayml_has_license',
            error=>q{This distribution does not have a license defined in META.yml.},
            remedy=>q{Define the license if you are using in Build.PL. If you are using MakeMaker (Makefile.PL) you should upgrade to ExtUtils::MakeMaker version 6.31.},
            code=>sub { 
                my $d=shift;
                my $yaml=$d->{meta_yml};
                ($yaml->{license} and $yaml->{license} ne 'unknown') ? 1 : 0 }
        },
#        {
#            name=>'metayml_conforms_spec_1_0',
#            error=>q{META.yml does not conform to the META.yml Spec 1.0. See 
#            'metayml_error' in the dist view for more info.},
#            remedy=>q{Take a look at the META.yml Spec at 
#            http://module-build.sourceforge.net/META-spec-current.html and 
#            change your META.yml accordingly},
#            code=>sub {
#                my $d=shift;
#                return check_spec_conformance($d,'1.0');
#            },
#        },
        {
            name=>'metayml_conforms_to_known_spec',
            error=>q{META.yml does not conform to any recognised META.yml Spec. See 'metayml_error' in the dist view for more info.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d);
            },
        },
    {
            name=>'metayml_conforms_spec_current',
            is_extra=>1,
            error=>qq{META.yml does not conform to the Current META.yml Spec ($CURRENT_SPEC). See 'metayml_error' in the dist view for more info.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d,$CURRENT_SPEC,1);
            },
        },
    ];
}

sub check_spec_conformance {
    my ($d,$version,$check_current)=@_;
    my $yaml=$d->{meta_yml};
    my %hash=(
        yaml=>$yaml,
    );

    if (!$version) {
        if (my $from_yaml=$yaml->{'meta-spec'}{version}) {
            $version = $from_yaml;
        }
        else {
            $version='1.0';
        }
    }
    $hash{spec} = $version;

    my $spec = Test::YAML::Meta::Version->new(%hash);
    if ($spec->parse()) {
        my $report_version= $version || 'known';
        my @errors;
        foreach my $e ($spec->errors) {
            next if $e=~/distribution_type/;
            next if $e=~/specification URL/ && $check_current;
            push @errors,$e;
        }
        if (@errors) {
            $d->{metayml_error}.=$report_version.": ".join(" ",@errors)." ";
            return 0;
        }
    }
    return 1;
}

q{Barbies Favourite record of the moment:
  Nine Inch Nails: Year Zero};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::MetaYML - Checks data availabe in META.yml

=head1 SYNOPSIS

Checks various pieces of information in META.yml

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<11>.

=head3 analyse

C<MCK::MetaYML> checks C<META.yml>.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * metayml_is_parsable

=item * metayml_has_license

=item * metayml_conforms_spec_1_0

=item * metayml_conforms_known_spec
=
item * metayml_conforms_spec_current

=back

=head3 check_spec_conformance

    check_spec_conformance($d,$version);

Validates META.yml using Test::YAML::Meta.

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at
and Gabor Szabo, <gabor@pti.co.il>, http://www.szabgab.com

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
