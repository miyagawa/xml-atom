use strict;
use Test::More tests => 2;

use XML::Atom::Content;


my $stuff = "\x{1234}";

{
    my $content = XML::Atom::Content->new(Version => 0.3);
    $content->body($stuff);
    isnt $content->mode, 'base64';
}

{
    my $content = XML::Atom::Content->new(Version => 0.3);
    eval { doo(); }; # this set $@
    $content->body($stuff);
    isnt $content->mode, 'base64';
}





