package Module::CPANTS::Kwalitee::Pod;
use warnings;
use strict;
use Pod::Simple::Checker;
use File::Spec::Functions qw(catfile);


sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my $files=$me->d->{files_array};
    my $distdir=$me->distdir;

    my $pod_errors=0;
    my @msgs;
    foreach my $file (@$files) {
        next unless $file=~/\.p(m|od|l)$/;

        eval {
            # Count the number of POD errors
            my $parser=Pod::Simple::Checker->new;
            my $errata;
            $parser->output_string(\$errata);
            $parser->parse_file(catfile($distdir,$file));
            my $errors=()=$errata=~/Around line /g;
            $pod_errors+=$errors;
            push(@msgs,$errata) if $errata=~/\w/;
        }
    }
    if (@msgs) {
        # work around Pod::Simple::Checker returning strange data
        my $errors=join("\n",@msgs);
        $errors=~s/[^\w\d\s]+/ /g;
        $me->d->{error}{no_pod_errors}=$errors;
    }
}


##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'no_pod_errors',
            error=>q{The documentation for this distribution contains syntactic errors in its POD. Note that this metric tests all .pl, .pm and .pod files, even if they are in t/. See 'pod_message' in the dist error view for more info.},
            remedy=>q{Remove the POD errors. You can check for POD errors automatically by including Test::Pod to your test suite.},
            code=>sub { shift->{error}{no_pod_errors} ? 0 : 1 },
        },
    ];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Pod - Check Pod

=head1 SYNOPSIS

Check if the POD of a dist is syntactically correct.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::Pod> uses C<Pod::Simple::Checker> to check if there are any syntactic errors in the POD.

It checks all files matching C</\.p(m|od|l)$/>.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * no_pod_errors

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2006, 2009  Thomas Klausner

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
