package Tickit::Widget::TTree;

use 5.010;
use strict;
use warnings;

use Cwd;
use File::Find;
use Path::Class;
use Data::Dumper;

use parent qw/Tickit::Widget::VBox/;

use Tickit::Widget::TTree::Node;

=head1 NAME

Tickit::Widget::TTree - File browser widget for Tickit

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

 use Tickit;
 use Tickit::Widget::TTree;
 use IO::Async::Loop;

 my $loop = IO::Async::Loop->new;

 my $tickit = Tickit->new;
 $loop->add( $tickit );

 my $widget = Ticket::Widget::TTree->new;
 $tickit->set_root_widget( $widget );

 $tickit->run;

=head1 SUBROUTINES/METHODS

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    my %args = @_;
    $self->{root} = $args{root} // getcwd;
    $self->{opendirs} = { '.' => 1 };

    $args{start_open} //= [];

    $self->{opendirs}->{$_} = 1 for @{ $args{start_open} };
    $self->_cache_nodes;

    return $self;
}

sub window_gained {
    my $self = shift;
 
    $self->add( $_ ) for $self->_get_visible_nodes;
}
#
#sub on_key {
#}

sub _cache_nodes {
    my $self = shift;
    my $root = $self->{root};

    my $nodes = $self->{nodes} || {};
    my $opendirs = $self->{opendirs} || {};

    find sub {
        my $path = dir( $File::Find::name )->relative( $root );

        if (-d $File::Find::name) {
            my $dir = dir( $path );
            my $target = $nodes;

            return if $dir eq '.'; # don't want to see '.' in the list

            for my $d ($dir->dir_list) {
                $target->{dirs}->{$d} //= {};
                $target = $target->{dirs}->{$d};
            }

            $File::Find::prune = 1 unless exists $opendirs->{$path};
        }
        else {
            my $file = file( $path );

            my $target = $nodes;
            my $dir = $file->dir;

            # Files in the root directory appear as {dirs}{.}{$path} if we don't
            # do this
            if ($dir ne '.') {
                for my $d ($dir->dir_list) {
                    $target->{dirs}->{$d} //= {};
                    $target = $target->{dirs}->{$d};
                }
            }

            $target->{files}->{$file->basename} = 1;
        }

    }, $root;

    $self->{nodes} = $nodes;
#die Dumper $nodes;
}

sub _get_visible_nodes {
    my $self = shift;

    return unless my $window = $self->window;

    my $num = $window->lines;
    my @flat = ( Tickit::Widget::TTree::Node->new( 
        depth => 0,
        name => '.', 
        type => 'd',
        path => $self->{root},
        open => exists $self->{opendirs}->{'.'},
    ), $self->_make_widget_list($self->{nodes}) );

    # TODO: store a start offset.
    return grep defined, @flat[0..$num-1];
}

sub _make_widget_list {
    my $self = shift;
    my $node = shift;
    my $path = shift || '.';

    my $parent = dir($path);

    my @flat;

    for my $dir (sort keys %{ $node->{dirs} }) {
        $path = dir( $parent, $dir );
        push @flat, Tickit::Widget::TTree::Node->new( 
            depth => scalar $path->dir_list, 
            name => $dir, 
            type => 'd',
            path => $path,
            open => exists $self->{opendirs}->{$path},
        );
        push @flat, $self->_make_widget_list($node->{dirs}->{$dir}, $path);
    }

    for my $file (sort keys %{ $node->{files} }) {
        $path = dir( $parent, $file );

        push @flat, Tickit::Widget::TTree::Node->new( 
            depth => scalar $path->dir_list, 
            name => $file, 
            type => 'f',
            path => $path,
            open => 0,
        );
    }

    return @flat;
}


=head1 AUTHOR

Altreus, C<< <altreus at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tickit-widget-ttree at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tickit-Widget-TTree>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tickit::Widget::TTree


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tickit-Widget-TTree>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tickit-Widget-TTree>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tickit-Widget-TTree>

=item * Search CPAN

L<http://search.cpan.org/dist/Tickit-Widget-TTree/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Altreus.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Tickit::Widget::TTree
