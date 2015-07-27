#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;


my $r = CGI->new();
print $r->header();
print "<html><body>\n";

# Variables
my $username = 'steve'; # set your MySQL username
my $password = 'stevepass'; # set your MySQL password
my $database = 'stevetest'; # set your MySQL database name
my $server = 'localhost'; # set your server hostname (probably localhost)
my $bucketname = 'shopptest2:'; # S3 Bucket name ALWAYS ADD COLON AT THE END!

# Get the rows from database
my $dbh = DBI->connect("DBI:mysql:$database;host=$server", $username, $password)
    || die "Could not connect to database: $DBI::errstr";
my $sth = $dbh->prepare('select id,value from `wp_shopp_meta` where `name` like \'original\'')
    || die "$DBI::errstr";
$sth->execute();


if ($sth->rows < 0) {
    print "<p>Sorry, no results found.</p>";
} else {
    printf ">><p> Found %d rows:</p></p>", $sth->rows;
    # Loop if results found

	my $sql = "update `wp_shopp_meta` set value = ? where id= ?";
	my $update = $dbh->prepare($sql);

    while (my $results = $sth->fetchrow_hashref) {
        my $id = $results->{id}; # get the ID field
        my $value = $results->{value}; # get the value field
        printf "<p>%s</p>", $value;
	
	$results->{value} =~ s/9:"FSStorage";s:3:"uri";s:(\d+):"/8:"AmazonS3";s:3:"uri";s:XXX:"$bucketname/;
	my $n = $1 + length($bucketname);
	$results->{value} =~ s/XXX/$n/;

        printf "<p>SQL UPDATE: update `wp_shopp_meta` set value ='%s' where id=%s</p>", $results->{value}, $results->{id};
	
	# Execute the update for this id,value combination
	# uncomment next 3 lines to make the update live
	# $update->bind_param(1,$results->{value});
	# $update->bind_param(2,$results->{id});
	# $update->execute();
    }
}

# Disconnect
$sth->finish;
$dbh->disconnect;

print "</body></html>\n";
