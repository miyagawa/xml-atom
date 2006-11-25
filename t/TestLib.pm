package t::TestLib;
use strict;
use base qw( Exporter );

our @EXPORT = qw( xmllib_support_encoding );
use XML::Atom;

sub xmllib_support_encoding {
    my $enc = shift;

    my $xml = qq(<?xml version="1.0" encoding="$enc"?>\n<foo />);
    if (LIBXML) {
        eval { XML::LibXML->new->parse_string($xml) };
        return $@ ? 0 : 1;
    } else {
        eval { XML::XPath->new(xml => $xml) };
        return $@ ? 0 : 1;
    }
}

1;
