# $Id$

=head1 NAME

freeze.pir - reading and writing of state files

=head1 DESCRIPTION

Copyright:  2004 Bernhard Schmalhofer.  All Rights Reserved.
SVN Info:   $Id$
History:    Ported from GNU m4 1.4
References: http://www.gnu.org/software/m4/m4.html

Reading and writing state files. Invoced with the command line parameters
'--reload-state' and '--freeze-state'

=cut

# Some named constants
.include 'iterator.pasm'

=head1 SUBROUTINES

=head2 void produce_frozen_state( Hash state, string frozen_file )

Dump a state file.

=cut

.sub produce_frozen_state
  .param pmc        state
  .param string     frozen_file

  .local pmc symtab
  symtab = state['symtab']

  .local pmc       symbol
  .local int       len
  .local string    name
  .local string    text

  .local pmc frozen_fh
  frozen_fh = open frozen_file, 'w'
  .local pmc iterator
  iterator = new 'Iterator', symtab
  iterator = .ITERATE_FROM_START
  iter_loop:
  unless iterator goto END_ITER
    symbol = shift iterator
    name   = symbol['name']
    text   = symbol['text']
    print frozen_fh, 'T'
    len = length name
    print frozen_fh, len
    print frozen_fh, ','
    len = length text
    print frozen_fh, len
    print frozen_fh, "\n"
    print frozen_fh, name
    print frozen_fh, text
    print frozen_fh, "\n"

    branch iter_loop
END_ITER:
  close frozen_fh
.end


=head2 void reload_frozen_state( Hash state, string frozen_file )

Read a frozen file

TODO: Read in long files incrementally
TODO: Support all flags
TODO: Search for files in M4PATH
For now we just read the whole file into a string.
For now we just worry about the flags 'F', 'T' and 'V'.

=cut

.sub reload_frozen_state
  .param pmc        state
  .param string     frozen_file

  # Read the file into the string file
  .local string content
  # TODO: M4PATH
  .local pmc frozen_fh
  frozen_fh = open frozen_file, 'r'
  if frozen_fh goto READ_CONTENT
    printerr "'"
    printerr frozen_file
    printerr "'"
    printerr " not found\n"
    # TODO: proper exception handling
    end
READ_CONTENT:
  content = read frozen_fh, 60000
  close frozen_fh

  # We have read in a file, now let's parse it.
  .local int    pos             # position in file
  .local string token           # interesting substring in file

  # vars which will contain the extracted info
  .local int    name_len
  .local int    substitution_len
  .local string name
  .local string text

  # We need to look up builtin functions
  .local pmc builtin_tab
  builtin_tab = state['builtin_tab']
  .local pmc builtin

  # start the parse loop
  goto CHECK_PARSING_FINISHED

  HANDLE_NEXT_TOKEN:
  if token != '\n' goto NOT_AN_EMPTY_LINE
    # Ignore empty lines
    goto CHECK_PARSING_FINISHED
NOT_AN_EMPTY_LINE:

  if token != '#' goto NOT_A_COMMENT
    # Skip everything up to the end of line
    pos = index content, "\n"
    inc pos
    substr content, 0, pos, ''
    goto CHECK_PARSING_FINISHED
  NOT_A_COMMENT:

  if token != 'V' goto NOT_A_VERSION_SPECIFICICATION
    # Skip everything up to the end of line
    # TODO: verify 'V1' and make some test cases
    # TODO: Add version info to symtab
    pos = index content, "\n"
    inc pos
    substr content, 0, pos, ''
    goto CHECK_PARSING_FINISHED
  NOT_A_VERSION_SPECIFICICATION:

  if token != 'F' goto NOT_A_BUILTIN_MACRO
    # Look for two numbers seperated by a ','
    # We expect at least one digit
    pos = 0
    # rc_ is deprecated rx_is_d content, pos, UNEXPECTED
  PERHAPS_ANOTHER_DIGIT_1:
    # rc_ is deprecated rx_is_d content, pos, EXPECT_A_COMMA_1
    #goto PERHAPS_ANOTHER_DIGIT_1
  EXPECT_A_COMMA_1:
    substr token, content, 0, pos, ''
    name_len = token
    pos = 0
    # rx_ is deprecated rx_literal content, pos, ',', UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    # We expect at least another digit
    # rc_ is deprecated rx_is_d content, pos, UNEXPECTED
  PERHAPS_ANOTHER_DIGIT_2:
    # rc_ is deprecated rx_is_d content, pos, EXPECT_A_NEWLINE_1
    #goto PERHAPS_ANOTHER_DIGIT_2
  EXPECT_A_NEWLINE_1:
    substr token, content, 0, pos, ''
    substitution_len = token
    pos = 0
    # rx_ is deprecated rx_literal content, pos, "\n", UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    # We know the length, so we can extract the strings
    substr name, content, 0, name_len, ''
    substr text, content, 0, substitution_len, ''
    builtin = builtin_tab[name]
    unless builtin goto BUILTIN_NOT_FOUND
    define_builtin( state, name, builtin )
    goto BUILTIN_HAS_BEEN_HANDLED
    BUILTIN_NOT_FOUND:
      printerr "`"
      printerr name
      printerr "' from frozen file not found in builtin table!\n"
    BUILTIN_HAS_BEEN_HANDLED:
    pos = 0
    # rx_ is deprecated rx_literal content, pos, "\n", UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    goto CHECK_PARSING_FINISHED
  NOT_A_BUILTIN_MACRO:

  if token != 'T' goto NOT_A_USER_DEFINED_MACRO
    # Look for two numbers seperated by a ','
    # We expect at least one digit
    pos = 0
    # rc_ is deprecated rx_is_d content, pos, UNEXPECTED
  PERHAPS_ANOTHER_DIGIT_3:
    # rc_ is deprecated rx_is_d content, pos, EXPECT_A_COMMA_2
    # goto PERHAPS_ANOTHER_DIGIT_3
  EXPECT_A_COMMA_2:
    substr token, content, 0, pos, ''
    name_len = token
    pos = 0
    # rx_ is deprecated rx_literal content, pos, ',', UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    # We expect at least another digit
    # rc_ is deprecated rx_is_d content, pos, UNEXPECTED
  PERHAPS_ANOTHER_DIGIT_4:
    # rc_ is deprecated rx_is_d content, pos, EXPECT_A_NEWLINE_2
    # goto PERHAPS_ANOTHER_DIGIT_4
  EXPECT_A_NEWLINE_2:
    substr token, content, 0, pos, ''
    substitution_len = token
    pos = 0
    # rx_ is deprecated rx_literal content, pos, "\n", UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    substr name, content, 0, name_len, ''
    substr text, content, 0, substitution_len, ''
    # We know the length, so we can extract the strings
    define_user_macro( state, name, text )
    pos = 0
    # rx_ is deprecated rx_literal content, pos, "\n", UNEXPECTED
    substr content, 0, pos, ''
    pos = 0
    goto CHECK_PARSING_FINISHED
  NOT_A_USER_DEFINED_MACRO:

# TODO: handle the missing options
  print 'unknown flag: '
  print token
  print "\n"

CHECK_PARSING_FINISHED:
  substr token, content, 0, 1, ''
  if token != '' goto HANDLE_NEXT_TOKEN
    goto FINISHED
  UNEXPECTED:
  printerr "Found an unexpected character\n'"
  printerr token
  printerr "'\n"

  FINISHED:
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
