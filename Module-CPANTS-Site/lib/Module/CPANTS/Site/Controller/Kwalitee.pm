package Module::CPANTS::Site::Controller::Kwalitee;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub shortcoming : Local {
    my ( $self, $c ) = @_;
    my $metric       = $c->req->param( 'name' );
    my $kwalitee     = $c->model( 'Kwalitee' );
    
    $c->stash->{ indicator } = $kwalitee->get_indicators_hash->{ $metric };
}

sub view : Path {
    my ( $self, $c, $distname ) = @_;
    
    my $dist = $c->model( 'DBIC::Dist' )->search( { dist => $distname } );

    $c->stash->{ dist } = $dist->first;
}

'listening to: kids during judo training';

__END__

=head1 NAME

Module::CPANTS::Site::Controller::Kwalitee - Catalyst Controller

=head1 SYNOPSIS

See L<Module::CPANTS::Site>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS


=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
