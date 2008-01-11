package Module::CPANTS::ProcessCPAN;
use strict;
use warnings;

use Module::CPANTS::Analyse;
use Module::CPANTS::Schema;
use Module::CPANTS::Kwalitee;
use Module::CPANTS::ProcessCPAN::ConfigData;
use base qw(Class::Accessor);
use Carp;
use File::Spec::Functions qw(catdir catfile rel2abs);
use Parse::CPAN::Packages;
use YAML::Syck qw(Load);
use FindBin;
use File::Copy;
use DateTime;

use version; our $VERSION=version->new('0.72');

__PACKAGE__->mk_accessors(qw(cpan lint force run prev_run _db _db_hist));

sub new {
    my ($class,$cpan,$lint)=@_;

    my $me=bless {},$class;
    $me->cpan(rel2abs($cpan)) if $cpan;
    $me->lint(rel2abs($lint)) if $lint;
    return $me;
}

sub start_run {
    my $me=shift;

    my $mck=Module::CPANTS::Kwalitee->new;
    my $total_kwalitee=$mck->total_kwalitee;
    
    # prev run
    my @prev=$me->db->resultset('Run')->search(
        {},
        {
            order_by=>'date desc',
            rows=>1,
        }
    );
    $me->prev_run($prev[0]);
     
    my $now=DateTime->now;
    my $run=$me->db->resultset('Run')->create({
        mcanalyse_version=>$Module::CPANTS::Analyse::VERSION,
        mcprocess_version=>$Module::CPANTS::ProcessCPAN::VERSION,
        available_kwalitee=>$mck->available_kwalitee,
        total_kwalitee=>$mck->total_kwalitee,
        date=>$now,
    });
    $me->run($run);
    print $run->id,"\n";

    return $me;
}

sub process_cpan {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $db=$me->db;
    my $lint=$me->lint;
    my $analysed=$me->yaml_analysed;
    my $processed=$me->yaml_processed;
    my %seen;
    
    # prefill in_db
    my %in_db;
    my $all_dists=$db->resultset('Dist')->search;
    while (my $d=$all_dists->next) {
        $in_db{$d->dist}++;
    }

    foreach my $dist (sort {$a->dist cmp $b->dist} $p->latest_distributions) {
        my $vname=$dist->distvname;
        next if $vname=~/^perl[-\d]/;
        next if $vname=~/^ponie-/;
        next if $vname=~/^Perl6-Pugs/;
        next if $vname=~/^parrot-/;
        next if $vname=~/^Bundle-/;
        $seen{$dist->dist}++;

        if ($in_db{$dist->dist}) {
            if ($me->force) {
                print "forced reindex of $vname\n";
            }
            else {
                print "skipping $vname\n";
                next;
            }
        }
        else {
            print "new version of $vname\n";
        }
    
        print "analyse $vname\n";
        my $file=$me->cpan_path_to_dist($dist->prefix);
        
        # call cpants_lint.pl
        my $from_lint=`$^X $lint --yaml --dir $analysed $file`;
        $me->process_yaml($from_lint);   
    
    }

    # dump old dists from DB
    my @distributions=$p->distributions;
    my %dists=map {$_->dist => 1} grep { $_->dist }   @distributions;

    $all_dists->reset;
    while (my $d=$all_dists->next) {
        unless ($seen{$d->dist}) {
            print $d->dist." not on CPAN anymore, deleted from DB\n";
            $d->delete;
        }
    }
}

