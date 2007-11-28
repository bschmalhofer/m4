# $Id$

=head1 NAME

src/macro.pir - does macro substitution

=head1 DESCRIPTION

Copyright:  2004-2005 Bernhard Schmalhofer.  All Rights Reserved.
SVN Info:   $Id$
History:    Ported from GNU m4 1.4
References: http://www.gnu.org/software/m4/m4.html

=head1 SUBROUTINES

=head2 void expand_input( Hash state )

Loop through some input files.
TODO: read files in next_token()

=cut

.sub expand_input
  .param pmc  state

  .local string token_data, token_type  # current token data and type

  # go through the input, token for token
NEXT_TOKEN:
  ( token_type, token_data ) = next_token( state )
  expand_token( state, token_type, token_data )
  if token_type != 'TOKEN_EOF' goto NEXT_TOKEN

FINISH_EXPAND_INPUT:
.end


=head2 void expand_token( Hash state, string token_type, string token_data )

Expand one token, according to its type.  Potential macro names
(TOKEN_WORD) are looked up in the symbol table, to see if they have a
macro definition.  If they have, they are expanded as macros, otherwise
the text are just copied to the output.

=cut

.sub expand_token
  .param pmc       state
  .param string    token_type
  .param string    token_data

  .local pmc symtab
  symtab = state['symtab']

  # TOKEN_EOF and TOKEN_MACDEF are not expanded
  if token_type == 'TOKEN_EOF'    goto FINISH_EXPAND_TOKEN
  if token_type == 'TOKEN_MACDEF' goto FINISH_EXPAND_TOKEN

  # 'TOKEN_STRING' does the same as 'TOKEN_SIMPLE',
  if token_type == 'TOKEN_STRING' goto SHIPOUT_TEXT
  if token_type == 'TOKEN_SIMPLE' goto SHIPOUT_TEXT

  if token_type != 'TOKEN_WORD' goto NO_TOKEN_WORD
    .local int symbol_exists
    symbol_exists = exists symtab[token_data]
    unless symbol_exists goto SHIPOUT_TEXT
      .local pmc symbol
      symbol = symtab[token_data]
      .local string symbol_type
      symbol_type = symbol['type']
      if symbol_type != 'TOKEN_FUNC' goto EXPAND_MACRO
        # there are two types of macro invocations:
        # macro
        # macro( arg1, ... )
        # Most macros needs a parameter list, but e.g. __file__ has not args
        .local int blind_no_args
        blind_no_args = symbol['blind_no_args']
        unless blind_no_args goto EXPAND_MACRO
          .local string input_string
          input_string = state['stack';'input';0;'string']
          .local int first_char, open_parenthesis
          first_char = ord input_string
          open_parenthesis = ord '('
          if first_char != open_parenthesis goto SHIPOUT_TEXT
          goto EXPAND_MACRO

EXPAND_MACRO:
  expand_macro( state, symbol )
  goto FINISH_EXPAND_TOKEN

NO_TOKEN_WORD:
  printerr "unknown token type: "
  printerr token_type
  end

SHIPOUT_TEXT:
  shipout_text( state, token_data )
  goto FINISH_EXPAND_TOKEN

FINISH_EXPAND_TOKEN:
.end


=head2 string processed_token expand_macro( Hash state, Hash symbol )

The macro expansion is handled by expand_macro().
It parses the arguments in collect_arguments() and
builds a ResizablePMCArray containing the arguments.
The arguments themselves are stored on a local obstack.
expand_macro() uses call_macro() to do the call of the macro.

expand_macro() is potentially recursive, since it calls expand_argument(),
which might call expand_token (), which might call expand_macro().

=cut

.sub expand_macro
  .param pmc  state
  .param pmc  symbol

  .local int expansion_level
  expansion_level = state['expansion_level']
  .local int nesting_limit
  nesting_limit = state['nesting_limit']
  inc expansion_level
  if expansion_level <= nesting_limit goto NESTING_LIMIT_NOT_REACHED_YET
    printerr "ERROR: Recursion limit of "
    printerr nesting_limit
    printerr "exceeded, use -L<N> to change it"
    end
