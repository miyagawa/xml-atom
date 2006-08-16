# $Id$
use strict;
use XML::Atom;
use XML::Atom::Feed;
use XML::Atom::Link;
use Test::More tests => 1;

my $feed = XML::Atom::Feed->new(Version => 1.0);
$feed->title("foo bar");

my $link = XML::Atom::Link->new(Version => 1.0);
   $link->href("http://www.example.com/");

my $entry = XML::Atom::Entry->new(Version => 1.0);
   $entry->title("Foo Bar");

$feed->add_link($link);
$feed->add_entry($entry);

like $feed->as_xml, qr!<feed xmlns="http://www.w3.org/2005/Atom">!;




