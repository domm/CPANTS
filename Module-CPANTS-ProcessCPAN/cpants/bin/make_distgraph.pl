#!/usr/bin/perl
use strict;
use warnings;
 
use GD::Graph;
use GD::Graph::linespoints;
use Module::CPANTS::DB;
use Module::CPANTS::Kwalitee;
use Module::CPANTS::ProcessCPAN;
use File::Spec::Functions;

my $home=Module::CPANTS::ProcessCPAN::ConfigData->config('home');
my $outpath=shift(@ARGV) || catdir($home,'root','static','graphs');

my $mck=Module::CPANTS::Kwalitee->new;
my $max_y=int(($mck->total_kwalitee / $mck->available_kwalitee)*100);

my $mcp=bless {},'Module::CPANTS::ProcessCPAN';
my $db=$mcp->db_hist;

my @runs=$db->resultset('Run')->search({},
    {
        order_by=>'date desc',
        rows=>1,
    }
);
my $run=$runs[0];
my $dists=$db->resultset('Module::CPANTS::DBHistory::Dist')->search({run=>$run->id});
my %authors;
print "making distgraphs\n";
while (my $dist=$dists->next) {
    make_distgraph($dist);
    #$authors{$dist->author->id}=$dist->author;
}
exit;
foreach my $author (values %authors) {
    make_authorgraph($author);
}

exit;

sub make_distgraph {
    my ($dist)=@_;   
    
    my $results=$db->resultset('Module::CPANTS::DBHistory::Dist')->search(distname=>$dist->distname);
    
    my $graph=GD::Graph::linespoints->new(800,300);
    $graph->set(
        x_label=>'CPANTS Run (Release of Dist)',
		'y_label'=>'Kwalitee',
		title=>"Kwalitee History for ".$dist->distname,
		'y_max_value'=>$max_y,
        y_min_value=>0,
        x_labels_vertical=>1,
        show_values=>1,
        values_vertical=>1,
        values_space=>-35,
    );
    
    my @date; my @kw;
    while (my $set=$results->next) {
        my $date=substr($set->run->date,0,10) || '?';
        push(@date,"$date (".($set->version || '?').")");
        push(@kw,sprintf("%.2f",$set->kwalitee));
    }
    my $gd=$graph->plot([\@date,\@kw]) || die $graph->error;
    open(IMG, ">",catfile($outpath,$dist->distname.".png")) or die $!;
    binmode IMG;
    print IMG $gd->png;
    print $dist->distname,"\n";
    return;
}

sub make_authorgraph {
    my $author=shift;
    my $results=$db->resultset('Module::CPANTS::DBHistory::Author')->search(author=>$author->id);

    my @date; my @kw; my @dists;
    my $max_dists=0;
    my %seen;   # hack - there seems to be bad data in the DB
    while (my $set=$results->next) {
        next if $seen{$set->run->id}++;
        my $date=substr($set->run->date,0,10) || '?';
        push(@date,$date);
        push(@kw,$set->average_kwalitee);
        my $num_dists=$set->num_dists;
        push(@dists,$num_dists);
        $max_dists=$num_dists if $num_dists>$max_dists; 
    }
    
    print_graph('dists','Number of Dists',$author,\@date,\@dists,$max_dists+1+(int $max_dists*0.1));
    print_graph('kw','Average Kwalitte',$author,\@date,\@kw,$max_y);

    exit;
    return;
}


sub print_graph {
    my ($file,$label,$author,$dates,$data,$max)=@_;
    my $graph=GD::Graph::linespoints->new(800,250);
    $graph->set(
        x_label=>'CPANTS Run',
        title=>$label.' '.$author->pauseid,
        'y_max_value'=>$max,
        'y_min_value'=>0,
        x_labels_vertical=>1,
        values_vertical=>1,
        show_values=>1,
        values_space=>7,
    );

    my $gd=$graph->plot([$dates,$data]) || die $graph->error;
    open(IMG, ">",catfile($outpath,$author->pauseid.'_'.$file.".png")) or die $!;
    binmode IMG;
    print IMG $gd->png;
     
}


