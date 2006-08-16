# $Id$

package XML::Atom::Thing;
use strict;
use base qw( XML::Atom::Base );

use XML::Atom;
use base qw( XML::Atom::ErrorHandler );
use XML::Atom::Util qw( first nodelist childlist remove_default_ns create_element );
use XML::Atom::Link;
use LWP::UserAgent;
BEGIN {
    if (LIBXML) {
        *init = \&init_libxml;
    } else {
        *init = \&init_xpath;
    }
}

sub init_libxml {
    my $atom = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    if (my $stream = delete $param{Stream}) {
        my $parser = XML::LibXML->new;
        my $doc;
        if (ref($stream) eq 'SCALAR') {
            $doc = $parser->parse_string($$stream);
        } elsif (ref($stream)) {
            $doc = $parser->parse_fh($stream);
        } else {
            $doc = $parser->parse_file($stream);
        }
        $param{Elem} = $doc->getDocumentElement;
    } elsif (my $doc = delete $param{Doc}) {
        $param{Elem} = $doc->getDocumentElement;
    }
    $atom->SUPER::init(%param);
    $atom->fixup_ns;
    return $atom;
}

sub fixup_ns {
    my $obj = shift;
    $obj->{ns} = $obj->elem->namespaceURI;
}

sub init_xpath {
    my $atom = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    my $elem_name = $atom->element_name;
    if (my $stream = delete $param{Stream}) {
        my $xp;
        if (ref($stream) eq 'SCALAR') {
            $xp = XML::XPath->new(xml => $$stream);
        } elsif (ref($stream)) {
            $xp = XML::XPath->new(ioref => $stream);
        } else {
            $xp = XML::XPath->new(filename => $stream);
        }
        my $set = $xp->find('/' . $elem_name);
        unless ($set && $set->size) {
            $set = $xp->find('/');
        }
        $param{Elem} = ($set->get_nodelist)[0];
    } elsif (my $doc = delete $param{Doc}) {
        $param{Elem} = $doc;
    } elsif (my $elem = $param{Elem}) {
        my $xp = XML::XPath->new(context => $elem);
        my $set = $xp->find('/' . $elem_name);
        unless ($set && $set->size) {
            $set = $xp->find('/');
        }
        $param{Elem} = ($set->get_nodelist)[0];
    }
    $atom->SUPER::init(%param);
    $atom;
}

sub set {
    my $atom = shift;
    my($ns, $name, $val, $attr, $add) = @_;
    if (ref($val) =~ /Element$/) {
        $atom->elem->appendChild($val);
        return $val;
    } else {
        return $atom->SUPER::set(@_);
    }
}

sub add_link {
    my $thing = shift;
    my($link) = @_;
    my $elem = ref $link eq 'XML::Atom::Link' ?
            $link->elem :
            create_element($thing->ns, 'link');
    $thing->elem->appendChild($elem);
    if (ref($link) eq 'HASH') {
        for my $k (qw( type rel href title )) {
            my $v = $link->{$k} or next;
            $elem->setAttribute($k, $v);
        }
    }
}

sub link {
    my $thing = shift;
    if (wantarray) {
        my @res = childlist($thing->elem, $thing->ns, 'link');
        my @links;
        for my $elem (@res) {
            push @links, XML::Atom::Link->new(Elem => $elem);
        }
        return @links;
    } else {
        my $elem = first($thing->elem, $thing->ns, 'link') or return;
        return XML::Atom::Link->new(Elem => $elem);
    }
}

# 0.3 -> 1.0 elements aliasing
sub _rename_elements {
    my($class, $atom03, $atom10) = @_;
    no strict 'refs';
    *{"$class\::$atom03"} = sub {
        my $self = shift;
        if ($self->version eq "1.0") {
            return $self->$atom10(@_);
        }
        @_ > 0 ? $self->set($self->ns, $atom03, @_) : $self->get($self->ns, $atom03);
    };

    *{"$class\::$atom10"} = sub {
        my $self = shift;
        if ($self->version eq "0.3") {
            return $self->$atom03(@_);
        }
        @_ > 0 ? $self->set($self->ns, $atom10, @_) : $self->get($self->ns, $atom10);
    };
}

sub DESTROY { }

use vars qw( $AUTOLOAD );
sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    no strict 'refs';
    *$AUTOLOAD = sub {
        @_ > 1 ? $_[0]->set($_[0]->ns, $var, @_[1..$#_]) : $_[0]->get($_[0]->ns, $var)
    };
    goto &$AUTOLOAD;
}

1;
