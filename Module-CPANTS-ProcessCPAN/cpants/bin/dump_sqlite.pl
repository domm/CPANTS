#!/usr/bin/perl
use strict;
use warnings;

use DBD::PgLite::MirrorPgToSQLite qw(pg_to_sqlite);

use File::Spec::Functions;
use Module::CPANTS::Schema;
use Module::CPANTS::Kwalitee;
use Module::CPANTS::ProcessCPAN;
use Module::CPANTS::ProcessCPAN::ConfigData;
my $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');

my $outpath=shift(@ARGV) || catdir($home,'root','static');

my @now=localtime(time);
my $now=sprintf("%02d_%02d_%02d", $now[5] % 100,@now[4, 3]);

my $mcp=bless {},'Module::CPANTS::ProcessCPAN';
my $db=$mcp->db;

my %dumps=(
    all         => [[qw(author kwalitee dist prereq modules uses)],[]],
# kwalitee    => [[qw(tables)][qw(views)]]; 
);

foreach my $name (keys %dumps) {
    my $dbfile  = catfile($outpath,'cpants_'.$name.'_'.$now.'.db');
    my $current = catfile($outpath,'cpants_'.$name.'.db');
    my $tables=$dumps{$name};

    pg_to_sqlite(
        sqlite_file => $dbfile,
        pg_dbh      => $db->storage->dbh,
        tables      => $tables->[0],
        indexes     => 1,
        verbose     => 1,
        cachedir    => 0,
        #snapshot    => 1,
    );

    # compress!
    system("gzip",$dbfile);
    rename($dbfile.'.gz',$current.'.gz');
}

