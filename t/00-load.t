#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Kakapo' ) || print "Bail out!\n";
}

diag( "Testing Kakapo $Kakapo::VERSION, Perl $], $^X" );
