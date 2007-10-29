package Module::CPANTS::ProcessCPAN;
use strict;
use warnings;

use Module::CPANTS::Analyse;
use Module::CPANTS::DB;
use Module::CPANTS::DBHistory;
use Module::CPANTS::Kwalitee;
use Module::CPANTS::ProcessCPAN::ConfigData;
use Data::Dumper;
use base qw(Class::Accessor);
use Carp;
use File::Spec::Functions qw(catdir catfile rel2abs);
use Parse::CPAN::Packages;
use YAML::Syck qw(LoadFile);
use FindBin;
use File::Copy;

use version; our $VERSION=version->new('0.71');

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
        
    my $run=$me->db->resultset('Run')->create({
        mcanalyse_version=>$Module::CPANTS::Analyse::VERSION,
        mcprocess_version=>$Module::CPANTS::ProcessCPAN::VERSION,
        available_kwalitee=>$mck->available_kwalitee,
        total_kwalitee=>$mck->total_kwalitee,
        date=>scalar localtime,
    });
    $me->run($run);
    
    my %for_history=map {$_=>$run->$_} qw(id mcanalyse_version mcprocess_version available_kwalitee total_kwalitee date);
    $me->db_hist->resultset('Run')->create(
        \%for_history    
    );

    return $me;
}

sub process_cpan {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $lint=$me->lint;
    my $analysed=$me->yaml_analysed;
    my $processed=$me->yaml_processed;

    foreach my $dist (sort {$a->dist cmp $b->dist} $p->latest_distributions) {
        my $vname=$dist->distvname;
        next if $vname=~/^perl[-\d]/;
        next if $vname=~/^ponie-/;
        next if $vname=~/^Perl6-Pugs/;
        next if $vname=~/^parrot-/;
        next if $vname=~/^Bundle-/;
        
        if (-e catfile($processed,$vname.'.yml')) {
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
        system("$^X $lint --yaml --to_file --dir $analysed $file");
    }
}

sub process_yaml {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $db=$me->db;
    my $run=$me->run;
    
    my $in_dir=$me->yaml_analysed;
    my $out_dir=$me->yaml_processed;
    
    opendir(my $IN,$in_dir) || die "Cannot open YAML dir $in_dir: $!";
    while (my $file=readdir $IN) {
        next unless $file=~/\.yml$/;
        my $absfile=catfile($in_dir,$file);
        copy($absfile,catfile($out_dir,$file));
        my $data;
        eval { $data=LoadFile($absfile) };
        if ($@) {
            print "Cannot parse YAML $absfile: $@";
            next;
        }

        print $data->{dist}."\n";

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
        foreach (qw(kwalitee modules uses prereq files_array dirs_array author meta_yml)) {
            delete $data->{$_};
        }
        
        my ($db_author,$db_dist);
        
        # save author 
        eval { 
            $db_author=$db->resultset('Author')->find_or_create({pauseid=>$author});
            $me->make_author_history($db_author);
            
            $db_dist=$db_author->add_to_dists({ 
                dist=>$data->{dist},
                run=>$run->id,
            })
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
        };
        if ($@) {
            my $from_cpants='';
            if (my $old=$db_dist->cpants_errors) {
                $from_cpants="$old\n";
            }
            print "$@\n";
            $db_dist->cpants_errors(join('',$from_cpants,"DB: $@"));
            $db_dist->update;
            $kwalitee->{no_cpants_errors}=0;
        }

        eval {
            $kwalitee->{dist}=$db_dist->id;
            $kwalitee->{run}=$run->id;
            $kwalitee->{kwalitee}=0;
            $db->resultset('Kwalitee')->create($kwalitee);
        };
        if ($@) {
            my $e=$@;
            croak $data->{dist}." DB kwalitee error: $e";
        }
        unlink($absfile);
    }

    return;

    # dump old dists
    my @distributions=$p->distributions;
    my %dists=map {$_->dist => 1} grep { $_->dist }   @distributions;

    my $rs=$db->resultset('Dist')->search;
    if ($rs) {
        while (my $in_db=$rs->next) {
            unless ($dists{$in_db->dist}) {
                print $in_db->dist." not on CPAN anymore, deleted from DB\n";
                $in_db->delete;
            }
        }
    }
}

sub make_author_history {
    my $me=shift;
    my $author=shift;
    
    my $dbhist=$me->db_hist;

    $dbhist->resultset('Author')->create({
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
    
    my $old_kw=$dist->kwalitee ? $dist->kwalitee->kwalitee : 0;
    
    $me->db_hist->resultset('Dist')->find_or_create({
        run=>$me->run->id,
        distname=>$dist->dist,
        version=>$dist->version,
        kwalitee=>$old_kw,
    });
    
}

sub db {
    my $me=shift;
    return $me->_db if $me->_db;
   
    my $name = catfile($me->home_dir,qw(sqlite cpants.db));
    return $me->_db(Module::CPANTS::DB->connect('dbi:SQLite:dbname='.$name));
}

sub db_hist {
    my $me=shift;
    return $me->_db_hist if $me->_db_hist;
   
    my $name = catfile($me->home_dir,qw(sqlite cpants_history.db));
    return $me->_db_hist(Module::CPANTS::DBHistory->connect("dbi:SQLite:dbname=$name"));
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


