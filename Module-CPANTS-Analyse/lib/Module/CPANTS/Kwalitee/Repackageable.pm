package Module::CPANTS::Kwalitee::Repackageable;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use List::MoreUtils qw(all any);
#use  Pod::Simple::TextContent;


sub order { 900 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;

   
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    my @fedora_licenses = qw(perl apache artistic_2 gpl lgpl mit mozilla);
    # based on: http://fedoraproject.org/wiki/Licensing
    my $fedora_licenses = "Acceptable licenses: (" . join(", ", @fedora_licenses) . ")";
    my $experimental = "This is an experimental metric. Still researching its requirements.";
    return [
         {
            name=>'easily_repackageagble_by_debian',
            error=>qq{It is easy to repackage this module by Debian. $experimental},
            remedy=>q{Fix each one of the metrics this depends on},
            is_extra=>1,
            code=>sub { 
                my $d=shift;
                my @required = qw(no_generated_files has_tests_in_t_dir);

                my $good = all { $d->{kwalitee}{$_} } @required;
                return $good;
            }
        },
         {
            name=>'easily_repackageagble_by_fedora',
            error=>qq{It is easy to repackage this module by Fedora. $fedora_licenses. $experimental},
            remedy=>q{Fix each one of the metrics this depends on},
            is_extra=>1,
            code=>sub { 
                my $d=shift;
                my @required = qw(no_generated_files);

                my $good = all { $d->{kwalitee}{$_} } @required;
                my $license = $d->{meta_yml}{license};
                $good = $good and defined $license and any {$license eq $_} @fedora_licenses;
                return $good;
            }
        },
         {
            name=>'easily_repackageagble',
            error=>qq{It is easy to repackage this module. $experimental See <a href="http://www.perlfoundation.org/perl5/index.cgi?cpan_packaging">cpan_packaging</a> },
            remedy=>q{Fix each one of the metrics this depends on},
            is_extra=>1,
            code=>sub { 
                my $d=shift;
                my @required = qw(easily_repackageagble_by_debian easily_repackageagble_by_fedora);
                my $good = all { $d->{kwalitee}{$_} } @required;
                #use Data::Dumper;
                #print STDERR Dumper $d;
                return $good;
            }
        },
    ];
}


q{Favourite record of the moment:
  Lili Allen - Allright, still};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Repackageable - Checks for various signs that make a module packageable

=head1 SYNOPSIS

There are several agregate metrics in here.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

=head3 analyse

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * easily_repackageagble

=item * easily_repackageagble_by_fedora

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at
and Gabor Szabo, <gabor@pti.co.il>, http://www.szabgab.com

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
