requires 'Class::Data::Inheritable';
requires 'DateTime';
requires 'DateTime::TimeZone';
requires 'Digest::SHA1';
requires 'LWP::UserAgent';
requires 'MIME::Base64';
requires 'URI';
requires 'XML::LibXML', '1.69';
requires 'XML::XPath';
requires 'perl', '5.008001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
};
