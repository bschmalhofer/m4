# $Id$

=head1 NAME

t/regex/002_tokens.t - Test the PGE rules used by Parrot m4

=cut

use strict;
use warnings;
use lib qw( lib ../lib ../../lib m4/lib );

use Parrot::Test tests => 22;
use Parrot::Test::PGE;

# Tests for PGE
my %regex = ( word     => q{^<[_a..zA..Z]><[_a..zA..Z0..9]>*},
              string   => q{^\\`<-[`]>*\\'},
              simple   => q{^<-[`#_a..zA..Z]>}, 
              comment  => q{^\#\N*\n}, 
            );
foreach my $target ( qw{ foo Korrekturfluid _Gebietsverkaufsleiter a1 b2_c3_ } )
{
  p6rule_is( $target, $regex{word}, "q{$target} is a word" );
}
foreach my $target ( qw{ 1a +a1 }, "  with_leading_space" )
{
  p6rule_isnt( $target, $regex{word}, "q{$target} is not a word" );
}

foreach my $target ( qw{ `Korrekturfluid' `' } )
{
  p6rule_is( $target, $regex{string}, "q{$target} is a quoted string" );
}
foreach my $target ( qw{ 1a +a1 `asdf asdf' } )
{
  p6rule_isnt( $target, $regex{string}, "q{$target} is not a quoted string" );
}

foreach my $target ( "+# asdf", "'", '123', '0' )
{
  p6rule_is( $target, $regex{simple}, "q{$target} is passed through" );
}
foreach my $target ( "# asdf\n", '_x' )
{
  p6rule_isnt( $target, $regex{simple}, "q{$target} is not passed through" );
}

foreach my $target ( "# asdf\n" )
{
  p6rule_is( $target, $regex{comment}, "q{$target} is a comment" );
}
foreach my $target ( " # asdf\n" )
{
  p6rule_isnt( $target, $regex{comment}, "q{$target} is not a comment" );
}
