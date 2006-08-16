# $Id$
use strict;
use XML::Atom;
use XML::Atom::Feed;
use XML::Atom::Link;
use Test::More tests => 9;

my $feed = XML::Atom::Feed->new(Version => 1.0);
$feed->title("foo bar");

my $link = XML::Atom::Link->new(Version => 1.0);
   $link->href("http://www.example.com/");

my $entry = XML::Atom::Entry->new(Version => 1.0);
   $entry->title("Foo Bar");
   $entry->content("foo bar");

$feed->add_link($link);
$feed->add_entry($entry);

like $feed->as_xml, qr!<feed xmlns="http://www.w3.org/2005/Atom"!;
unlike $feed->as_xml, qr!mode="xml"!;
like $feed->as_xml, qr!type="xhtml"!;

# usage of DefaultVersion
$XML::Atom::DefaultVersion = 1.0;

$feed = XML::Atom::Feed->new;
$feed->title("foo bar");
$feed->add_link({ href => "http://www.example.com/" });

$entry = XML::Atom::Entry->new( Version => "1.0" );
$entry->title("Foo Bar");
$entry->content("foo bar");

$feed->add_entry($entry);

like $feed->as_xml, qr!<feed xmlns="http://www.w3.org/2005/Atom"!;
unlike $feed->as_xml, qr!mode="xml"!;
like $feed->as_xml, qr!type="xhtml"!;

# parse again
my $xml = $feed->as_xml;
$feed = XML::Atom::Feed->new(Stream => \$xml);
is $feed->version, "1.0";
is $feed->title, "foo bar";
is $feed->link->href, 'http://www.example.com/';

