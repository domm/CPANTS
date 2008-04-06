#!/opt/perl5.10/bin/perl -w

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use DBIx::Class::Schema::Loader "make_schema_at", "dump_to_dir";
use Module::CPANTS::ProcessCPAN;
my $p=Module::CPANTS::ProcessCPAN->new();

my $dest = $ARGV[0] || "$FindBin::Bin/../lib/";

print("Creating Database schema in directory <$dest>\n");
make_schema_at(
    "Module::CPANTS::Schema",
    {
        dump_directory     => $dest,
        skip_relationships => 1,
		components         => [qw/InflateColumn PK/],
    },
    [$p->dsn],
);

=head1 NAME

babilu_create_dbic_schema.pl -- create schema from current database

=head1 SYNOPSIS

  ./ babilu_create_dbic_schema.pl --debug --rels --dest=/tmp/lol

    Options: --dest chose the destination directory MUST be used
    if you use rels-- help this output-- debug be verbose
    -- rels analyze relationships between tables
    -- host db hostname( defaults to localhost )

    = cut

    1;

