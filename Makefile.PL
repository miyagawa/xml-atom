# $Id$

use inc::Module::Install;

name 'XML-Atom';
all_from 'lib/XML/Atom.pm';
auto_set_repository;

requires('MIME::Base64');
requires('URI');
requires('Class::Data::Inheritable');
requires('XML::LibXML', 1.64);

features(
    'Pure perl XML parsing with XML::XPath' => [
        -default => 0,
       'XML::XPath' => 0,
    ],
    'Client/Server for Atom API' => [
        -default => 1,
        LWP => 0,
        'LWP::Authen::Wsse' => 0,
        'Digest::SHA1' => 0,
        'DateTime' => 0,
    ],
    'Feed and API Auto-discovery' => [
        -default => 1,
        'HTML::Parser' => 0,
    ],
);

auto_include();

&WriteAll;
