# $Id$

=head1 NAME 

input.pir - Setting up input and reading input

=head1 DESCRIPTION

Copyright:  2004 Bernhard Schmalhofer. All Rights Reserved.
CVS Info:   $Id$
History:    Ported from GNU m4 1.4
References: http://www.gnu.org/software/m4/m4.html

=head1 SUBROUTINES

=head2 void input_init( Hash state )

Initialise the input stack and various regexes.

'input_stack'   contains files, strings and macro definitions
'word_regex'    recognizes TOKEN_WORD.
'string_regex'  recognizes TOKEN_STRING
'simple_regex'  recognizes TOKEN_SIMPLE
'comment_regex' recognizes comments, returned as TOKEN_SIMPLE

TODO: recognize nested quoted strings

=cut

.include "datatypes.pasm"

.sub input_init 
  .param pmc state 

  .local pmc empty_array

  # setup of stacks
  empty_array = new ResizablePMCArray
  state['token_stack'] = empty_array
  empty_array = new ResizablePMCArray
  state['input_stack'] = empty_array
  empty_array = new ResizablePMCArray
  state['wrapup_stack'] = empty_array

  # setup of regexes
  # regular expressions are needed for finding words and quoted strings
  .local pmc regex
  .local pmc erroffset
  erroffset = new Integer
  erroffset = 0
  .local pmc NULL
  NULL = null

  .local pmc init_func, compile_func, match_func, dollar_func, pcre_lib
  init_func    = find_global 'PCRE', 'init'
  compile_func = find_global 'PCRE', 'compile'
  dollar_func  = find_global 'PCRE', 'dollar'
  match_func   = find_global 'PCRE', 'match'
  state['pcre_match_func'] = match_func
  pcre_lib     = init_func()

  .local pmc err_decl
  .local pmc err  
  err_decl = new ResizablePMCArray
  push err_decl, .DATATYPE_CSTR
  push err_decl, 0
  push err_decl, 0
  err = new .ManagedStruct
  assign err, err_decl

  # pcre *pcre_compile( const char *pattern, int options,
  #                     const char **errptr, int *erroffset,
  #                     const unsigned char *tableptr
  .local pmc pcre_compile
  pcre_compile = dlfunc pcre_lib, "pcre_compile", "ptip3P"

  #int pcre_exec( const pcre *code, const pcre_extra *extra,
  #               const char *subject, int length, int startoffset,
  #               int options, int *ovector, int ovecsize );
  .local pmc pcre_exec
  pcre_exec = dlfunc pcre_lib, "pcre_exec", "ipPtiiipi"
  state['pcre_exec'] = pcre_exec

  #int pcre_copy_substring( const char *subject, int *ovector,
  #                         int stringcount, int stringnumber, char *buffer,
  #                         int buffersize );
  .local pmc pcre_copy_substring
  pcre_copy_substring = dlfunc pcre_lib, "pcre_copy_substring", "itpiibi"
  state['pcre_copy_substring'] = pcre_copy_substring

  regex = pcre_compile( '^[^`#_a-zA-Z]', 0, err, erroffset, NULL )
  state['simple_regex'] = regex
  regex = pcre_compile( '^#[^\n]*\n', 0, err, erroffset, NULL )
  state['comment_regex'] = regex
  regex = pcre_compile( '^[_a-zA-Z][_a-zA-Z0-9]*', 0, err, erroffset, NULL )
  state['word_regex'] = regex
  regex = pcre_compile( "^`[^`]*'", 0, err, erroffset, NULL )
  state['string_regex'] = regex

.end


=head2 void push_file( Hash state, string filename )

Stores a filename on a stack
TODO: open these files and complain when they don't or pass filehandles

=cut

.sub push_file 
  .param pmc      state 
  .param string   filename    

  # This is needed for m4___file__
  # TODO: this is badly broken, when there are multiple input files
  state['current_file'] = filename

  .local pmc in
  in = open filename, '<'
  if in goto PROCESS_SINGLE_FILE
    printerr filename
    printerr " not found\n"
    end
  PROCESS_SINGLE_FILE:
  .local string input_string    # input file handle
  input_string = read in, 50000
  close in

  # state['input_stack'] has been created in input_init 
  # TODO: seperate input blocks for every file
  .local pmc input_stack
  input_stack = state['input_stack']
  .local pmc input_block
  .local int stack_size
  stack_size = input_stack
  if stack_size > 0 goto NOT_FIRST_FILE
    input_block = new Hash
    input_block['type'] = 'INPUT_STRING'
    input_block['string'] = input_string
    push input_stack, input_block
    goto FINISH_PUSH_FILE
  NOT_FIRST_FILE:
  input_block = shift input_stack
  .local string file
  file = input_block['string']
  file = file . input_string
  input_block['string'] = file
  push input_stack, input_block
  FINISH_PUSH_FILE:
