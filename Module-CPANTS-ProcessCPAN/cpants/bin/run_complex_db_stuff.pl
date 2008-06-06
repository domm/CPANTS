#!/usr/bin/perl
use strict; 
use warnings;
use Module::CPANTS::ProcessCPAN;
use Module::CPANTS::Schema;
use Module::CoreList;
use Parse::CPAN::Authors;
use Getopt::Long;

my %opts;
GetOptions(\%opts,qw(cpan=s));

die "Usage: run_complex_db_stuff.pl --cpan path/to/local/cpan/mirror" unless  $opts{cpan};

my $p=Module::CPANTS::ProcessCPAN->new($opts{cpan});
my $k=Module::CPANTS::Kwalitee->new;
my $available_kw=$k->available_kwalitee;
my @ind=$k->get_indicators;

my $dbh=$p->db->storage->dbh;

# set core modules
print "update CoreList\n";
$p->db->resultset('Modules')->find_or_create({module=>'perl',is_core=>1,dist=>0});
my $core=$Module::CoreList::version{$] *1};
foreach my $mod (keys %$core) {
    my $m=$p->db->resultset('Modules')->find_or_create({module=>$mod});
    $m->is_core(1);
    $m->dist(0) unless $m->dist;
    $m->update;
}

{
    my $sth=$dbh->prepare("select distinct dist from modules where is_core=1");
    $sth->execute;
    while (my $dist=$sth->fetchrow_arrayref) {
        $dbh->do("update dist set is_core=1 where id=?",undef,$dist->[0]);
    }
}

# build list of module->dist
my %modules;
{
    my $sth=$dbh->prepare("select module,dist from modules");
    $sth->execute;
    while (my ($module,$dist)=$sth->fetchrow_array) {
        $modules{$module}=$dist;
    }
}

# build list of dist->id
my %dists;
{
    my $sth=$dbh->prepare("select id,dist from dist");
    $sth->execute;
    while (my ($id,$dist)=$sth->fetchrow_array) {
        $dists{$id}=$dist;
    }
}
# build hash of core dists
my %core_dists;
{
    my $sth=$dbh->prepare("select id from dist where is_core=1");
    $sth->execute;
    while (my ($dist)=$sth->fetchrow_array) {
        $core_dists{$dist}=1;
    }
}

# fill dist references in prereq
{
    print "fill prereq with dist_ids\n";
    my $sth=$dbh->prepare("select distinct requires from prereq where in_dist is null order by requires");
    $sth->execute();
    while (my ($module)=$sth->fetchrow_array) {
        next unless defined $modules{$module};
        $dbh->do("update prereq set in_dist=? where requires=?",undef,$modules{$module},$module);
    }
}

{
    print "fill uses with dist_ids\n";
    my $sth=$dbh->prepare("select distinct module from uses where in_dist is null order by module");
    $sth->execute();
    while (my ($module)=$sth->fetchrow_array) {
        next unless defined $modules{$module};
        $dbh->do("update uses set in_dist=? where module=?",undef,$modules{$module},$module);
    }
}

my %kwalitee_updates;

# is_prereq
{
    print "is_prereq\n";
    my $sth=$dbh->prepare("select dist.id,author from dist,author where dist.author=author.id");
    $sth->execute;
    while (my ($distid,$authid)=$sth->fetchrow_array) {
        my $is_prereq=$dbh->selectrow_array("select count(prereq.id) from prereq,dist,author where prereq.dist=dist.id AND dist.author=author.id AND in_dist=? AND dist.author!=?",undef,$distid,$authid);
        push(@{$kwalitee_updates{$distid}},'is_prereq') if $is_prereq>0;
    }
}


# prereq_matches_use
{
    print "prereq_matches_use\n";
    check_prereq('prereq_matches_use','in_code>0','is_prereq=1 OR is_optional_prereq=1');
}

# prereq_matches_use
{
    print "build_prereq_matches_use\n";
    check_prereq('build_prereq_matches_use',q{in_tests>0 AND module not like 'Test::Pod%'},'(is_prereq=1 OR is_optional_prereq=1 OR is_build_prereq=1)');
}

