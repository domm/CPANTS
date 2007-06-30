package Module::CPANTS::Kwalitee::NeedsCompiler;
use warnings;
use strict;

sub order { 200 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my $files=$me->d->{files_array};
    foreach my $f (@$files) {
        if ($f =~ /\.[hc]$/i or $f =~ /\.xs$/i) {
            $me->d->{needs_compiler}=1;
            return;
        }
    }
    if (defined ref($me->d->{prereq}) and ref($me->d->{prereq} eq 'ARRAY')) {
        for my $m (@{ $me->d->{prereq} }) {
            if ($m->{requires} =~ /^Inline::/
               or $m->{requires} eq 'ExtUtils::CBuilder'
               or $m->{requires} eq 'ExtUtils::ParseXS') {
                $me->d->{needs_compiler}=1;
                return;
            }
        }
    }
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
    ];
}


q{Favourite compiler:
  gcc};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::NeedsCompiler - Checks if the module needs a (probably C) compiler

=head1 SYNOPSIS

Checks if there is some indication in the module that it needs a C compiler to build and install

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<200>.

=head3 analyse

Checks for file with .c, .h or .xs extensions.
Check is the module depends on any of the Inline:: modules or
on ExtUtils::CBuilder or ExtUtils::ParseXS.

=head3 TODO:

How to recognize cases such as http://search.cpan.org/dist/Perl-API/ 
and http://search.cpan.org/dist/Term-Size-Perl
that generate the .c files during installation
 
=head3 kwalitee_indicators

No Kwalitee Indicator.

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Gabor Szabo <gabor@pti.co.il> http://www.pti.co.il

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
