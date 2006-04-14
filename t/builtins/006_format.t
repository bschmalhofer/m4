# $Id$

use strict;
use warnings;
use lib qw( lib ../lib ../../lib m4/lib );

use Parrot::Test tests => 3;

{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'substring in middle of string' );
format(`012345SUB')
CODE
012345SUB
OUT
}

{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'substring in middle of string' );
format( `The string "%s" is "%d" codepoints long.', `012345', `6')
CODE
The string "012345" is "6" codepoints long.
OUT
}

{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'substring in middle of string' );
format(`Pi is about %3.3f', `3.14')
CODE
Pi is about 3.140
OUT
}
