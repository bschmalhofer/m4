# $Id$

use strict;
use warnings;
use lib qw( lib ../lib ../../lib m4/lib );

use Parrot::Config;
#use Test::More tests => 3; 
use Test::More skip_all => 'infinite loop lurking'; 

my $real_out;
my $parrot_m4 = "cd .. && .$PConfig{slash}parrot$PConfig{exe} languages/m4/m4.pbc";


#--------------------------------------------
$real_out     = `$parrot_m4 --reload-state=languages/m4/examples/only_builtin.frozen languages/m4/examples/hello.m4`; 
is( $real_out, << 'END_OUT', '1 file' );
Hello
END_OUT


#--------------------------------------------
$real_out     = `$parrot_m4 --reload-state=languages/m4/examples/only_builtin.frozen languages/m4/examples/hello.m4 languages/m4/examples/hello.m4`; 
is( $real_out, << 'END_OUT', '2 files' );
Hello
Hello
END_OUT


#--------------------------------------------
$real_out     = `$parrot_m4 --reload-state=languages/m4/examples/only_builtin.frozen languages/m4/examples/hello.m4 languages/m4/examples/hello.m4 languages/m4/examples/hello.m4`; 
is( $real_out, << 'END_OUT', '3 files' );
Hello
Hello
Hello
END_OUT


