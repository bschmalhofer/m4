# $Id$

use strict;
use warnings;
use lib qw( lib ../lib ../../lib m4/lib );

use Parrot::Test tests => 1;

# STDERR is not buffered.
# The arguments of errprint are seperated by ' ' when printed
{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'errprint with three args' );
before errprint(   `Should',     `be', `printed on STDERR') after
CODE
before Should be printed on STDERR after
OUT
}
