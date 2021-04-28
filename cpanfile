requires 'Class::Data::Inheritable';
requires 'DateTime';
requires 'DateTime::TimeZone';
requires 'Digest::SHA';
requires 'LWP::UserAgent';
requires 'MIME::Base64';
requires 'URI';
requires 'XML::LibXML', '2.0202';
requires 'XML::XPath';
requires 'perl', '5.008001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
};
