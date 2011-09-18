use strict;
use warnings;
use Test::More;

BEGIN {
    unless (eval { require DateTime } and eval { require DateTime::Format::Atom }) {
        plan skip_all => 'DateTime and DateTime::Format::Atom are required for tests';
    }
}

plan tests => 2;

use XML::Atom::Feed;

my $f = XML::Atom::Feed->new();

my $dt = DateTime->now();

$f->updated($dt);

my $xml = $f->as_xml;
my $dt_string = DateTime::Format::Atom->format_datetime($dt);

like($xml, qr/$dt_string/, "correct format made");
unlike($xml, qr|<modified/>|, "no empty modified elements");
