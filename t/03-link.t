# $Id$

use strict;

use Test::More tests => 14;
use XML::Atom::Link;

my $link;

$link = XML::Atom::Link->new;
isa_ok $link, 'XML::Atom::Link';
ok $link->elem;

$link->title('This is a test.');
is $link->title, 'This is a test.';
$link->title('Different title.');
is $link->title, 'Different title.';
$link->title('This is a test.');

$link->rel('alternate');
is $link->rel, 'alternate';

$link->href('http://www.example.com/');
is $link->href, 'http://www.example.com/';

$link->type('text/html');
is $link->type, 'text/html';

my $xml = $link->as_xml;
like $xml, qr/^<\?xml version="1.0" encoding="utf-8"\?>/;
like $xml, qr/<link xmlns="http:\/\/purl.org\/atom\/ns#"/;
like $xml, qr/title="This is a test."/;
like $xml, qr/rel="alternate"/;
like $xml, qr/href="http:\/\/www.example.com\/"/;
like $xml, qr/type="text\/html"/;

my $ns = XML::Atom::Namespace->new(dc => "http://purl.org/dc/elements/1.1/");
$link->set($ns, "subject" => "blah");
$xml = $link->as_xml;
like $xml, qr/dc:subject="blah"/;
