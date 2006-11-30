use strict;
use warnings;
use XML::Atom::Client;
use Test::More tests => 1;

my $foo;
no warnings 'redefine';
my $orig = LWP::UserAgent::AtomClient->can('DESTROY');
*LWP::UserAgent::AtomClient::DESTROY = sub { $orig->(@_); $foo = 1 };

{
    my $client = XML::Atom::Client->new;
};

ok $foo;
