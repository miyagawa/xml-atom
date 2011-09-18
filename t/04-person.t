# $Id$

use strict;

use Test::More tests => 9;
use XML::Atom::Person;

my $person;

$person = XML::Atom::Person->new;
isa_ok $person, 'XML::Atom::Person';
ok $person->elem;

$person->name('Foo Bar');
is $person->name, 'Foo Bar';
$person->name('Baz Quux');
is $person->name, 'Baz Quux';

$person->email('foo@bar.com');
is $person->email, 'foo@bar.com';

my $xml = $person->as_xml;
like $xml, qr/^<\?xml version="1.0" encoding="UTF-8"\?>/;
like $xml, qr/<author xmlns="http:\/\/purl.org\/atom\/ns#">/;
like $xml, qr/<name(?: xmlns="http:\/\/purl.org\/atom\/ns#")?>Baz Quux<\/name>/;
like $xml, qr/<email(?: xmlns="http:\/\/purl.org\/atom\/ns#")?>foo\@bar.com<\/email>/;
