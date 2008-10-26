# $Id$

use strict;

use t::TestLib;
use Test::More;
use XML::Atom;
use XML::Atom::Entry;
use XML::Atom::Person;

unless ( xmllib_support_encoding('euc-jp') ){
    plan skip_all => 'euc-jp is not supported on your XML library';
}

plan tests => 71;

my $entry;

$entry = XML::Atom::Entry->new;
$entry->title('Foo Bar');
is $entry->title, 'Foo Bar';

$entry = XML::Atom::Entry->new('t/samples/entry-ns.xml');
isa_ok $entry, 'XML::Atom::Entry';
is $entry->title, 'Unit Test 1';

$entry = XML::Atom::Entry->new(Stream => 't/samples/entry-ns.xml');
is $entry->title, 'Unit Test 1';
my $body = $entry->content->body;
ok $body;
like $body, qr/^<img src="foo.gif" align="left"/;
like $body, qr/This is what you get when you do unit testing\./;

$entry = XML::Atom::Entry->new(Stream => 't/samples/entry-full.xml');
is $entry->title, 'Guest Author';
is $entry->id, 'tag:typepad.com:post:75207';
is $entry->issued, '2003-07-21T02:47:34-07:00';
is $entry->modified, '2003-08-22T18:36:57-07:00';
is $entry->created, '2003-07-21T02:47:34-07:00';
is $entry->summary, 'No, Ben isn\'t updating. It\'s me testing out guest author functionality....';
isa_ok $entry->author, 'XML::Atom::Person';
is $entry->author->name, 'Mena';
$entry->author->name('Ben');
is $entry->author->url, 'http://mena.typepad.com/';
my $dc = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
is $entry->get($dc->subject), 'Food';
my @subj = $entry->getlist($dc->subject);
is scalar(@subj), 2;
is $subj[0], 'Food';
is $subj[1], 'Cats';
isa_ok $entry->content, 'XML::Atom::Content';
is $entry->content->body, '<p>No, Ben isn\'t updating. It\'s me testing out guest author functionality.</p>';

my @link = $entry->link;
is scalar(@link), 2;
is $link[0]->rel, 'alternate';
is $link[0]->type, 'text/html';
is $link[0]->href, 'http://ben.stupidfool.org/typepad/2003/07/guest_author.html';
is $link[1]->rel, 'service.edit';
is $link[1]->type, 'application/x.atom+xml';
is $link[1]->href, 'http://www.example.com/atom/entry_id=75207';
is $link[1]->title, 'Edit';

my @links = $entry->links;
is scalar(@links), 2;
is $links[0]->rel, 'alternate';


my $link = $entry->link;
isa_ok $link, 'XML::Atom::Link';
is $link->rel, 'alternate';
is $link->type, 'text/html';
is $link->href, 'http://ben.stupidfool.org/typepad/2003/07/guest_author.html';

$link = XML::Atom::Link->new;
$link->title('Number Three');
$link->rel('service.post');
$link->href('http://www.example.com/atom');
$link->type('application/x.atom+xml');

$entry->add_link($link);
@link = $entry->link;
is scalar(@link), 3;
is $link[2]->rel, 'service.post';
is $link[2]->type, 'application/x.atom+xml';
is $link[2]->href, 'http://www.example.com/atom';
is $link[2]->title, 'Number Three';

## xxx test setting/getting different content encodings
## xxx encodings
## xxx Doc param

$entry->title('Foo Bar');
is $entry->title, 'Foo Bar';
$entry->set($dc->subject, 'Food & Drink');
is $entry->get($dc->subject), 'Food & Drink';

ok(my $xml = $entry->as_xml);

my $entry2 = XML::Atom::Entry->new(Stream => \$xml);
isa_ok $entry2, 'XML::Atom::Entry';
is $entry2->title, 'Foo Bar';
is $entry2->author->name, 'Ben';
is $entry2->get($dc->subject), 'Food & Drink';
isa_ok $entry2->content, 'XML::Atom::Content';
is $entry2->content->body, '<p>No, Ben isn\'t updating. It\'s me testing out guest author functionality.</p>';

my $entry3 = XML::Atom::Entry->new;
my $author = XML::Atom::Person->new;
$author->name('Melody');
is $author->name, 'Melody';
$author->email('melody@nelson.com');
$author->url('http://www.melodynelson.com/');
$entry3->title('Histoire');
ok !$entry3->author;
$entry3->author($author);
isa_ok $entry3->author, 'XML::Atom::Person';
is $entry3->author->name, 'Melody';

$entry = XML::Atom::Entry->new;
$entry->content('<p>Not well-formed.');
is $entry->content->mode, 'escaped';
is $entry->content->body, '<p>Not well-formed.';

$entry = XML::Atom::Entry->new( Stream => \$entry->as_xml );
is $entry->content->mode, 'escaped';
is $entry->content->body, '<p>Not well-formed.';

$entry = XML::Atom::Entry->new;
$entry->content("This is a test that should use base64\0.");
$entry->content->type('image/gif');
is $entry->content->mode, 'base64';
is $entry->content->body, "This is a test that should use base64\0.";
is $entry->content->type, 'image/gif';

$entry = XML::Atom::Entry->new( Stream => \$entry->as_xml );
is $entry->content->mode, 'base64';
is $entry->content->body, "This is a test that should use base64\0.";
is $entry->content->type, 'image/gif';

my $ns = XML::Atom::Namespace->new(list => "http://www.sixapart.com/atom/list#");
$link->set($ns, type => "Books");
$entry->add_link($link);
$xml = $entry->as_xml;
like $xml, qr/list:type="Books"/;

$entry->set($dc, "subject" => "Weblog");

like $entry->as_xml, qr/<dc:subject .*>Weblog<\/dc:subject>/;

$entry->add($dc, "subject" => "Tech");
like $entry->as_xml, qr/<dc:subject .*>Weblog<\/dc:subject>/;
like $entry->as_xml, qr/<dc:subject .*>Tech<\/dc:subject>/;

# re-set
$entry->set($dc, "subject" => "Weblog");
like $entry->as_xml, qr/<dc:subject .*>Weblog<\/dc:subject>/;

# euc-jp feed
SKIP: {
skip "Skipping UTF-8 tests since it depends on libxml", 2;
$entry = XML::Atom::Entry->new('t/samples/entry-euc.xml');
is $entry->title, 'ゲストオーサー';
is $entry->content->body, '<p>日本語のフィード</p>';
}
