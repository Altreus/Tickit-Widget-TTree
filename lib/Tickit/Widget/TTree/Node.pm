package Tickit::Widget::TTree::Node;

use utf8;
use strict;
use warnings;

use parent qw/Tickit::Widget::Static/;

sub new {
    my $class = shift;
    my %args = @_;

    my $frame = '';
    if ($args{depth} > 0) {
        my $parent_tail = '| ' x $args{depth};

        my $hook;
        $hook = ' ' if $args{type} eq 'f';
        $hook = '+' if $args{type} eq 'd';
        $hook = '-' if $args{open};

        $frame = $parent_tail . $hook;
    }

    my $text = $frame . $args{name};

    my $self = $class->SUPER::new(
        text => $text,
        valign => 'middle',
        align => 'left',
    );

    @{ $self }{qw/ depth name fullpath open /}
       = @args{qw/ depth name fullpath open /};

    return $self;
}

1;
