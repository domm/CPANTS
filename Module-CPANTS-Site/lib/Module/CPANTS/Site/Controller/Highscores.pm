package Module::CPANTS::Site::Controller::Highscores;

use strict;
use warnings;

use base qw( Catalyst::Controller );

sub index : Private { }

sub hall_of_fame : Local {
    my ( $self, $c )=@_;

    my $max = $c->max_kwalitee;
    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {
            'kwalitee.kwalitee' => $max,
        },
        {
            join     => [ qw( kwalitee author ) ],
            order_by => 'author.pauseid',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 40,
         }
    );
}

sub hall_of_shame : Local {
    my ( $self, $c ) = @_;

    my $max = $c->max_kwalitee;
    my $min = int( $max / 3 );

    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {
            'kwalitee.kwalitee' => { '<=', $min },
        },
        {
            join     => [ qw( kwalitee author ) ],
            order_by => 'kwalitee.kwalitee, author.pauseid',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 40,
         }
    );
}

sub many : Local {
    my ( $self, $c ) = @_;
    $c->stash->{ list } = $c->model( 'DBIC::Author' )->search(
        {
             num_dists => { '>=', 5 },
        },
        {
            order_by => 'average_kwalitee DESC, num_dists DESC, pauseid',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 100,
        
        },
    );
   
    $c->stash->{ top40type } = 'many';
    $c->stash->{ template  } = 'highscores/top40';
}

sub few : Local {
    my ( $self, $c ) = @_;
    $c->stash->{ list } = $c->model( 'DBIC::Author' )->search(
        {
             num_dists=>[ { '<', 5, '>', 0 } ]
        },
        {
            order_by => 'average_kwalitee DESC, num_dists DESC, pauseid',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 100,
        
        },
    );

    $c->stash->{ top40type } = 'few';
    $c->stash->{ template  } = 'highscores/top40';
}

1;

__END__

=head1 NAME

Module::CPANTS::Site::Controller::Highscores - Catalyst Controller

=head1 SYNOPSIS

See L<Module::CPANTS::Site>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS


=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
