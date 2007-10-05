use strict;
use warnings;
use Test::More;

BEGIN {
    unless (eval { require DateTime }) {
        plan skip_all => 'DateTime is required for tests';
    }
}

plan tests => 1;
use XML::Atom::Client;

my $foo;
no warnings 'redefine';
my $orig = LWP::UserAgent::AtomClient->can('DESTROY');
*LWP::UserAgent::AtomClient::DESTROY = sub { $orig->(@_); $foo = 1 };

{
    my $client = XML::Atom::Client->new;
};

ok $foo;
