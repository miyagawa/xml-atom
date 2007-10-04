# $Id$

use inc::Module::Install;

name('XML-Atom');
abstract('Atom API and Feed Support');
author('Benjamin Trott <cpan@stupidfool.org>');
version_from('lib/XML/Atom.pm');
license('perl');
no_index(directory => 't');
sign(0);

include('ExtUtils::AutoInstall');

requires('MIME::Base64');
requires('URI');
requires('Class::Data::Inheritable');
requires('XML::LibXML', 1.64);

features(
    'Pure perl XML parsing with XML::XPath' => [
        -default => 0,
        recommends('XML::XPath'),
    ],
    'Client/Server for Atom API' => [
        -default => 1,
        recommends('LWP'),
        recommends('LWP::Authen::Wsse'),
        recommends('Digest::SHA1'),
        recommends('DateTime'),
    ],

    'Feed and API Auto-discovery' => [
        -default => 1,
        recommends('HTML::Parser'),
    ],
);

auto_include();
auto_install();

&WriteAll;
