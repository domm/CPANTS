package Module::CPANTS::Kwalitee::Uses;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Module::ExtractUse;

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my $distdir=$me->distdir;
    my $modules=$me->d->{modules};
    my $files=$me->d->{files_array};
    my @tests=grep {m|^x?t\b.*\.t|} @$files;

    my %skip=map {$_->{module}=>1 } @$modules;
    my %uses;
    
    # used in modules
    my $p=Module::ExtractUse->new;
    foreach (@$modules) {
        $p->extract_use(catfile($distdir,$_->{file}));
    }

    while (my ($mod,$cnt)=each%{$p->used}) {
        next if $skip{$mod};
        $uses{$mod}={
            module=>$mod,
            in_code=>$cnt,
            in_tests=>0,
        };
    }
    
    # used in tests
    my $pt=Module::ExtractUse->new;
    foreach my $tf (@tests) {
        next if -s catfile($distdir,$tf) > 1_000_000; # skip very large test files
        $pt->extract_use(catfile($distdir,$tf));
    }
    while (my ($mod,$cnt)=each%{$pt->used}) {
        next if $skip{$mod};
        if ($uses{$mod}) {
            $uses{$mod}{'in_tests'}=$cnt;
        } else {
            $uses{$mod}={
                module=>$mod,
                in_code=>0,
                in_tests=>$cnt,
            }
        }
    }

    $me->d->{uses}=\%uses;
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'use_strict',
            error=>q{This distribution does not 'use strict;' in all of its modules.},
            remedy=>q{Add 'use strict' to all modules.},
            code=>sub {
                my $d=shift;
                my $modules=$d->{modules};
                my $uses=$d->{uses};
                return 0 unless $modules && $uses;
                
                my ($strict)=$uses->{'strict'};
                return 0 unless $strict;
                return 1 if $strict->{in_code} >= @$modules;
                return 0;
            },
        },
        {
            name=>'use_warnings',
            error=>q{This distribution does not 'use warnings;' in all of its modules.},
            is_extra=>1,
            remedy=>q{Add 'use warnings' to all modules.},
            code=>sub {
                my $d=shift;
                my $modules=$d->{modules};
                my $uses=$d->{uses};
                use Data::Dumper;
                return 0 unless $modules && $uses;
                my ($warnings)=$uses->{'warnings'};
                return 0 unless $warnings;
                return 1 if $warnings->{in_code} >= @$modules;
                return 0;
            },
        },
        
        {
            name=>'has_test_pod',
            error=>q{Doesn't include a test for pod correctness (Test::Pod)},
            remedy=>q{Add a test using Test::Pod to check for pod correctness.},
            code=>sub {
                my $d=shift;
                return 1 if $d->{uses}->{'Test::Pod'};
                return 0;
            },
        },
        {
            name=>'has_test_pod_coverage',
            error=>q{Doesn't include a test for pod coverage (Test::Pod::Coverage)},
            remedy=>q{Add a test using Test::Pod::Coverage to check for POD coverage.},
            code=>sub {
                my $d=shift;
                return 1 if $d->{uses}->{'Test::Pod::Coverage'};
                return 0;
            },
        },
    ];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Uses - Checks which modules are used

=head1 SYNOPSIS

Check which modules are actually used in the code.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::Uses> uses C<Module::ExtractUse> to find all C<use> statements in code (actual code and tests).

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * use_strict

=item * has_test_pod

=item * has_test_pod_coverage

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut

