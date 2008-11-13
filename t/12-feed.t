# $Id$

use strict;

use Test::More tests => 33;
use XML::Atom::Feed;
use URI;

my $feed;

$feed = XML::Atom::Feed->new('t/samples/feed.xml');
isa_ok $feed, 'XML::Atom::Feed';
is $feed->title, 'dive into atom';
is ref($feed->link), 'XML::Atom::Link';
is $feed->link->href, 'http://diveintomark.org/atom/';
is $feed->version, '0.2';
is $feed->language, 'en';
is $feed->modified, '2003-08-25T11:39:42Z';
is $feed->tagline, '';
is $feed->id, 'tag:diveintomark.org,2003:14';
is $feed->generator, 'http://www.movabletype.org/?v=2.64';
is $feed->copyright, 'Copyright (c) 2003, Atom User';

isa_ok $feed->author, 'XML::Atom::Person';
is $feed->author->name, 'Atom User';
is $feed->author->email, 'atom@example.com';
is $feed->author->homepage, 'http://diveintomark.org/atom/';

$feed->version('0.3');
is $feed->version, '0.3';
$feed->language('fr');
is $feed->language, 'fr';

my @entries = $feed->entries;
is scalar(@entries), 15;
my $entry = $entries[0];
is ref($entry), 'XML::Atom::Entry';
is $entry->title, 'Test';
is $entry->content->body, '<p>Python is cool stuff for ReSTy webapps.</p>';

$entry = XML::Atom::Entry->new;
$entry->title('Foo');
$entry->content('<p>This is a test.</p>');
$feed->add_entry($entry);

@entries = $feed->entries;
is scalar @entries, 16;
my $last = $entries[-1];
is $last->title, 'Foo';
#ok($last->content->body, '<p>This is a test.</p>');

$feed->add_link({ title => 'Number Three', rel => 'service.post',
                  href => 'http://www.example.com/atom',
                  type => 'application/x.atom+xml' });
my @links = $feed->link;
is scalar @links, 2;
is ref($links[-1]), 'XML::Atom::Link';
is $links[-1]->title, 'Number Three';
is $links[-1]->rel, 'service.post';
is $links[-1]->href, 'http://www.example.com/atom';
is $links[-1]->type, 'application/x.atom+xml';

# Test we can insert an entry in the front.
$entry = XML::Atom::Entry->new;
$entry->title('Bar');
$entry->content('<p>This is another test.</p>');
$feed->add_entry($entry, { mode => 'insert' });
@entries = $feed->entries;

is scalar @entries, 17;
is $entries[0]->title, 'Bar';
is $feed->title, 'dive into atom';

is $feed->content_type, "application/x.atom+xml";