sub check_prereq {
    my ($type,$uses_sql,$prereq_sql)=@_;

    my %uses;
    my %prereq;
    my $sth_uses=$dbh->prepare("select dist,in_dist,module from uses where module !~ '^v?5' AND $uses_sql");
    $sth_uses->execute;
    while (my ($dist,$in,$module)=$sth_uses->fetchrow_array) {
        if (defined $in) {
            $uses{$dist}->{$in}=$module;
        } else {
            push(@{$uses{$dist}->{not_in_cpants}},$module);
        }
    }
    my $sth_prereq=$dbh->prepare("select distinct dist,in_dist from prereq where in_dist is not null AND ($prereq_sql)");
    $sth_prereq->execute;
    while (my ($dist,$in)=$sth_prereq->fetchrow_array) {
        $prereq{$dist}->{$in}=1;
    }
    
    foreach my $dist (keys %uses) {
        my $used=$uses{$dist} || {};
        my $prereq=$prereq{$dist} || {};
        my @missing;
        foreach my $distid (keys %$used) {
            if ($distid eq 'not_in_cpants') {
                push(@missing,@{$used->{$distid}});
            }
            else {
                push(@missing,$used->{$distid}) unless $prereq->{$distid} || $core_dists{$distid};
            }
        }
        if (@missing) {
            my $error="Undefined prereqs: ".join(', ', @missing);
            $dbh->do("update error set $type=? where id=?",undef,$error,$dist);
        }
        else {
            push(@{$kwalitee_updates{$dist}},$type);
        }
    }

}


# update kwalitee
{
    print "update kwalitee\n";
    while (my ($dist,$rows)=each %kwalitee_updates) {
        $dbh->do("update kwalitee set ".(
            join(', ',map { "$_='1'" } @$rows)
        )." where dist=?",undef,$dist);
    }
}


# calc final kwalitee 
{
    print "calc final kwalitee\n";   
    my $sth=$dbh->prepare("select id,".join(',',map {$_->{name} }@ind)." from kwalitee");
    $sth->execute;

    # TODO replace with accessors from MCK
    my @extra=map {$_->{name}} grep {$_->{is_extra}} @ind;
    my @core=map {$_->{name}} grep {!$_->{is_extra} && !$_->{is_experimental}} @ind;
   
    while (my $r=$sth->fetchrow_hashref) {
        my $id=$r->{id};
        my $core_kw=0;
        foreach (@core) {
            $core_kw++ if $r->{$_};
        }
        my $abs_kw=$core_kw;
        foreach (@extra) {
            $abs_kw++ if $r->{$_};
        }

        my $kw=100*$abs_kw / $available_kw;
        my $rel_core_kw=100*$core_kw / $available_kw;
        $dbh->do("update kwalitee set kwalitee=?,abs_kw=?,abs_core_kw=?,rel_core_kw=? where id=?",undef,$kw,$abs_kw,$core_kw,$rel_core_kw,$id);
    }
}


# fill_authors
{
    print "fill authors\n";
    my $pca = Parse::CPAN::Authors->new($p->cpan_01mailrc);
    foreach my $auth ($pca->authors) {
        my $pauseid=$auth->pauseid;
        my $a=$p->db->resultset('Author')->find_or_create(pauseid=>$pauseid);
        foreach (qw(name email)) {
            $a->$_($auth->$_);
        }
        foreach (qw(average_kwalitee num_dists rank)) {
            $a->$_(0) unless $a->$_;
        }
        $a->update;
    }
}

# AUTHOR: num_dists, average
{
    print "calc authors num_dists and average kwalitee\n";
    my $sth=$dbh->prepare("select count(*) as num_dists,avg(kwalitee.rel_core_kw) as average,avg(kwalitee.kwalitee) as absolute_average,dist.author as id from dist,kwalitee where dist.id=kwalitee.dist group by author");
    $sth->execute;
    while (my @r=$sth->fetchrow_array) {
        $dbh->do("update author set num_dists=?,average_kwalitee=?,average_total_kwalitee=? where id=?",undef,@r);
    }
    $sth->finish;
    $dbh->do("update author set num_dists=0 where num_dists is null");
}

# RANKS
{ 
    print "calc authors rank in cpants game\n";
    foreach my $query ("select average_kwalitee,id from author where num_dists>=5 order by average_kwalitee desc",
    "select average_kwalitee,id from author where num_dists<5 AND num_dists>0 order by average_kwalitee desc")
    {
        my $sth=$dbh->prepare($query);
        $sth->execute;
        my $pos=0;my $cnt=0;my $k=0;
        my @done;
        while (my ($avg,$id)=$sth->fetchrow_array) {
            $cnt++;
            if ($k!=$avg) {
                $k=$avg;
                $pos=$cnt;
            }
            push(@done,[$pos,$id]);
        }
        foreach (@done) {
            $dbh->do("update author set rank=? where id=?",undef,@$_);
        }
    }
}


# 

