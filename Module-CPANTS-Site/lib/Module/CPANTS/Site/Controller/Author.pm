package Module::CPANTS::Site::Controller::Author;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub search : Local {
    my ( $self, $c, $search ) = @_;
    my $term = $c->stash->{term} = $search || $c->req->param( 'pauseid' );
 
    return unless $term;
    $term=~s/\s//g;

    $c->log->debug( "search author for $term" ) if $c->debug;
    
    my $list = $c->stash->{list} = $c->model( 'DBIC::Author' )->search_like(
        {
            pauseid => uc( $term ) . '%',
        },
        {
            order_by => 'pauseid ASC',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 20,
        }
    );

    if ($list == 1) {
        $c->res->redirect($c->uri_for('/author',$list->first->pauseid));
    }

}

sub view : Path {
    my ( $self, $c, $author ) = @_;

    unless( $author ) {
        $c->stash->{ template } = 'author/search';
        return;
    }

    my $item = $c->model( 'DBIC::Author' )->search(
        { pauseid => $author }
    )->first;

    if ( !$item ) {
        $c->stash->{ template } = 'author/search';
        $c->detach( 'search', [ $author ] );
    }

    $c->stash->{ item } = $item;
}

1;

__END__

=head1 NAME

Module::CPANTS::Site::Controller::Author - Catalyst component

=head1 SYNOPSIS

See L<Module::CPANTS::Site>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS


=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

