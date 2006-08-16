# $Id$

use strict;

use Test;
use XML::Atom::Content;

BEGIN { plan tests => 26 };

my $content;

$content = XML::Atom::Content->new;
ok($content->elem);
$content->type('image/jpeg');
ok($content->type, 'image/jpeg');
$content->type('application/gzip');
ok($content->type, 'application/gzip');

$content = XML::Atom::Content->new('This is a test.');
ok($content->body);
ok($content->body, 'This is a test.');
ok($content->mode, 'xml');

$content = XML::Atom::Content->new(Body => 'This is a test.');
ok($content->body);
ok($content->body, 'This is a test.');
ok($content->mode, 'xml');

$content = XML::Atom::Content->new(Body => 'This is a test.', Type => 'foo/bar');
ok($content->body);
ok($content->body, 'This is a test.');
ok($content->mode, 'xml');
ok($content->type, 'foo/bar');

$content = XML::Atom::Content->new;
$content->body('This is a test.');
ok($content->body, 'This is a test.');
ok($content->mode, 'xml');
$content->type('foo/bar');
ok($content->type, 'foo/bar');

$content = XML::Atom::Content->new;
$content->body('<p>This is a test with XHTML.</p>');
ok($content->body, '<p>This is a test with XHTML.</p>');
ok($content->mode, 'xml');

$content = XML::Atom::Content->new;
$content->body('<p>This is a test with invalid XHTML.');
ok($content->body, '<p>This is a test with invalid XHTML.');
ok($content->mode, 'escaped');

$content = XML::Atom::Content->new;
$content->body("This is a test that should use base64\x7f.");
$content->type('text/plain');
ok($content->mode, 'base64');
ok($content->body, "This is a test that should use base64\x7f.");

$content = XML::Atom::Content->new;
$content->body("My name is \xe5\xae\xae\xe5\xb7\x9d.");
ok($content->mode, 'xml');
ok($content->body, "My name is \xe5\xae\xae\xe5\xb7\x9d.");

$content = XML::Atom::Content->new;
$content->type('text/plain');
eval { $content->body("Non-printable: " . chr(578)) };
ok($content->mode, 'base64');
ok($content->body, "Non-printable: " . chr(578));
