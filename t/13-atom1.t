use strict;
use Test::More tests => 20;
use XML::Atom::Feed;

sub is_deeply_method;

my $file = "t/samples/atom-1.0.xml";
open my $fh, $file or die "$file: $!";

my $feed = XML::Atom::Feed->new(Stream => $fh);
isa_ok $feed, 'XML::Atom::Feed';

is $feed->title, 'dive into mark', 'atom:title';
is $feed->version, '1.0', 'atom:version based on namespace';
is $feed->updated, "2005-07-11T12:29:29Z", 'atom:updated';

my @link = $feed->link;
is @link, 2, "2 links";
is_deeply_method $link[0], { rel => 'alternate', type => 'text/html', hreflang => 'en', href => 'http://example.org/' };
is_deeply_method $link[1], { rel => 'self', type => 'application/atom+xml', href => 'http://example.org/feed.atom' };

my @entry = $feed->entries;
is @entry, 1, "1 entry";
my $entry = $entry[0];
is $entry->title, 'Atom draft-07 snapshot';

my @entry_link = $entry->link;
is_deeply_method $entry_link[0], { rel => 'alternate', type => 'text/html', href => 'http://example.org/2005/04/02/atom' };
is_deeply_method $entry_link[1], { rel => 'enclosure', type => 'audio/mpeg', length => 1337, href => 'http://example.org/audio/ph34r_my_podcast.mp3' };

is $entry->author->name, 'Mark Pilgrim';
is $entry->author->uri, 'http://example.org/';
is $entry->author->email, 'f8dy@example.com';

my @contrib = $entry->contributor;
is @contrib, 2, "2 contribs";
is_deeply_method $contrib[0], { name => 'Sam Ruby' };
is_deeply_method $contrib[1], { name => 'Joe Gregorio' };

my $contrib = $entry->contributor;
is $contrib->name, 'Sam Ruby', 'testing scalar context';

is_deeply_method $entry->content, { type => 'xhtml', lang => 'en', base => 'http://diveintomark.org/' };
like $entry->content->body, qr!<p>.*<i>\[Update: The Atom draft is finished.\]</i>.*</p>!s;

sub is_deeply_method {
    my($thing, $hashref, $msg) = @_;
    my %copy = map { $_ => $thing->$_ } keys %$hashref;
    is_deeply \%copy, $hashref, $msg;
}
