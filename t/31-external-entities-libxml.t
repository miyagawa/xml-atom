use strict;
use Test::More;

use XML::Atom::Entry;
use FindBin;
my $filepath = "$FindBin::Bin/samples/entry-ns.xml";

BEGIN {
    unless (eval { require XML::LibXML }) {
        plan skip_all => 'LibXML required for this test';
    }
}
plan tests => 4;

my $xml = <<"EOX";
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE entry [
<!ENTITY ref SYSTEM "file://$filepath">
]>
  <entry xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <title>Guest Author</title>
    <link rel="alternate" type="text/html" href="http://ben.stupidfool.org/typepad/2003/07/guest_author.html" />
    <link rel="service.edit" title="Edit" type="application/x.atom+xml" href="http://www.example.com/atom/entry_id=75207" />
    <id>tag:typepad.com:post:75207</id>
    <issued>2003-07-21T02:47:34-07:00</issued>
    <modified>2003-08-22T18:36:57-07:00</modified>
    <created>2003-07-21T02:47:34-07:00</created>
    <summary>No, Ben isn&apos;t updating. It&apos;s me testing out guest author functionality....</summary>
    <author>
      <name>Mena</name>
      <url>http://mena.typepad.com/</url>
    </author>
    <dc:subject>Food</dc:subject>
    <dc:subject>Cats</dc:subject>
    <content type="text/html" xml:lang="en-us">&ref;
<div xmlns="http://www.w3.org/1999/xhtml"><p>No, Ben isn't updating. It's me testing out guest author functionality.</p></div>
</content>
  </entry>
EOX

## default sane parser
{
    my $entry = XML::Atom::Entry->new(Stream => \$xml);
    is $entry->title, "Guest Author", "got title";
    my $content = $entry->content->body;
    unlike $content, qr/This is what you get when you do unit testing/,
        "ignored entity";
}

## custom parser
{
    my $libxml = XML::LibXML->new;
    my $entry = XML::Atom::Entry->new(Stream => \$xml, Parser => $libxml);
    is $entry->title, "Guest Author", "got title";
    my $content = $entry->content->body;
    like $content, qr/This is what you get when you do unit testing/,
        "resolved entity";
}
