package Module::CPANTS::Site::Controller::Root;

use strict;
use warnings;

use base qw( Catalyst::Controller );

__PACKAGE__->config->{ namespace } = '';

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->status( '404' );
    $c->res->body( 'Not Found' );
}

sub index : Private {
    my ( $self, $c ) = @_;
    $c->stash->{ template } = 'index';
}

sub static_html : Regex('^([a-z_0-9]+)\.html$') {
    my ( $self, $c ) = @_;
    my $file = $c->req->captures->[ 0 ];

    $c->detach( 'index' ) if $file eq 'index';

    my @path = ( qw( templates static ), $file );
    $c->detach( 'default' ) unless -e $c->path_to( @path );

    $c->stash->{ template } = join( '/', @path[ 1, 2 ] );
}

1;

__END__

=head1 NAME

Module::CPANTS::Site::Controller::Root - Catalyst Controller

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
