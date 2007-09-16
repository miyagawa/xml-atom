use strict;
use Test::More 'no_plan';
use FindBin;
use XML::Atom::Feed;

my $feed = XML::Atom::Feed->new(Version => 1.0);
$feed->version; # 1.0
$feed->title("Dicion\xc3\xa1rios");
is $feed->title, "Dicion\xc3\xa1rios";

my $out = "$FindBin::Bin/utf8-create.xml";
open my $fh, ">", $out;
print $fh $feed->as_xml_utf8;
close $fh;

$feed = XML::Atom::Feed->new($out);
is $feed->title, "Dicion\xc3\xa1rios";

END { unlink $out if -e $out }
