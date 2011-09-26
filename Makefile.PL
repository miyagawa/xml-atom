# $Id$

use inc::Module::Install;
use 5.008;

name 'XML-Atom';
all_from 'lib/XML/Atom.pm';
auto_set_repository;

requires('MIME::Base64');
requires('URI');
requires('Class::Data::Inheritable');
requires('XML::XPath');
requires('LWP::UserAgent');
requires('Digest::SHA1');
requires('DateTime');
requires('DateTime::TimeZone');
requires('XML::LibXML', 1.69);

features(
    'Pure perl XML parsing with XML::XPath' => [
        -default => 0,
       'XML::XPath' => 0,
    ],
    'Client/Server for Atom API' => [
        -default => 1,
        LWP => 0,
        'LWP::Authen::Wsse' => 0,
    ],
    'Feed and API Auto-discovery' => [
        -default => 1,
        'HTML::Parser' => 0,
    ],
);

auto_include();

&WriteAll;
