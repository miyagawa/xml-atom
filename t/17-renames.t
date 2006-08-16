use strict;
use FindBin;
use Test::More tests => 5;

use XML::Atom::Feed;

my $f = XML::Atom::Feed->new("$FindBin::Bin/samples/atom-1.0.xml");
is $f->tagline, $f->subtitle;

my $e = ($f->entries)[0];
is $e->modified, $e->updated, $e->modified;
is $e->issued, $e->published, $e->issued;

# create
$f = XML::Atom::Feed->new;
$f->title("foo bar");
$f->tagline("Hello");

is $f->tagline, "Hello";
is $f->subtitle, "Hello";
