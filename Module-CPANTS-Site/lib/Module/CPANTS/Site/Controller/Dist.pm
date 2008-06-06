package Module::CPANTS::Site::Controller::Dist;

use strict;
use warnings;

use base qw( Catalyst::Controller::BindLex );

sub search : Local {
    my ( $self, $c, $search ) = @_;
    my $term : Stashed = $search || $c->req->param( 'dist' );

    return unless $term;

    $c->log->debug( "search dist for $term" ) if $c->debug;
    $term=~s/::/-/g;
        
    my $list : Stashed = $c->model( 'DBIC::Dist' )->search(
        {
            dist => { ILIKE =>  '%' . $term . '%' },
        },
        {
            order_by => 'dist ASC',
            page     => $c->request->param( 'page' ) || 1,
            rows     => 20,
        }
    );
    if ($list == 1) {
        $c->response->redirect($c->uri_for('/dist/overview',$list->first->dist));
    }
}

# for backward compat / google

sub view : Path {
    my ( $self, $c, $distname ) = @_;
    $c->res->redirect($c->uri_for('overview',$distname));
}   

sub overview : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
}

sub kwalitee : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
    my $kwalitee_hash : Stashed = $c->model( 'Kwalitee' )->get_indicators_hash;
}

sub prereq : Local {
    my ( $self, $c, $distname ) = @_;
    my $dist = $c->forward('get_dist',[ $distname ]);
    $c->stash->{ prereqs } = $dist->get_prereqs();
    $c->stash->{ build_prereqs } = $dist->get_build_prereqs();
    $c->stash->{ optional_prereqs } = $dist->get_optional_prereqs();
}

sub used_by : Local {
    my ( $self, $c, $distname ) = @_;
    my $dist = $c->forward('get_dist',[ $distname ]);
    $c->stash->{ used_by } = $dist->used_by;
}

sub metadata : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
}

sub provides : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
}

sub errors : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
}

sub external : Local {
    my ( $self, $c, $distname ) = @_;
    $c->forward('get_dist',[ $distname ]);
}

sub get_dist : Private {
    my ( $self, $c, $distname ) = @_;

    unless( $distname ) {
        $c->stash->{ template } = 'dist/search';
        $c->detach( 'search' );
    }
    
    my $dist = $c->model('DBIC::Dist')->get_dist($distname);
    if( !$dist ) {
        $c->stash->{ template } = 'dist/search';
        $c->detach( 'search', [ $distname ] );
    }

    $c->stash->{dist} = $dist;
    return $dist;
}

sub json : Local Args(1) {
my ($self,$c,$distname) = @_;
$c->forward('get_dist',[ $distname ]);
}

# FIXME: All this crud should be movied into the model.
my %bys=( 
size_packed     => 'size_packed DESC,dist',
size_unpacked   => 'size_unpacked DESC,dist',
files           => 'files DESC,dist',
age             => {
    order_by=>'released,dist',
    show_field=>'released',
},
absolute_kwalitee  => { 
    join=>'kwalitee',
    prefetch=>'kwalitee',
    order_by=>'kwalitee.kwalitee desc,me.dist',
    '+select' => [ 'kwalitee.kwalitee' ],
    '+as'     => [ 'kwalitee' ],
    show_field=>'kwalitee',
},
core_kwalitee    =>  { 
    join=>'kwalitee',
    prefetch=>'kwalitee',
    order_by=>'kwalitee.rel_core_kw desc,me.dist',
    '+select' => [ 'kwalitee.rel_core_kw' ],
    '+as'     => [ 'kwalitee' ],
    show_field=>'kwalitee',
},

);

sub by : Local {
    my ( $self, $c, $fld ) = @_;
    my $by=$bys{$fld} || die "No such page: stats/by/$fld";
    my $title=$fld;
    my @order;
    if (ref($by) eq 'HASH') {
        $fld=$by->{show_field} if $by->{show_field};
        @order=%$by;
        $c->stash->{no_format}=1;
    }
    else {
        @order=(order_by=>$by);
    }
    $c->stash->{template}='dist/by_date' if $fld eq 'released';
    $c->stash->{field}=$fld;
    $c->stash->{title}=$title;
    
    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {},
        {
            @order,
            page     => $c->request->param( 'page' ) || 1,
            rows     => 40,
        }
    );
}
   
sub by_required : Local {
    my ( $self, $c, $fld ) = @_;
    $c->stash->{field}=$fld;
    $c->stash->{template}='dist/by';
    
    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search_related(
        'requiring',
        { 'requiring.in_dist'=> { '>'=>'0' } },
        {
            select  => [{count=>'requiring.in_dist'}],
            #as      => [qw(in_dist count)],
            group_by    => [qw(in_dist)],
            page     => $c->request->param( 'page' ) || 1,
            rows     => 40,
        }
    );


}



# TODO move to Kwalitee
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

sub complying : Local {
    my ( $self, $c ) = @_;
    my $sc = $c->req->param( 'metric' );

    $c->stash->{ list } = $c->model( 'DBIC::Dist' )->search(
        {
            "kwalitee.$sc" => 1,
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
