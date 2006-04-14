# $Id$

use strict;
use warnings;
use lib qw( lib ../lib ../../lib m4/lib );

use Parrot::Test tests => 3;

{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'hello' );
`foo'
CODE
foo
OUT
}
{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'hello' );
define(`foo', `Hello World')
define(`furcht', `Hallo Welt')

In German `foo' is furcht.
CODE



In German foo is Hallo Welt.
OUT
}
{
  language_output_is( 'm4', <<'CODE', <<'OUT', 'hello' );
define(`foo', `Hello World')
define(`furcht', `Hallo Welt')
In `German foo is furcht.
another line in a string'
CODE


In German foo is furcht.
another line in a string
OUT
}
