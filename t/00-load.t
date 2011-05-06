#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Tickit::Widget::TTree' ) || print "Bail out!\n";
}

diag( "Testing Tickit::Widget::TTree $Tickit::Widget::TTree::VERSION, Perl $], $^X" );