NESTING_LIMIT_NOT_REACHED_YET:
  state['expansion_level'] = expansion_level

  .local pmc arguments
  arguments = new .ResizablePMCArray
  collect_arguments( state, arguments )

  .local string text
  ( text ) = call_macro( state, symbol, arguments )
  .local string input_string
  input_string = state['stack';'input';0;'string']
  input_string = text . input_string
  state['stack';'input';0;'string'] = input_string

  expansion_level = state['expansion_level']
  dec expansion_level
  state['expansion_level'] = expansion_level

.end


=head2 string processed_token call_macro( ResizablePMCArray macro, string token )

Apply macro to a token.

TODO: distinguish between TOKEN_FUNC and TOKEN_WORD

=cut

.sub call_macro
  .param pmc       state
  .param pmc       symbol
  .param pmc       arguments

  .local string symbol_type, symbol_name
  symbol_type = symbol['type']
  symbol_name = symbol['name']

  .local string    text
  if symbol_type != 'TOKEN_TEXT' goto NO_TOKEN_TEXT
    text = symbol['text']
    goto FINISH_CALL_MACRO
NO_TOKEN_TEXT:

  if symbol_type == 'TOKEN_FUNC' goto TOKEN_FUNC
    printerr "INTERNAL ERROR: Bad symbol type in call_macro"
    end
TOKEN_FUNC:
  .local pmc func
  func = symbol['func']
  # indirect call of subs, seems to need elaborate PIR syntax
  .begin_call
    .arg state
    .arg arguments
  .call func
    ret_func_1:
    .result text
  .end_call

FINISH_CALL_MACRO:
  .return ( text )
.end


=head2 void collect_arguments

Collect all the arguments to a call of a macro.

=cut

.sub collect_arguments
  .param pmc state
  .param pmc arguments

  # The macro name has already been read in, thus we need to match
  # something like "('furcht', 'Hallo Welt')"
  # and capture the name 'furcht' and the substitution 'Hallo Welt'.
  # Thus we need to remenber the start and the length of these two captures
  .local int cnt_stack
  .local string input_string
  input_string = state['stack';'input';0;'string']

  # We need a '(' at beginning of string
  .local int index_opening
  index_opening = index input_string, '('
  if index_opening != 0 goto NOT_A_ARGUMENT_LIST

  # expand strings
  .local int start_index
  start_index = 0
  .local int num_args
  num_args = 0
  .local int index_comma, index_closing, index_start_string, index_end_string, len_string
  .local string arg
EXPAND_ARG:
  # find a string before ')'
  index_closing = index input_string, ')', start_index

  if index_closing == -1 goto NO_MORE_ARGS
  if num_args == 0 goto SKIP_SKIP_COMMA
  index_comma = index input_string, ',', start_index
  if index_comma == -1 goto NO_MORE_ARGS
  if index_closing < index_comma goto NO_MORE_ARGS
  start_index = index_comma
SKIP_SKIP_COMMA:
  index_start_string = index input_string, '`', start_index
  if index_start_string == -1 goto NO_MORE_ARGS
  inc index_start_string
  if index_closing < index_start_string goto NO_MORE_ARGS
  index_end_string = index input_string, "'", index_start_string
  if index_end_string == -1 goto NO_MORE_ARGS
  len_string = index_end_string - index_start_string
  substr arg, input_string, index_start_string, len_string
  start_index = index_end_string
  push arguments, arg
  num_args = arguments
  goto EXPAND_ARG

NO_MORE_ARGS:
  inc index_closing
  substr input_string, 0, index_closing, ''

NOT_A_ARGUMENT_LIST:
  state['stack';'input';0;'string'] = input_string
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
