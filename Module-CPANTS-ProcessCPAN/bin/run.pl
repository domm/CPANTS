#!/usr/bin/perl
use strict;
use warnings;

use Sys::Hostname;
use FindBin;

my $force='';
$force=' --force' if $ARGV[0] && $ARGV[0] =~/force/;

my $perl=$^X;
my $hostname=hostname();
my $path=$FindBin::Bin;
my $lib=$path."/../lib";
my ($cpan,$lint,$site,$yaml);

if ($hostname =~/hexten/) {
    $cpan='/home2/no-backup/CPAN/cpan.hexten.net/htdocs/';
    $lint='/home/domm/Module-CPANTS-Analyse/bin/cpants_lint.pl';
    $site='/home/domm/Module-CPANTS-Site/';
    $yaml='/home/domm/Module-CPANTS-ProcessCPAN/yaml/';

    $ENV{CPANTS_USER}='cpants';
    unless ($ENV{CPANTS_PWD}) {
        open(my $fh,'/home/domm/cpants_pwd') || die "Cannot read cpants pwd from /home/domm/cpants_pwd: $!";
        my $pwd=<$fh>;
        close $fh;
        chomp($pwd);
        $ENV{CPANTS_PWD}=$pwd;
    }
    
} else {
    $cpan='/home/minicpan';
    $lint='/home/domm/perl/cpants/Module-CPANTS-Analyse/bin/cpants_lint.pl';
    $site='/home/domm/perl/cpants/Module-CPANTS-Site/';
    $yaml='/home/domm/perl/cpants/Module-CPANTS-ProcessCPAN/yaml/';
}

my $yaml_in=$yaml.'in/';
my $yaml_out=$yaml.'out/';
system("$perl -I$lib $path/analyse_cpan.pl --cpan $cpan --lint $lint --dir $yaml_in $force");
# TODO
# take each yaml file, stuff it in DB, move it to $yaml_out
system($perl,"-I$lib", $path."/run_complex_db_stuff.pl",$cpan);
system($perl,"-I$lib", $path."/update_authors.pl",$cpan);
system($perl,"-I$lib", $path."/make_graphs.pl",$site."root/static/");
system($perl,"-I$lib", $path."/make_distgraph.pl",$site."root/static/graphs");
system($perl,"-I$lib", $path."/dump_sqlite.pl",$site."root/static/sqlite");


