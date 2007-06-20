package XML::Atom::Ext::Test;

use base qw( XML::Atom::Base );

XML::Atom::Feed->mk_elem_accessors(qw(totalResults startIndex itemsPerPage),
    [ element_ns() ]
);

XML::Atom::Feed->mk_object_list_accessor( ext_link => 'XML::Atom::Ext::Test::Link' );
#XML::Atom::Feed->mk_object_accessor( Query => 'XML::Atom::Ext::::Query' );

sub element_ns {
    return XML::Atom::Namespace->new("testext" => q{http://test.com/-/spec/test/0.1/} );
}

1;

package XML::Atom::Ext::Test::Link;

use base qw( XML::Atom::Base );

__PACKAGE__->mk_attr_accessors( qw( href hreflang rel type ) );

sub element_name {
    return 'link'
}

sub element_ns {
    return XML::Atom::Ext::Test->element_ns;
}

1;

package main;

use strict;
use warnings;

use XML::Atom::Feed;
use Test::More tests => 8;

my $feed = XML::Atom::Feed->new;

my $link = XML::Atom::Link->new;
    $link->href(q{http://www.legacy_link.com});
    $feed->add_link($link);

my $ext_link = XML::Atom::Ext::Test::Link->new;
    $ext_link->href(q{http://www.extended_link.org});
    $feed->add_ext_link($ext_link);

ok($ext_link, "creating extension link");

# Test simple accessors
my @accessors = qw( totalResults startIndex itemsPerPage );

for ( @accessors ) {
    $feed->$_( 2 );
}
for ( @accessors ) {
    is($feed->$_, 2, "extension accessors");
}

my $xml = $feed->as_xml;
like( $xml, qr{xmlns:testext="http://test.com/-/spec/test/0.1/"}, "ext namespace");
like( $xml, qr{<testext:link xmlns:testext="http://test.com/-/spec/test/0.1/" href="http://www.extended_link.org"/>}, "ext link match");

like( $xml, qr{<testext:startIndex xmlns:testext="http://test.com/-/spec/test/0.1/">2</testext:startIndex>}, "ext method match");

like( $xml, qr{<link(?: xmlns="http://purl.org/atom/ns#")? href="http://www.legacy_link.com"/>}, "standard link match");


__END__

=head2 Expected Output

 <?xml version="1.0" encoding="utf-8"?>
 <feed xmlns="http://purl.org/atom/ns#" xmlns:testext="http://test.com/-/spec/test/0.1/">
  <link xmlns="http://purl.org/atom/ns#" href="http://www.legacy_link.com"/>
  <testext:link xmlns:testext="http://test.com/-/spec/test/0.1/" href="http://www.extended_link.org"/>
  <testext:totalResults xmlns:testext="http://test.com/-/spec/test/0.1/">2</testext:totalResults>
  <testext:startIndex xmlns:testext="http://test.com/-/spec/test/0.1/">2</testext:startIndex>
  <testext:itemsPerPage xmlns:testext="http://test.com/-/spec/test/0.1/">2</testext:itemsPerPage>
 </feed>

