# $Id$

use strict;

use Test::More tests => 32;
use XML::Atom::Content;

my $content;

$content = XML::Atom::Content->new;
isa_ok $content, 'XML::Atom::Content';
ok $content->elem;
$content->type('image/jpeg');
is $content->type, 'image/jpeg';
$content->type('application/gzip');
is $content->type, 'application/gzip';

$content = XML::Atom::Content->new('This is a test.');
is $content->body, 'This is a test.';
is $content->mode, 'xml';

$content = XML::Atom::Content->new(Body => 'This is a test.');
is $content->body, 'This is a test.';
is $content->mode, 'xml';

$content = XML::Atom::Content->new(Body => 'This is a test.', Type => 'foo/bar');
is $content->body, 'This is a test.';
is $content->mode, 'xml';
is $content->type, 'foo/bar';

$content = XML::Atom::Content->new;
$content->body('This is a test.');
is $content->body, 'This is a test.';
is $content->mode, 'xml';
$content->type('foo/bar');
is $content->type, 'foo/bar';

$content = XML::Atom::Content->new;
$content->body('<p>This is a test with XHTML.</p>');
is $content->body, '<p>This is a test with XHTML.</p>';
is $content->mode, 'xml';

$content = XML::Atom::Content->new;
$content->body('<p>This is a test with invalid XHTML.');
is $content->body, '<p>This is a test with invalid XHTML.';
is $content->mode, 'escaped';

$content = XML::Atom::Content->new;
$content->body("This is a test that should use base64\x7f.");
$content->type('text/plain');
is $content->mode, 'base64';
is $content->body, "This is a test that should use base64\x7f.";

$content = XML::Atom::Content->new;
$content->body("My name is \xe5\xae\xae\xe5\xb7\x9d.");
is $content->mode, 'xml';
is $content->body, "My name is \xe5\xae\xae\xe5\xb7\x9d.";

$content = XML::Atom::Content->new;
$content->type('text/plain');
eval { $content->body("Non-printable: " . chr(578)) };
is $content->mode, 'base64';
is $content->body, un_utf8("Non-printable: " . chr(578));

# 1.0 with xhtml
$content = XML::Atom::Content->new(Version => 1.0);
$content->body("<div>foo bar</div>");

is $content->type, 'xhtml';
is $content->body, "<div>foo bar</div>";

# 1.0 with html
$content = XML::Atom::Content->new(Version => 1.0);
$content->body("<p>foo bar");

is $content->type, 'html';
is $content->body, "<p>foo bar";

# 1.0 as text
$content = XML::Atom::Content->new(Version => 1.0);
$content->body("foo bar");
$content->type('text');

is $content->type, 'text';
is $content->body, "foo bar";

# 1.0 as binary
$content = XML::Atom::Content->new(Version => 1.0);
$content->type('image/jpeg');
$content->body("\xff\xde\xde\xde");

is $content->type, 'image/jpeg';
is $content->body, "\xff\xde\xde\xde";

sub un_utf8 {
    my $foo = shift;
    Encode::_utf8_off($foo);
    $foo;
}