sub process_yaml {
    my ($me,$yaml)=@_;
    
    my $db=$me->db;
    my $run=$me->run;
    my $data; 
    eval { $data=Load($yaml) };
    if ($@) {
        print "Cannot parse YAML: $@";
        next;
    }

    # remove old data from this dist
    my $exists=$db->resultset('Dist')->find({dist=>$data->{dist}});
    if ($exists) {
        $me->make_dist_history($exists); 
        $exists->delete;
    }

    # remove data that references other tables;
    my $kwalitee=$data->{kwalitee};
    my $modules=$data->{modules};
    my $uses=$data->{uses};
    my $prereq=$data->{prereq};
    my $author=$data->{author};
    my $error=$data->{error};
    foreach (qw(kwalitee modules uses prereq files_array dirs_array author meta_yml error)) {
        delete $data->{$_};
    }
        
    my ($db_author,$db_dist,$db_error);
        
    # save author 
    eval { 
        $db_author=$db->resultset('Author')->find_or_create({pauseid=>$author});
        $me->make_author_history($db_author);
            
        $db_dist=$db_author->add_to_dists({ 
            dist=>$data->{dist},
            run=>$run->id,
        });

        $db_error=$db->resultset('Error')->find_or_create({dist=>$db_dist->id});
    };
    print "DB ERROR: cannot create dist: $@" and next if $@; 

    # add data and add stuff to other tables
    eval {
        $db_dist->update($data);
            
        foreach my $m (@$modules) {
            $db_dist->add_to_modules($m);
        }
        foreach my $pq (@$prereq) {
            $db_dist->add_to_prereq($pq);
        }
        foreach my $u (values %$uses) {
            $db_dist->add_to_uses($u);
        }
        while (my ($k,$v)=each %$error) {
            $db_error->$k($v);
        }
        $db_error->update;
    };
    if ($@) {
        my $from_cpants='';
        if (my $old=$db_error->cpants) {
            $from_cpants="$old\n";
        }
        print "$@\n";
        $db_error->cpants(join('',$from_cpants,"DB: $@"));
        $kwalitee->{no_cpants_errors}=0;
    }

    eval {
        $db_error->update;
        $kwalitee->{dist}=$db_dist->id;
        $kwalitee->{run}=$run->id;
        $kwalitee->{kwalitee}=0;
        $db->resultset('Kwalitee')->create($kwalitee);
    };
    if ($@) {
        my $e=$@;
        print $data->{dist}." DB kwalitee error: $e";
    }

    return;
}

sub make_author_history {
    my $me=shift;
    my $author=shift;
    
    my $db=$me->db;

    $db->resultset('HistoryAuthor')->create({
        run=>$me->run->id,
        author=>$author->id,
        average_kwalitee=>$author->average_kwalitee || 0,
        num_dists=>$author->num_dists || 0,
        rank=>$author->rank || 0,
    });
    
    # set conveniece fields in current author
    $author->prev_av_kw($author->average_kwalitee || 0);
    $author->prev_rank($author->rank|| 0);
    $author->update; 
}

sub make_dist_history {
    my ($me,$dist)=@_;
    return; 
    my $old_kw=$dist->kwalitee ? $dist->kwalitee->kwalitee : 0;
    
    $me->db->resultset('HistoryDist')->find_or_create({
        run=>$me->run->id,
        distname=>$dist->dist,
        version=>$dist->version,
        kwalitee=>$old_kw,
    });
    
}

sub db {
    my $me=shift;
    return $me->_db if $me->_db;
   
    return $me->_db(Module::CPANTS::Schema->connect(
        'dbi:Pg:dbname=cpants',
        Module::CPANTS::ProcessCPAN::ConfigData->config('db_user'),
        Module::CPANTS::ProcessCPAN::ConfigData->config('db_pwd')
    ));
}

sub cpan_01mailrc {
    my $me=shift;
    return catfile($me->cpan,'authors','01mailrc.txt.gz');
}

sub cpan_02packages {
    my $me=shift;
    return catfile($me->cpan,'modules','02packages.details.txt.gz');
}

sub cpan_path_to_dist {
    my $me=shift;
    my $prefix=shift;
    return catfile($me->cpan,'authors','id',$prefix);
}

=head2 Accessors to various directories

=cut

sub home_dir {
    my $me=shift;
    return Module::CPANTS::ProcessCPAN::ConfigData->config('home');
}

sub yaml_analysed { return catdir(shift->home_dir,qw(yaml analysed)) }
sub yaml_processed { return catdir(shift->home_dir,qw(yaml processed)) }

1;

__END__


=pod

=head1 NAME

Module::CPANTS::ProcessCPAN - Generate Kwalitee ratings for the whole CPAN

=head1 SYNOPSIS
  
=head1 DESCRIPTION

Run CPANTS on the whole of CPAN. Includes a DBIx::Class based DB abstraction layer. More docs soon...

=head1 WEBSITE

http://cpants.perl.org/

=head1 BUGS

Please report any bugs or feature requests, or send any patches, to
bug-module-cpants-analyse at rt.cpan.org, or through the web interface at
http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-CPANTS-ProcessCPAN.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

Please use the perl-qa mailing list for discussing all things CPANTS:
http://lists.perl.org/showlist.cgi?name=perl-qa

=head1 LICENSE

This code is Copyright (c) 2003-2006 Thomas Klausner.
All rights reserved.

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut


