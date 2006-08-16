# $Id: 22-autodiscovery.t,v 1.2 2003/12/30 07:38:47 btrott Exp $

use strict;

use XML::Atom::Feed;
use URI;
use HTML::TokeParser;
use LWP::UserAgent;

my $index = 'http://diveintomark.org/tests/client/autodiscovery/';

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $index);
my $res = $ua->request($req);
die "$index: ", $res->status_line unless $res->is_success;

my $p = HTML::TokeParser->new(\$res->content);
my $in_list = 0;
my @tests;
while (my $token = $p->get_token) {
    $in_list++, next if $token->[0] eq 'S' && $token->[1] eq 'ol';
    $in_list--, next if $token->[0] eq 'E' && $token->[1] eq 'ol';
    next unless $in_list && $token->[0] eq 'S' && $token->[1] eq 'a';
    push @tests, URI->new_abs($token->[2]{href}, $index)->as_string;
}

require Test::More;
Test::More->import(tests => @tests * 4);
for my $uri (@tests) {
    my @feeds = XML::Atom::Feed->find_feeds($uri);
    ok(scalar @feeds, "$uri has feeds");
    is(scalar @feeds, 1, "$uri has only 1 feed");
    my $feed = XML::Atom::Feed->new(URI->new($feeds[0]));
    ok($feed, "$uri has a valid feed");
    my $backlink;
    for my $link ($feed->link) {
        $backlink = $link->href if $link->rel eq 'alternate';
    }
    is($backlink, $uri, "$uri retrieved correct feed");
}
