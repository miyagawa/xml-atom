# $Id: 04-person.t,v 1.1 2004/05/08 13:20:58 btrott Exp $

use strict;

use Test;
use XML::Atom::Person;

BEGIN { plan tests => 9 };

my $person;

$person = XML::Atom::Person->new;
ok($person);
ok($person->elem);

$person->name('Foo Bar');
ok($person->name, 'Foo Bar');
$person->name('Baz Quux');
ok($person->name, 'Baz Quux');

$person->email('foo@bar.com');
ok($person->email, 'foo@bar.com');

my $xml = $person->as_xml;
ok($xml =~ /^<\?xml version="1.0" encoding="utf-8"\?>/);
ok($xml =~ m!<author xmlns="http://purl.org/atom/ns#">!);
ok($xml =~ m!<name xmlns="http://purl.org/atom/ns#">Baz Quux</name>!);
ok($xml =~ m!<email xmlns="http://purl.org/atom/ns#">foo\@bar.com</email>!);
