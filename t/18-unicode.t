# $Id$

use strict;
use encoding "utf-8";

use Test::More 'no_plan';
use XML::Atom;
use XML::Atom::Entry;
use XML::Atom::Person;

$XML::Atom::ForceUnicode = 1;

my $entry;
$entry = XML::Atom::Entry->new('t/samples/entry-utf8.xml');

ok $entry;
ok utf8::is_utf8($entry->title);
ok utf8::is_utf8($entry->summary);
ok utf8::is_utf8($entry->author->name);

is $entry->title, "フーバー";
is $entry->summary, "これはサマリ";
is $entry->author->name, "ミナ";

my $dc = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
my @cat = $entry->getlist($dc, 'subject');
ok utf8::is_utf8($cat[0]);
ok utf8::is_utf8($cat[1]);
is $cat[0], "たべもの";
is $cat[1], "猫";

is $entry->content->type, 'text/html';
ok utf8::is_utf8($entry->content->body);
is $entry->content->body, "<p>これは日本語のポストです。</p>";
