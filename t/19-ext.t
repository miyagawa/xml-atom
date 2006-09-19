# $Id$

use strict;
use FindBin;
use Test::More tests => 9;

use XML::Atom::Feed;

my $foo = XML::Atom::Ext::Foo->new;
isa_ok $foo, 'XML::Atom::Ext::Foo';
$foo->bar(1);
is $foo->bar, 1;
like $foo->as_xml, qr/<foo xmlns="http:\/\/www.example.com\/ns\/">/;
like $foo->as_xml, qr/<bar xmlns="http:\/\/www.example.com\/ns\/">1<\/bar>/;

my $feed = XML::Atom::Feed->new;
$feed->foo($foo);
my $foo2 = $feed->foo;
isa_ok $foo2, 'XML::Atom::Ext::Foo';
is $foo2->bar, 1;

## Make sure the alternate name works.
$feed->foo2($foo);
$foo2 = $feed->foo2;
isa_ok $foo2, 'XML::Atom::Ext::Foo';
is $foo2->bar, 1;

like $feed->as_xml, qr/<foo xmlns="http:\/\/www.example.com\/ns\/">/;

package XML::Atom::Ext::Foo;
use strict;
use base qw( XML::Atom::Base );

BEGIN {
    __PACKAGE__->mk_elem_accessors('bar');
    XML::Atom::Feed->mk_object_accessor( foo => __PACKAGE__ );
    XML::Atom::Feed->mk_object_accessor( foo2 => __PACKAGE__ );
}

sub element_name { 'foo' }
sub element_ns   { 'http://www.example.com/ns/' }
