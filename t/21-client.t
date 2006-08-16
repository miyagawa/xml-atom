# $Id: 21-client.t,v 1.9 2004/05/08 18:33:46 btrott Exp $

use strict;

use Test::More;
use XML::Atom::Client;
use XML::Atom::Entry;

unless ($ENV{DO_ATOMAPI_TEST}) {
    plan skip_all => "Don't do live Atom test";
}

plan tests => 22;

my $URL = 'http://localhost/cgi-bin/mt/mt-atom.cgi/weblog/blog_id=1';

for my $is_soap (1, 0) {
    my $entry = XML::Atom::Entry->new;
    $entry->title('Unit Test 1');
    $entry->summary('This is what you get');
    $entry->content('When you do unit testing.');

    my $api = XML::Atom::Client->new;
    $api->use_soap($is_soap);
    $api->username('Melody');
    $api->password('0osHZ.scFVmok');

    my $url = $api->createEntry($URL, $entry) or die $api->errstr;
    ok($url);

    my $entry2 = $api->getEntry($url);
    ok($entry2);
    is($entry2->title, 'Unit Test 1');

    my $feed = $api->getFeed($URL);
    ok($feed);
    ok($feed->entries);
    my @entries = $feed->entries;
    ok($entries[0]);
    is($entries[0]->title, $entry2->title);

    $entry->title('Unit Test 2');
    ok($api->updateEntry($url, $entry));

    $entry2 = $api->getEntry($url);
    ok($entry2);
    is($entry2->title, 'Unit Test 2');

    my $ok = $api->deleteEntry($url);
    ok($ok);
}
