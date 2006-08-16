# $Id: Makefile.PL,v 1.8 2004/06/01 16:56:28 btrott Exp $

use inc::Module::Install;

name('XML-Atom');
abstract('Atom API and Feed Support');
author('Benjamin Trott <cpan@stupidfool.org>');
version_from('lib/XML/Atom.pm');
license('perl');
no_index(directory => 't');
sign(1);

include('ExtUtils::AutoInstall');

requires('XML::LibXML' => 1.54);
requires('MIME::Base64');
requires('URI');

features(
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

    'Namespace Normalization' => [
        -default => 0,
        recommends('XML::LibXSLT'),
    ],
);

auto_include();
auto_install();

&WriteAll;
