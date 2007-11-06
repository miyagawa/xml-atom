# $Id$

use strict;
use FindBin;
use Test::More tests => 16;

use XML::Atom::Feed;

my $foo = XML::Atom::Ext::Foo->new;
isa_ok $foo, 'XML::Atom::Ext::Foo';
$foo->bar(1);
is $foo->bar, 1;
like $foo->as_xml, qr/<foo xmlns="http:\/\/www.example.com\/ns\/">/;
like $foo->as_xml, qr/<bar(?: xmlns="http:\/\/www.example.com\/ns\/")?>1<\/bar>/;

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

{
    my $elem = XML::Atom::Ext::WithNS->new;
    isa_ok $elem, 'XML::Atom::Ext::WithNS';
    $elem->baz(1);
    is $elem->baz, 1;
    like $elem->as_xml, qr{<withns:with_ns.+xmlns:withns="http://example.com/withns/"};

    $feed->add_with_ns( $elem );
    like $feed->as_xml, qr{<withns:with_ns.+xmlns:withns="http://example.com/withns/"};
}

{
    my $feed = XML::Atom::Feed->new( \'<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://purl.org/atom/ns#">
  <withns:with_ns xmlns:withns="http://example.com/withns/" baz="1"/>
</feed>' );

    my( @elems ) = $feed->with_ns;
    is scalar @elems, 1;
    isa_ok $elems[ 0 ], 'XML::Atom::Ext::WithNS';
    is $elems[ 0 ]->baz, 1 ;
}

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


package XML::Atom::Ext::WithNS;

use strict;
use warnings;

use base qw( XML::Atom::Base );

BEGIN {
    __PACKAGE__->mk_attr_accessors( 'baz' );
    XML::Atom::Feed->mk_object_list_accessor( with_ns => __PACKAGE__ );
}

sub element_name { return 'with_ns' }

sub element_ns {
    return XML::Atom::Namespace->new( "withns" => q{http://example.com/withns/} );
}

