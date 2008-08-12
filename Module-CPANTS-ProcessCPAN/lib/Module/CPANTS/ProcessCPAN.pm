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

use version; our $VERSION=version->new('0.77');

__PACKAGE__->mk_accessors(qw(cpan lint force run prev_run _db _db_hist mck));

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
    $me->mck($mck);
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

sub stop_run {
    my $class=shift;
    my $me = $class->new;
    # prev run
    my $prev=$me->db->resultset('Run')->search(
        {},
        {
            order_by=>'date desc',
            rows=>1,
        }
    )->first;
    my $now=DateTime->now;
    $prev->stop($now);
    $prev->update;
}

sub process_cpan {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $db=$me->db;
    my $lint=$me->lint;
    my %seen=('Core'=>1);
    
    # prefill in_db
    my %in_db;
    my $all_dists=$db->resultset('Dist')->search;
    if($all_dists) {
        while (my $d=$all_dists->next) {
            next unless $d->vname;
            next if $d->dist eq 'Core';
            $in_db{$d->vname}++;
        }
    }
    $db->resultset('Dist')->find_or_create({dist=>'Core',id=>0,is_core=>1});

    my %authors;
    foreach my $dist (sort {$a->dist cmp $b->dist} $p->latest_distributions) {
        my $vname=$dist->distvname;
        next if $vname=~/^perl[-_]/;
        next if $vname=~/^ponie-/;
        next if $vname=~/^Perl6-Pugs/;
        next if $vname=~/^parrot-/;
        next if $vname=~/^Bundle-/;
        $seen{$dist->dist}++;

        if ($in_db{$dist->distvname}) {
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
        my $from_lint=`$^X $lint --yaml $file`;
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

    #use Data::Dumper;
    #print Dumper $data;

    # remove data that references other tables;
    my $kwalitee    = delete $data->{kwalitee};
    my $modules     = delete $data->{modules};
    my $uses        = delete $data->{uses};
    my $prereq      = delete $data->{prereq};
    my $author      = delete $data->{author};
    my $error       = delete $data->{error};
    my $versions    = delete $data->{versions};
    my $licenses    = delete $data->{licenses};
    my $test_files  = delete $data->{test_files};
    $data->{test_files_list} = join(';',@$test_files) if $test_files && ref($test_files) eq 'ARRAY';

    # TODO store licenses & versions
    foreach (qw(files_array ignored_files_array files_hash dirs_array meta_yml)) {
        delete $data->{$_};
    }
        
    my ($db_author,$db_dist,$db_error);
    eval {
        if ($db_dist=$db->resultset('Dist')->find({dist=>$data->{dist}})) {
            $me->make_dist_history($db_dist);
            $db_dist->run($run->id);
            $db_author=$db_dist->author;
        }
        else {    
            $db_author=$db->resultset('Author')->find_or_create({pauseid=>$author});
                   
            $db_dist=$db_author->add_to_dists({ 
                dist=>$data->{dist},
                run=>$run->id,
            });
        }
        $db_error=$db->resultset('Error')->find_or_create({dist=>$db_dist->id});
    };
    print "DB ERROR: cannot create dist: $@" and return if $@; 

    eval {
        # purge errors from old runs
        foreach my $col ($db_error->columns) {
            next if $col eq 'id' || $col eq 'dist';
            $db_error->$col('');
        }
        $db_error->update;
    };
    if ($@) {
        die $@;
        $db_error->cpants("purge errors: $@");
    }

    # todo move to update authors..
    $me->make_author_history($db_dist->author);
    
    # add data and add stuff to other tables
    my $distid=$db_dist->id;
    eval {
        $db_dist->update($data);
        $db_dist->modules->delete;
        $db_dist->prereq->delete;
        $db_dist->uses->delete;
        foreach my $m (@$modules) {
            $m->{dist}=$distid;
            $db->resultset('Modules')->find_or_create($m);
        }
        foreach my $pq (@$prereq) {
            $pq->{dist}=$distid;
            $db->resultset('Prereq')->find_or_create($pq);
        }
        foreach my $u (values %$uses) {
            $u->{dist}=$distid;
            $db->resultset('Uses')->find_or_create($u);
        }
        while (my ($k,$v)=each %$error) {
            $v = join(', ',@$v) if ref($v) eq 'ARRAY';
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
        my $kwdb=$db->resultset('Kwalitee')->find_or_create({
            dist=>$db_dist->id,
        });
        my %new_kwalitee=map { $_=>0 } $me->mck->all_indicator_names;
        
        while (my ($k,$v)=each %$kwalitee) {
            $new_kwalitee{$k}=$v || 0;
        }
        $kwdb->update(\%new_kwalitee);
    };
    if ($@) {
        my $e=$@;
        print $data->{dist}." DB kwalitee error: $e";
    }

}

sub make_author_history {
    my $me=shift;
    my $author=shift;
    
    my $db=$me->db;

    eval {
        $db->resultset('HistoryAuthor')->find_or_create({
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
    };
}

sub make_dist_history {
    my ($me,$dist)=@_;
    eval {
        my $old_kw=$dist->kwalitee ? $dist->kwalitee->kwalitee : 0;
        $me->db->resultset('HistoryDist')->find_or_create({
            dist=>$dist->id,
            run=>$me->run->id,
            distname=>$dist->dist,
            version=>$dist->version,
            kwalitee=>$old_kw,
        });
    };
    return;
}

sub db {
    my $me=shift;
    return $me->_db if $me->_db;
   
    return $me->_db(Module::CPANTS::Schema->connect(
        $me->dsn
    ));
}

=head3 dsn

Returns the DSN as a three element list (dbname, user, pwd)

=cut

sub dsn {
    my $me=shift;
    return (
        'dbi:Pg:dbname=cpants',
        Module::CPANTS::ProcessCPAN::ConfigData->config('db_user'),
        Module::CPANTS::ProcessCPAN::ConfigData->config('db_pwd')
    );
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


1;

__END__


=pod

=head1 NAME

Module::CPANTS::ProcessCPAN - Generate Kwalitee ratings for the whole CPAN

=head1 SYNOPSIS
  
=head1 DESCRIPTION

Run CPANTS on the whole of CPAN. Includes a DBIx::Class based DB 
abstraction layer. More docs soon...

=head2 How to set up a local CPANTS processor

=head3 Prereqs

=over

=item * A PostgreSQL DB named C<cpants>

=item * A local CPAN mirror (eg one mirrored with CPAN::Mini)

=item * All the prereqs of Module::CPANTS::Analyse & 
Module::CPANTS::ProcessCPAN

=back

=head3 Set up the DB

You can find the current schema of the CPANTS DB in 
F<sql/cpants.schema>. Use this schema to set up a Postgres DB:

  psql cpants < sql/cpants.schema

You will also need to set up an account in the DB. If you don't know 
how to do that, read the postgres docs...

=head3 Install Module::CPANTS::ProcessCPAN

When you install Module::CPANTS::ProcessCPAN the Build script will ask 
you some questions where to install the app to:

  Please specify the CPANTS home directory: [/home/domm/cpants ]

  Postgres DB user: [cpants ]

  Postgres DB password: [cpants ]

After installing the code with C<sudo ./Build install> you have to 
install the app into the CPANTS home directory you specified earlier:

  ./Build install_cpants

This will set up the needed directories and scripts. Please note that 
if you install Module::CPANTS::Site (the Catalyst-based web frontend), 
    it will re-use the CPANTS home dir and install the cat app into 
    the same location.

=head3 Running CPANTS

Change into the CPANTS home dir. There you will find a dir C<bin> 
containing various scripts. You can either call each script on it's 
own (usefull if your working on one step of the process), or call the 
wrapper script C<bin/run.pl>. C<run.pl> calls all scripts in the 
correct order and with the needed parameters.

C<run.pl> itself takes theses parameters:

=over

=item * --cpan

Required

This is the path to the root of the local cpan mirror

=item * --lint

Required

The path to the C<cpants_lint.pl> script that's comming with 
Module::CPANTS::Analyse. If you're in the middle of developing new 
features (or more likely fixing bugs...) you can point this to the dev 
version in your Module::CPANTS::Analyse repo (C<--lint 
../Module-CPANTS-Analyse/bin/cpants_lint.pl>)

=item * --force 

Optional

Test B<all> dists, not only those that have been uploaded since the last run. Please note that this usually takes aprox an hour...

=back

=head3 Testing only a subset of CPAN

During development of new features it's very annoying to wait for an 
hour until you uncover the next bug. Therefore it pays off to set up a 
slim local CPAN mirror. I wrote CPAN::Mini::FromList to set up such a 
mirror.


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


