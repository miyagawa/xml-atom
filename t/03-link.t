# $Id: 03-link.t,v 1.4 2004/05/09 10:49:02 btrott Exp $

use strict;

use Test;
use XML::Atom::Link;

BEGIN { plan tests => 13 };

my $link;

$link = XML::Atom::Link->new;
ok($link);
ok($link->elem);

$link->title('This is a test.');
ok($link->title, 'This is a test.');
$link->title('Different title.');
ok($link->title, 'Different title.');
$link->title('This is a test.');

$link->rel('alternate');
ok($link->rel, 'alternate');

$link->href('http://www.example.com/');
ok($link->href, 'http://www.example.com/');

$link->type('text/html');
ok($link->type, 'text/html');

my $xml = $link->as_xml;
ok($xml =~ /^<\?xml version="1.0" encoding="utf-8"\?>/);
ok($xml =~ m!<link xmlns="http://purl.org/atom/ns#"!);
ok($xml =~ /title="This is a test."/);
ok($xml =~ /rel="alternate"/);
ok($xml =~ m!href="http://www.example.com/"!);
ok($xml =~ m!type="text/html"!);