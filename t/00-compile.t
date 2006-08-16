# $Id: 00-compile.t,v 1.3 2003/12/24 08:59:16 btrott Exp $

my $loaded;
BEGIN { print "1..1\n" }
use XML::Atom;
use XML::Atom::Entry;
use XML::Atom::Feed;
use XML::Atom::Client;
use XML::Atom::Server;
use XML::Atom::Person;
use XML::Atom::Content;
$loaded++;
print "ok 1\n";
END { print "not ok 1\n" unless $loaded }
