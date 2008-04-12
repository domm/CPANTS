package Module::CPANTS::Site::Controller::JSON::Dist;

use base qw/Catalyst::Controller/;

use strict;

sub dependencies : Local {
    my ($self,$c,$dist_name) = @_;
    my $dist=$c->model('DBIC::Dist')->get_dist($dist_name);
    $c->detach('/default') unless $dist;
    $c->stash->{dist}=$dist->dist;
    $c->stash->{ prereqs }          = [ map { $_->as_hashref } 
                                      $dist->get_prereqs()];
    $c->stash->{ build_prereqs }    = [ map { $_->as_hashref } 
                                      $dist->get_build_prereqs()];
    $c->stash->{ optional_prereqs } = [ map { $_->as_hashref } 
                                      $dist->get_optional_prereqs()];
    $c->stash->{ optional_prereqs } = [ map { $_->dist->as_hashref } 
                                      $dist->used_by()];
    
}

1;