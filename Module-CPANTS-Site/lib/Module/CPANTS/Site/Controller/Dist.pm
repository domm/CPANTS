package Module::CPANTS::Site::Controller::Dist;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub search : Local {
    my ( $self, $c, $term ) = @_;

    $term ||= $c->req->param( 'dist' );

    return unless $term;

    $c->log->debug( "search dist for $term" ) if $c->debug;
    $term=~s/::/-/g;
        
    # todo: ignore case in searches
    $c->stash->{ term } = $term;
    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {
            dist => { ILIKE => $term . '%' },
        },
        {
            order_by => 'dist ASC',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 20,
        }
    );
}

sub view : Path {
    my ( $self, $c, $distname ) = @_;
    
    unless( $distname ) {
        $c->stash->{ template } = 'dist/search';
        return;
    }

    my $dist;
    if ( $distname =~ /^\d+$/ ) {
        $dist = $c->model( 'DBIC::Dist' )->find( $distname );
    } else {
        $dist = $c->model( 'DBIC::Dist' )->search( { dist => $distname } )->first;

        if( !$dist ) {
        # TODO
        #my @mod=Module::CPAN->search(module=>$distname_colons);
        #if (@mod == 1) {
        #    return $c->res->redirect("/dist/".$mod[0]->dist->dist_without_version);
        #}
            $c->stash->{ template } = 'dist/search';
            $c->detach( 'search', [ $distname ] );
        }
    }

    $c->stash->{ dist          } = $dist;
    $c->stash->{ kwalitee_hash } = $c->model( 'Kwalitee' )->get_indicators_hash;
    $c->stash->{ requiring     } = $dist->search_related(
        'requiring',
        { },
        {
            order_by => 'dist.dist',
            prefetch => [ qw( dist ) ],
        }
    );
    $c->stash->{ prereqs       } = $dist->search_related(
        'prereq',
        { },
        {
            order_by => 'me.requires',
            prefetch => [ qw( dist ) ],
        }
    );
}

sub shortcoming : Local {
    my ( $self, $c ) = @_;
    my $sc = $c->req->param( 'metric' );

    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {
            "kwalitee.$sc" => 0,
        },
        {
            join     => [ qw( kwalitee ) ],
            order_by => 'me.dist',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 40,
        }
    );
}

sub clean_distname {
    my ( $self, $distname ) = @_;
    my $distname_colons = $distname;

    if ( $distname =~ /::/ ) {
        $distname = ~s/::/-/g;
    } else {
        $distname_colons = ~s/-/::/g;
    }

    return ( $distname, $distname_colons );
}   

'listening to: Nightmares on Wax - in a space outta sound';

__END__

=head1 NAME

Module::CPANTS::Site::Controller::Dist - Catalyst Controller

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
