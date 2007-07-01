package Module::CPANTS::ProcessCPAN;
use strict;
use warnings;

use Module::CPANTS::Analyse;
use Module::CPANTS::DB;
use Module::CPANTS::Kwalitee;
use Data::Dumper;
use base qw(Class::Accessor);
use Carp;
use File::Spec::Functions qw(catdir catfile rel2abs);
use Parse::CPAN::Packages;
use YAML;

use vars qw($VERSION);
$VERSION=0.64;

__PACKAGE__->mk_accessors(qw(cpan lint force run prev_run _db process_dir out_dir));

sub new {
    my ($class,$cpan,$lint)=@_;

    my $me=bless {},$class;
    $me->cpan(rel2abs($cpan));
    $me->lint(rel2abs($lint));
    return $me;
}

sub start_run {
    my $me=shift;

    my $mck=Module::CPANTS::Kwalitee->new;
    my $total_kwalitee=scalar @{$mck->get_indicators};
    
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
        version=>$Module::CPANTS::Analyse::VERSION,
        date=>scalar localtime,
        available_kwalitee=>$total_kwalitee,
    });
    $me->run($run);

    
    return $me;
}

sub process_cpan {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $db=$me->db;
    my $lint=$me->lint;
    my $run=$me->run;
    my $process_dir=$me->process_dir;

    foreach my $dist (sort {$a->dist cmp $b->dist} $p->latest_distributions) {
        my $vname=$dist->distvname;
        next if $vname=~/^perl[-\d]/;
        next if $vname=~/^ponie-/;
        next if $vname=~/^Perl6-Pugs/;
        next if $vname=~/^parrot-/;
        next if $vname=~/^Bundle-/;

        my $exists=$db->resultset('Dist')->find({dist=>$dist->dist});
        if ($exists) {
            # check version
            if ($exists->vname && $vname eq $exists->vname) {
                if ($me->force) {
                    print "forced reindex of ".$dist->dist." (".$dist->version." )\n";
                    $me->make_dist_history($exists); 
                    $exists->delete;
                } else {
                    next;
                }
            } else {
                print "new version of ".($dist->dist || '?')." (".($exists->version || '?')." -> ".($dist->version || '?')." )\n";
                $me->make_dist_history($exists); 
                $exists->delete;
            }
        }
        
        print "analyse $vname\n";
        my $file=$me->cpan_path_to_dist($dist->prefix);
        
        # call cpants_lint.pl
        system("$^X $lint --yaml --to_file --dir $process_dir $file") == 0 or die "aborted with SIG $?\n";
    }
}


sub process_cpan_old {
    my $me=shift;
    
    my $p=Parse::CPAN::Packages->new($me->cpan_02packages);
    my $db=$me->db;
    my $lint=$me->lint;
    my $run=$me->run;
     
    foreach my $file ($me->process_dir)
        my $data=LoadFile($file);

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
        $db->txn_begin;
        # save author 
        eval { 
            $db_author=$db->resultset('Author')->find_or_create({pauseid=>$author});
            $me->make_author_history($db_author);
            
            $db_dist=$db_author->add_to_dists({ 
                dist=>$dist->dist,
                run=>$run->id,
            })
        };
        $db->txn_commit;
        print "DB ERROR: cannot create dist: $@" and next if $@; 

        # add data and add stuff to other tables
        $db->txn_begin;
        eval {
            $db_dist->update($data);
            
            foreach my $m (@$modules) {
                $db_dist->add_to_modules($m);
            }
            foreach my $p (@$prereq) {
                $db_dist->add_to_prereq($p);
            }
            foreach my $u (values %$uses) {
                $db_dist->add_to_uses($u);
            }
        };
        if ($@) {
            $db_dist->cpants_errors($db_dist->cpants_errors."\nDB:\n$@");
            $db->txn_rollback;
            $kwalitee->{no_cpants_errors}=0;
        } else {
            $db->txn_commit;
        }

        $db->txn_begin;
        eval {
            $kwalitee->{dist}=$db_dist->id;
            $kwalitee->{run}=$run->id;
            $kwalitee->{kwalitee}=0;
            $db->resultset('Kwalitee')->create($kwalitee);
        };
        if ($@) {
            my $e=$@;
            $db->txn_rollback;
            croak $dist->dist." DB kwalitee error: $e";
        } else {
            $db->txn_commit;
        }
    }

    # dump old dists
    my @distributions=$p->distributions;
    my %dists=map {$_->dist => 1}  @distributions;

    my $rs=$db->resultset('Dist')->search;
    while (my $in_db=$rs->next) {
        unless ($dists{$in_db->dist}) {
            print $in_db->dist." not on CPAN anymore, deleted from DB\n";
            $in_db->delete;
        }
    }
}

sub make_author_history {
    my $me=shift;
    my $author=shift;
    
    my $db=$me->db;

    $db->txn_begin;
    $db->resultset('AuthHist')->create({
        run=>$me->run->id,
        author=>$author->id,
        average_kwalitee=>$author->average_kwalitee || 0,
        num_dists=>$author->num_dists || 0,
        rank=>$author->rank || 0,
    });
    $db->txn_commit;
    
    # set conveniece fields in current author
    $author->prev_av_kw($author->average_kwalitee || 0);
    $author->prev_rank($author->rank|| 0);
    $author->update; 
}

sub make_dist_history {
    my ($me,$dist)=@_;
    
    my $old_kw=$dist->kwalitee ? $dist->kwalitee->kwalitee : 0;
    
    $me->db->resultset('DistHist')->find_or_create({
        run=>$me->run->id,
        distname=>$dist->dist,
        version=>$dist->version,
        kwalitee=>$old_kw,
    });
    
}

sub db {
    my $me=shift;
    return $me->_db if $me->_db;
   
    my $name = $INC{'Test/More.pm'} ? 'test_cpants' : 'cpants';
    return $me->_db(Module::CPANTS::DB->connect('dbi:Pg:dbname='.$name,$ENV{CPANTS_USER},$ENV{CPANTS_PWD}));
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


