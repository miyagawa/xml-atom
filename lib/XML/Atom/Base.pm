# $Id$

package XML::Atom::Base;
use strict;
use base qw( XML::Atom::ErrorHandler );

use XML::Atom;
use XML::Atom::Util qw( set_ns first nodelist childlist create_element remove_default_ns );

sub new {
    my $class = shift;
    my $obj = bless {}, $class;
    $obj->init(@_) or return $class->error($obj->errstr);
    $obj;
}

sub init {
    my $obj = shift;
    my %param = @_;
    if (!exists $param{Namespace} and my $ns = $obj->element_ns) {
        $param{Namespace} = $ns;
    }
    $obj->set_ns(\%param);
    my $elem;
    unless ($elem = $param{Elem}) {
        if (LIBXML) {
            my $doc = XML::LibXML::Document->createDocument('1.0', 'utf-8');
            $elem = $doc->createElementNS($obj->ns, $obj->element_name);
            $doc->setDocumentElement($elem);
        } else {
            $elem = XML::XPath::Node::Element->new($obj->element_name);
            my $ns = XML::XPath::Node::Namespace->new('#default' => $obj->ns);
            $elem->appendNamespace($ns);
        }
    }
    $obj->{elem} = $elem;
    $obj;
}

sub element_name { }
sub element_ns { }

sub ns   { $_[0]->{ns} }
sub elem { $_[0]->{elem} }

sub version {
    my $atom = shift;
    XML::Atom::Util::ns_to_version($atom->ns);
}

sub get {
    my $obj = shift;
    my($ns, $name) = @_;
    my @list = $obj->getlist($ns, $name);
    return $list[0];
}

sub getlist {
    my $obj = shift;
    my($ns, $name) = @_;
    my $ns_uri = ref($ns) eq 'XML::Atom::Namespace' ? $ns->{uri} : $ns;
    my @node = nodelist($obj->elem, $ns_uri, $name);
    return map {
        my $val = LIBXML ? $_->textContent : $_->string_value;
        if ($] >= 5.008) {
            require Encode;
            Encode::_utf8_off($val) unless $XML::Atom::ForceUnicode;
        }
        $val;
     } @node;
}

sub add {
    my $obj = shift;
    my($ns, $name, $val, $attr) = @_;
    return $obj->set($ns, $name, $val, $attr, 1);
}

sub set {
    my $obj = shift;
    my($ns, $name, $val, $attr, $add) = @_;
    my $ns_uri = ref $ns eq 'XML::Atom::Namespace' ? $ns->{uri} : $ns;
    my @elem = childlist($obj->elem, $ns_uri, $name);
    if (!$add && @elem) {
        $obj->elem->removeChild($_) for @elem;
    }
    my $elem = create_element($ns, $name);
    if (UNIVERSAL::isa($val, 'XML::Atom::Base')) {
        if (LIBXML) {
            for my $child ($val->elem->childNodes) {
                $elem->appendChild($child->cloneNode(1));
            }
            for my $attr ($val->elem->attributes) {
                next unless ref($attr) eq 'XML::LibXML::Attr';
                $elem->setAttribute($attr->getName, $attr->getValue);
            }
        } else {
            for my $child ($val->elem->getChildNodes) {
                $elem->appendChild($child);
            }
            for my $attr ($val->elem->getAttributes) {
                $elem->appendAttribute($attr);
            }
        }
    } else {
        if (LIBXML) {
            $elem->appendChild(XML::LibXML::Text->new($val));
        } else {
            $elem->appendChild(XML::XPath::Node::Text->new($val));
        }
    }
    $obj->elem->appendChild($elem);
    if ($attr) {
        while (my($k, $v) = each %$attr) {
            $elem->setAttribute($k, $v);
        }
    }
    return $val;
}

sub get_attr {
    my $obj = shift;
    my($attr) = @_;
    my $val = $obj->elem->getAttribute($attr);
    if ($] >= 5.008) {
        require Encode;
        Encode::_utf8_off($val) unless $XML::Atom::ForceUnicode;
    }
    $val;
}

sub set_attr {
    my $obj = shift;
    if (@_ == 2) {
        my($attr, $val) = @_;
        $obj->elem->setAttribute($attr => $val);
    } elsif (@_ == 3) {
        my($ns, $attr, $val) = @_;
        my $attribute = "$ns->{prefix}:$attr";
        if (LIBXML) {
            $obj->elem->setAttributeNS($ns->{uri}, $attribute, $val);
        } else {
            my $ns = XML::XPath::Node::Namespace->new(
                    $ns->{prefix} => $ns->{uri}
                );
            $obj->elem->appendNamespace($ns);
            $obj->elem->setAttribute($attribute => $val);
        }
    }
}

sub get_object {
    my $obj = shift;
    my($ns, $name, $class) = @_;
    my @elem = childlist($obj->elem, $ns, $name) or return;
    my @obj = map { $class->new( Elem => $_, Namespace => $ns ) } @elem;
    return wantarray ? @obj : $obj[0];
}

sub mk_elem_accessors {
    my $class = shift;
    my(@list) = @_;
    no strict 'refs';
    for my $elem (@list) {
        (my $meth = $elem) =~ tr/\-/_/;
        *{"${class}::$meth"} = sub {
            my $obj = shift;
            if (@_) {
                return $obj->set($obj->ns, $elem, $_[0]);
            } else {
                return $obj->get($obj->ns, $elem);
            }
        };
    }
}

sub mk_attr_accessors {
    my $class = shift;
    my(@list) = @_;
    no strict 'refs';
    for my $attr (@list) {
        (my $meth = $attr) =~ tr/\-/_/;
        *{"${class}::$meth"} = sub {
            my $obj = shift;
            if (@_) {
                return $obj->set_attr($attr => $_[0]);
            } else {
                return $obj->get_attr($attr);
            }
        };
    }
}

sub mk_object_accessor {
    my $class = shift;
    my($name, $ext_class) = @_;
    no strict 'refs';
    (my $meth = $name) =~ tr/\-/_/;
    *{"${class}::$meth"} = sub {
        my $obj = shift;
        my $ns_uri = $ext_class->element_ns || $obj->ns;
        if (@_) {
            return $obj->set($ns_uri, $name, $_[0]);
        } else {
            return $obj->get_object($ns_uri, $name, $ext_class);
        }
    };
}

sub as_xml {
    my $obj = shift;
    if (LIBXML) {
        my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
        $doc->setDocumentElement($obj->elem);
        remove_default_ns($obj->elem);
        return $doc->toString(1);
    } else {
        return '<?xml version="1.0" encoding="utf-8"?>' . "\n" .
            $obj->elem->toString;
    }
}

1;
