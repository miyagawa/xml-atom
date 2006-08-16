use strict;
use FindBin;
use Test::More tests => 3;

use XML::Atom::Feed;

my $f = XML::Atom::Feed->new("$FindBin::Bin/samples/atom-1.0.xml");
is $f->tagline, $f->subtitle;

my $e = ($f->entries)[0];
is $e->modified, $e->updated;
is $e->issued, $e->published;
