package Module::CPANTS::Site;

use strict;
use warnings;
use Module::CPANTS::ProcessCPAN::ConfigData;
use File::Spec::Functions;
use Catalyst qw(Static::Simple
    Session
    Session::Store::File
    Session::State::Cookie
);

my $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');
my $db_user=Module::CPANTS::ProcessCPAN::ConfigData->config('db_user');
my $db_pwd=Module::CPANTS::ProcessCPAN::ConfigData->config('db_pwd');
$Template::Directive::WHILE_MAX=3000;
use version; our $VERSION = version->new('0.75');


__PACKAGE__->config(
    name    => 'Module::CPANTS::Site',
    home    => $home,
    root    => catdir($home,'root'),
    'View::TT' => {
        WRAPPER=>'wrapper',
        INCLUDE_PATH=>catdir($home,'templates'),
    },
    'Model::DBIC'=>{
        schema_class=>'Module::CPANTS::Schema',
        connect_info=>['dbi:Pg:dbname=cpants',$db_user,$db_pwd],
    },
);

__PACKAGE__->setup;
    

sub end : Private {
    my ( $self, $c ) = @_;
    
    my $kw = $c->model( 'Kwalitee' );
    my $rs = $c->model( 'DBIC::Run' )->search(
        {},
        {
            order_by => 'id desc',
            rows     => 1,
        }
    );
    
    $c->stash->{ VERSION } = $VERSION;
    $c->stash->{ run     } = $rs->first;
    $c->stash->{ mck     } = $kw;
    $c->stash->{ perlversion } = $];

    $c->stash->{cpants_is_analysing}=1 if (-e catfile($home,'cpants_is_analysing'));

    $c->forward( $c->view('') ) unless $c->stash->{'is_redirect'} || $c->response->body;
}

sub max_kwalitee {
    my ( $c ) = @_;
    
    my $rs = $c->model('DBIC::Kwalitee')->search(
        {},
        {
            select => [ { max => 'kwalitee' } ],
            as     => [ qw( kwalitee ) ],
        }
    );
    return $rs->first->kwalitee;
}

'listening to: Nightmares on Wax - in a space outta sound';

__END__

=head1 NAME

Module::CPANTS::Site - Catalyst based application

=head1 SYNOPSIS

    script/module_cpants_site_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=head2 end

=cut

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

