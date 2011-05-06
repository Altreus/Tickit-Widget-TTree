#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use Tickit;
use Tickit::Widget::TTree;

use IO::Async::Loop;

my $loop = IO::Async::Loop->new;

my $tickit = Tickit->new;

$loop->add( $tickit );

my $rootwidget = Tickit::Widget::TTree->new(
    root => '/usr',
    start_open => ['games', 'lib', 'lib/ConsoleKit'],
);

$tickit->set_root_widget( $rootwidget );

$tickit->run;

