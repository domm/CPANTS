package Module::CPANTS::Kwalitee::MetaYML;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use YAML qw(LoadFile);

sub order { 20 }

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
        {
            name=>'metayml_conforms_spec_1_0',
            error=>q{META.yml does not conform to the META.yml Spec 1.0. See 'metayml_error' in the dist view for more info.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d,'1.0',[qw(name version license generated_by)]);
            },
        },
        {
            name=>'metayml_conforms_spec_current',
            is_extra=>1,
            error=>q{META.yml does not conform to the Current META.yml Spec (1.2). See 'metayml_error' in the dist view for more info.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-current.html and change your META.yml accordingly},
            code=>sub {
                my $d=shift;
                return check_spec_conformance($d,'current',[qw(meta-spec name version abstract author license generated_by)]);
            },
        },
    ];
}

sub check_spec_conformance {
    my ($d,$version,$fields)=@_;
    my $yaml=$d->{meta_yml};
    my %fields=map {$_=>1} @$fields;
    foreach my $field (keys %fields) {
        delete $fields{$field} if exists $yaml->{$field};
    }
    if (scalar keys %fields == 0) {
        return 1;
    } else {
        $d->{metayml_error}.=join("",map {"'$_' missing (META.yml spec $version)\n"} keys %fields);
        return 0;
    }
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

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

=item * metayml_conforms_spec_1_2

=back

=head3 check_spec_conformance

  check_spec_conformance($d,$version,$fields);

Checks if META.yml contains the neccessary keys

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at
and Gabor Szabo, <gabor@pti.co.il>, http://www.szabgab.com

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
