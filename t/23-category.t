use strict;
use Test::More 'no_plan';

use XML::Atom::Feed;

my $feed = XML::Atom::Feed->new("t/samples/vox.xml");
my $entry = ($feed->entries)[0];

ok $entry;
is $entry->title, "Pirates of Caribbean - Dead Man's Chest";

my @category = $entry->category;
is @category, 4, 'returns list in a list context';
is $category[0]->term, 'disney';
is $category[0]->scheme, 'http://bulknews.vox.com/tags/disney/';
is $category[0]->label, 'disney';

my $cat = $entry->category;
isa_ok $cat, 'XML::Atom::Category', 'scalar context';
is $cat->term, 'disney';

my @categories = $entry->categories;
is @categories, 4, "moniker";

{
    my $entry = XML::Atom::Entry->new( Version => 1.0 );
    $entry->title("foo bar");
    $entry->add_category({
        term => "foo",
        scheme => "http://example.org/foo#",
        label => "foo bar",
    });

    my @cat = $entry->categories;
    is @cat, 1;
    is $cat[0]->term, "foo";
    is $cat[0]->scheme, "http://example.org/foo#";
    is $cat[0]->label, "foo bar";

    $entry->add_category({
        term => "bar",
        scheme => "http://example.org/bar#",
    });

    @cat = $entry->categories;
    is @cat, 2;
    is $cat[1]->term, "bar";

    my $xml = $entry->as_xml;
    like $xml, qr!<category xmlns="http://www.w3.org/2005/Atom" term="foo" scheme="http://example.org/foo#" label="foo bar"/>!;
    like $xml, qr!<category xmlns="http://www.w3.org/2005/Atom" term="bar" scheme="http://example.org/bar#"/>!;
}

