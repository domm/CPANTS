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
        } else {
            warn "Invalid row in Debian file:\n$row\n";
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
            error=>qq{The module is distributed by Debian},
            remedy=>q{Make your package easily repackagable by Debian and convince the Debian-Perl team to package your module},
            is_extra=>1,
            is_experimental=>1,
            code=> sub {
                    my $d = shift;
                    #die Dumper [$debian, $d];
                    my $metric=shift;
                    return $debian->{ $d->{dist} } ? 1 : 0;
                    
                },
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

=item * easily_repackageable

=item * easily_repackageable_by_fedora

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