.end


=head2 string next_token( Hash state )

Parse and return a single token from the input stream.  A token can
either be TOKEN_EOF, if the input_stack is empty; it can be TOKEN_STRING
for a quoted string; TOKEN_WORD for something that is a potential macro
name; and TOKEN_SIMPLE for any single character that is not a part of
any of the previous types.					
									   |
Next_token () return the token type and the token data.

Uses regular expressions for finding tokens.

=cut

.sub next_token 
  .param pmc state 

  .local pmc input_stack    
  input_stack = state['input_stack']
  .local pmc input_block    
  input_block = shift input_stack
  .local string input_string    
  input_string = input_block['string']
  .local int current_file_len
  current_file_len = length input_string    
  .local pmc pcre_exec    
  pcre_exec = state['pcre_exec']
  .local pmc NULL
  null NULL
  .local pmc ovector
  ovector = new ManagedStruct
  ovector = 120       # 1/(2/3) * 4  * 2 * 10 for 10 result pairs
  .local int is_match
  .local pmc regex    
  .local string token_type
  token_type = 'TOKEN_EOF'
  .local string token_data
  token_data = ''
  .local int is_string_match
  is_string_match = 0
    
  # look for 'TOKEN_SIMPLE'
  # read a whole bunch of non-macro and non-word charcters
  regex = state['simple_regex']
  token_type = 'TOKEN_SIMPLE'
  is_match = pcre_exec( regex, NULL, input_string, current_file_len, 0, 0, ovector, 10 )
  if is_match ==  1 goto MATCH
  if is_match != -1 goto MATCH_FAILED

  # look for comments and return it as 'TOKEN_SIMPLE'
  regex = state['comment_regex']
  token_type = 'TOKEN_SIMPLE'
  is_match = pcre_exec( regex, NULL, input_string, current_file_len, 0, 0, ovector, 10 )
  if is_match ==  1 goto MATCH
  if is_match != -1 goto MATCH_FAILED

  # look for 'TOKEN_STRING'
  regex = state['string_regex']
  token_type = 'TOKEN_STRING'
  is_string_match = 1
  is_match = pcre_exec( regex, NULL, input_string, current_file_len, 0, 0, ovector, 10 )
  if is_match ==  1 goto MATCH
  if is_match != -1 goto MATCH_FAILED
  is_string_match = 0

  # look for 'TOKEN_WORD'
  # this will be checked for macro substitution
  regex = state['word_regex']
  token_type = 'TOKEN_WORD'
  is_match = pcre_exec( regex, NULL, input_string, current_file_len, 0, 0, ovector, 10 )
  if is_match ==  1 goto MATCH
  if is_match != -1 goto MATCH_FAILED

  if current_file_len != 0 goto MATCH_FAILED 
  token_type = 'TOKEN_EOF'
  token_data = ''
  goto FINISH_NEXT_TOKEN 

  MATCH:
    # ovector is an int arrary containing start stop coords
    .local int start_line, end_line
    .local pmc struct
    struct = new SArray
    struct = 3
    struct[0] = .DATATYPE_INT
    struct[1] = 2
    struct[2] = 0
    assign ovector, struct
    start_line = ovector[0;0]
    end_line   = ovector[0;1]
    token_data = substr input_string, start_line, end_line, ''
    unless is_string_match goto NO_STRING_MATCH
      substr token_data, 0, 1, ''
      substr token_data, -1, 1, ''
    NO_STRING_MATCH: 
  goto FINISH_NEXT_TOKEN

  MATCH_FAILED:
    printerr "failed to match !"
    printerr input_string
    printerr "!\n"     
  goto FINISH_NEXT_TOKEN

  FINISH_NEXT_TOKEN: 
  input_block['string'] = input_string
  push input_stack, input_block

  .return ( token_type, token_data )
.end
