# $Id$

=head1 NAME

builtin.pir - builtin and user defined macros

=head2 DESCRIPTION

Copyright:  2004 Bernhard Schmalhofer.  All Rights Reserved.
SVN Info:   $Id$
History:    Ported from GNU m4 1.4
References: http://www.gnu.org/software/m4/m4.html

Code for all builtin macros, initialisation of symbol table, and
expansion of user defined macros.

=cut

# Some named constants
.include 'include/iterator.pasm'

=head1 SUBROUTINES

=head2 void builtin_tab_init( Hash state )

Initialise all builtin and predefined macros.

=cut

.sub builtin_tab_init 
  .param pmc state

  .local pmc builtin_tab, builtin, func

  # Generate a table of Sub
  builtin_tab = state['builtin_tab']

  .const .Sub func_m4_not_implemented = "m4_not_implemented"

  #     name                    GNUext  macros  blind   function */
  #   { "__file__",                TRUE,        FALSE,        FALSE,        m4___file__ },
  builtin = new .Hash
  builtin['name'] = '__file__'
  .const .Sub func_m4___file__ = "m4___file__"
  builtin['func'] = func_m4___file__ 
  builtin['blind_no_args'] = 0 
  builtin_tab['__file__'] = builtin

  #   { "__line__",                TRUE,        FALSE,        FALSE,        m4___line__ },
  builtin = new .Hash
  builtin['name'] = '__line__'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['__line__'] = builtin

  #   { "builtin",                TRUE,        FALSE,        TRUE,        m4_builtin },
  builtin = new .Hash
  builtin['name'] = 'builtin'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['builtin'] = builtin

  #   { "changecom",                FALSE,        FALSE,        FALSE,        m4_changecom },
  builtin = new .Hash
  builtin['name'] = 'changecom'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['changecom'] = builtin

  #   { "changequote",	        FALSE,        FALSE,        FALSE,        m4_changequote },
  builtin = new .Hash
  builtin['name'] = 'changequote'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['changequote'] = builtin

  #   { "changeword",        TRUE,        FALSE,        FALSE,        m4_changeword },
  builtin = new .Hash
  builtin['name'] = 'changeword'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['changeword'] = builtin

  #   { "debugmode",        TRUE,        FALSE,        FALSE,        m4_debugmode },
  builtin = new .Hash
  builtin['name'] = 'debugmode'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['debugmode'] = builtin

  #   { "debugfile",        TRUE,        FALSE,        FALSE,        m4_debugfile },
  builtin = new .Hash
  builtin['name'] = 'debugfile'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['debugfile'] = builtin

  #   { "decr",                FALSE,        FALSE,        TRUE,        m4_decr },
  builtin = new .Hash
  builtin['name'] = 'decr'
  .const .Sub func_m4_decr = "m4_decr"
  builtin['func'] = func_m4_decr
  builtin['blind_no_args'] = 1 
  builtin_tab['decr'] = builtin

  #   { "define",                FALSE,        TRUE,        TRUE,        m4_define },
  builtin = new .Hash
  builtin['name'] = 'define'
  .const .Sub func_m4_define = "m4_define"
  builtin['func'] = func_m4_define
  builtin['blind_no_args'] = 1 
  builtin_tab['define'] = builtin

  #   { "defn",                FALSE,        FALSE,        TRUE,        m4_defn },
  builtin = new .Hash
  builtin['name'] = 'defn'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['defn'] = builtin

  #   { "divert",                FALSE,        FALSE,        FALSE,        m4_divert },
  builtin = new .Hash
  builtin['name'] = 'divert'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['divert'] = builtin

  #   { "divnum",                FALSE,        FALSE,        FALSE,        m4_divnum },
  builtin = new .Hash
  builtin['name'] = 'divnum'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['divnum'] = builtin

  #   { "dnl",                  FALSE,        FALSE,        FALSE,        m4_dnl },
  builtin = new .Hash
  builtin['name'] = 'dnl'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['dnl'] = builtin

  #   { "dumpdef",                FALSE,        FALSE,        FALSE,        m4_dumpdef },
  builtin = new .Hash
  builtin['name'] = 'dumpdef'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['dumpdef'] = builtin

  #   { "errprint",                FALSE,        FALSE,        FALSE,        m4_errprint },
  builtin = new .Hash
  builtin['name'] = 'errprint'
  .const .Sub func_m4_errprint = "m4_errprint"
  builtin['func'] = func_m4_errprint
  builtin['blind_no_args'] = 0 
  builtin_tab['errprint'] = builtin

  #   { "esyscmd",                TRUE,        FALSE,        TRUE,        m4_esyscmd },
  builtin = new .Hash
  builtin['name'] = 'esyscmd'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['esyscmd'] = builtin

  #   { "eval",		FALSE,	FALSE,	TRUE,	m4_eval },
  builtin = new .Hash
  builtin['name'] = 'eval'
  .const .Sub func_m4_eval = "m4_eval"
  builtin['func'] = func_m4_eval
  builtin['blind_no_args'] = 1 
  builtin_tab['eval'] = builtin

  #   { "format",		TRUE,	FALSE,	FALSE,	m4_format },
  builtin = new .Hash
  builtin['name'] = 'format'
  .const .Sub func_m4_format = "m4_format"
  builtin['func'] = func_m4_format
  builtin['blind_no_args'] = 0 
  builtin_tab['format'] = builtin

  #   { "ifdef",		FALSE,	FALSE,	TRUE,	m4_ifdef },
  builtin = new .Hash
  builtin['name'] = 'ifdef'
  .const .Sub func_m4_ifdef = "m4_ifdef"
  builtin['func'] = func_m4_ifdef
  builtin['blind_no_args'] = 1 
  builtin_tab['ifdef'] = builtin

  #   { "ifelse",		FALSE,	FALSE,	TRUE,	m4_ifelse },
  builtin = new .Hash
  builtin['name'] = 'ifelse'
  .const .Sub func_m4_ifelse = "m4_ifelse"
  builtin['func'] = func_m4_ifelse
  builtin['blind_no_args'] = 1 
  builtin_tab['ifelse'] = builtin

  #   { "include",		FALSE,	FALSE,	TRUE,	m4_include },
  builtin = new .Hash
  builtin['name'] = 'include'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['include'] = builtin

  #   { "incr",	        	FALSE,	FALSE,	TRUE,	m4_incr },
  builtin = new .Hash
  builtin['name'] = 'incr'
  .const .Sub func_m4_incr = "m4_incr"
  builtin['func'] = func_m4_incr
  builtin['blind_no_args'] = 1 
  builtin_tab['incr'] = builtin

  #   { "index",		FALSE,	FALSE,	TRUE,	m4_index },
  builtin = new .Hash
  builtin['name'] = 'index'
  .const .Sub func_m4_index = "m4_index"
  builtin['func'] = func_m4_index
  builtin['blind_no_args'] = 1 
  builtin_tab['index'] = builtin

  #   { "indir",		TRUE,	FALSE,	FALSE,	m4_indir },
  builtin = new .Hash
  builtin['name'] = 'indir'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['indir'] = builtin

  #   { "len",	        	FALSE,	FALSE,	TRUE,	m4_len },
  builtin = new .Hash
  builtin['name'] = 'len'
  .const .Sub func_m4_len = "m4_len"
  builtin['func'] = func_m4_len
  builtin['blind_no_args'] = 1 
  builtin_tab['len'] = builtin

  #   { "m4exit",		FALSE,	FALSE,	FALSE,	m4_m4exit },
  builtin = new .Hash
  builtin['name'] = 'm4exit'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['m4exit'] = builtin

  #   { "m4wrap",		FALSE,	FALSE,	FALSE,	m4_m4wrap },
  builtin = new .Hash
  builtin['name'] = 'm4wrap'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['m4wrap'] = builtin

  #   { "maketemp",		FALSE,	FALSE,	TRUE,	m4_maketemp },
  builtin = new .Hash
  builtin['name'] = 'maketemp'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['maketemp'] = builtin

  #   { "patsubst",		TRUE,	FALSE,	TRUE,	m4_patsubst },
  builtin = new .Hash
  builtin['name'] = 'patsubst'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['patsubst'] = builtin

  #   { "popdef",		FALSE,	FALSE,	TRUE,	m4_popdef },
  builtin = new .Hash
  builtin['name'] = 'popdef'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['popdef'] = builtin

  #   { "pushdef",		FALSE,	TRUE,	TRUE,	m4_pushdef },
  builtin = new .Hash
  builtin['name'] = 'pushdef'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['pushdef'] = builtin

  #   { "regexp",		TRUE,	FALSE,	TRUE,	m4_regexp },
  builtin = new .Hash
  builtin['name'] = 'regexp'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['regexp'] = builtin

  #   { "shift",		FALSE,	FALSE,	FALSE,	m4_shift },
  builtin = new .Hash
  builtin['name'] = 'shift'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['shift'] = builtin

  #   { "sinclude",		FALSE,	FALSE,	TRUE,	m4_sinclude },
  builtin = new .Hash
  builtin['name'] = 'sinclude'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['sinclude'] = builtin

  #   { "substr",		FALSE,	FALSE,	TRUE,	m4_substr },
  builtin = new .Hash
  builtin['name'] = 'substr'
  .const .Sub func_m4_substr = "m4_substr"
  builtin['func'] = func_m4_substr
  builtin['blind_no_args'] = 1 
  builtin_tab['substr'] = builtin

  #   { "syscmd",		FALSE,	FALSE,	TRUE,	m4_syscmd },
  builtin = new .Hash
  builtin['name'] = 'syscmd'
  .const .Sub func_m4_syscmd = "m4_syscmd"
  builtin['func'] = func_m4_syscmd
  builtin['blind_no_args'] = 1 
  builtin_tab['syscmd'] = builtin

  #   { "sysval",		FALSE,	FALSE,	FALSE,	m4_sysval },
  builtin = new .Hash
  builtin['name'] = 'sysval'
  .const .Sub func_m4_sysval = "m4_sysval"
  builtin['func'] = func_m4_sysval
  builtin['blind_no_args'] = 0 
  builtin_tab['sysval'] = builtin

  #   { "traceoff",		FALSE,	FALSE,	FALSE,	m4_traceoff },
  builtin = new .Hash
  builtin['name'] = 'traceoff'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['traceoff'] = builtin

  #   { "traceon",		FALSE,	FALSE,	FALSE,	m4_traceon },
  builtin = new .Hash
  builtin['name'] = 'traceon'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['traceon'] = builtin

  #   { "translit",		FALSE,	FALSE,	TRUE,	m4_translit },
  builtin = new .Hash
  builtin['name'] = 'translit'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 1 
  builtin_tab['translit'] = builtin

  #   { "undefine",		FALSE,	FALSE,	TRUE,	m4_undefine },
  builtin = new .Hash
  builtin['name'] = 'undefine'
  .const .Sub func_m4_undefine = "m4_undefine"
  builtin['func'] = func_m4_undefine
  builtin['blind_no_args'] = 1 
  builtin_tab['undefine'] = builtin

  #   { "undivert",		FALSE,	FALSE,	FALSE,	m4_undivert },
  builtin = new .Hash
  builtin['name'] = 'undivert'
  builtin['func'] = func_m4_not_implemented 
  builtin['blind_no_args'] = 0 
  builtin_tab['undivert'] = builtin

.end


=head2 void builtin_init( Hash state )

Initialise all builtin and predefined macros.

=cut

.sub builtin_init 
  .param pmc state

  .local pmc    iterator, builtin, builtin_tab
  .local string name
  .local int    prefix_all_builtins

  builtin_tab = state['builtin_tab']
  prefix_all_builtins = state['prefix_all_builtins']
  iterator = new .Iterator, builtin_tab
  set iterator, .ITERATE_FROM_START
ITER_LOOP:
  unless iterator, END_ITER
  builtin = shift iterator
  name = builtin['name']
  unless prefix_all_builtins goto DONT_PREFIX_ALL_BUILTINS
  name = 'm4_' . name
DONT_PREFIX_ALL_BUILTINS:
  define_builtin( state, name, builtin )
  goto ITER_LOOP
END_ITER:
.end


=head2 void define_builtin( Hash state, string name, string bp )

Install a builtin macro with name 'name', bound to the function 'bp'.

=cut

.sub define_builtin 
  .param pmc       state
  .param string    name
  .param pmc       builtin

  .local pmc symtab
  symtab = state['symtab']

  # Now store the passed symbol
  .local pmc symbol
  symbol = new .Hash
  symbol['name'] = name
  symbol['type'] = 'TOKEN_FUNC'

  .local string text
  text = builtin['name']
  symbol['text'] = text

  .local pmc func
  func = builtin['func']
  symbol['func'] = func

  .local int blind_no_args
  blind_no_args = builtin['blind_no_args']
  symbol['blind_no_args'] = blind_no_args

  symtab[name] = symbol
.end


=head2 void define_user_macro( Hash state, string name, string text )

Define a predefined or user-defined macro, with name 'name', and expansion 'text'. 
This function is also called from main(). 

=cut

.sub define_user_macro 
  .param pmc       state
  .param string    name     
  .param string    text

  .local pmc symtab
  symtab = state['symtab']

  # Now store the passed symbol
  .local pmc symbol
  symbol = new .Hash
  symbol['name'] = name
  symbol['text'] = text
  symbol['type'] = 'TOKEN_TEXT'

  symtab[name] = symbol
.end


=head2 define_macro

The function define_macro is common for the builtins "define",
"undefine", "pushdef" and "popdef".  ARGC and ARGV is as for the caller,
and MODE argument determines how the macro name is entered into the
symbol table.							

=cut

.sub define_macro 
  .param pmc       state
  .param string    name
  .param string    text

  # right now we handle only TOKEN_TEXT
  define_user_macro( state, name, text )
.end


=head2 m4___file__

Mostly for debugging.
TODO: This is broken for multiple input files.
TODO: This is broken when the path seperator is not '/'

=cut

.sub m4___file__ 
  .param pmc  state

  .local string current_file
  current_file = state['current_file']

  .return ( current_file )
.end


=head2 m4_decr

Decrease a number.

=cut

.sub m4_decr 
  .param pmc state
  .param pmc arguments

  .local int arg0
  arg0 = arguments[0]
  dec arg0

  .local string ret
  ret = arg0

  .return( ret )
.end


=head2 m4_define

Define a user defined macro.

=cut

.sub m4_define 
  .param pmc state
  .param pmc arguments

  # right now we handle only TOKEN_TEXT

  .local string arg0, arg1
  arg0 = arguments[0]
  arg1 = arguments[1]

  define_macro( state, arg0, arg1 )

  .return ( '' )
.end


=head2 m4_errprint

Print to standard error.
The individual arguments are seperated by a blank.

=cut

.sub m4_errprint 
  .param pmc state
  .param pmc arguments

  # right now we handle only TOKEN_TEXT

  .local pmc    iterator, arg
  .local int    is_first_arg
  is_first_arg = 1
  iterator = new .Iterator, arguments
  set iterator, .ITERATE_FROM_START
ITER_LOOP:
  unless iterator, END_ITER
  if is_first_arg goto FIRST_ARG
  printerr ' '
  goto FIRST_OR_OTHER_ARG
FIRST_ARG:
  is_first_arg = 0
FIRST_OR_OTHER_ARG: 
  arg = shift iterator
  printerr arg
  goto ITER_LOOP
END_ITER:

  .return ( '' )
.end


=head2 m4_eval

Integer arithmetics.

=cut

.sub m4_eval 
  .param pmc state
  .param pmc arguments

  # load shared library
  .local pmc m4_evaluate_lib
  m4_evaluate_lib = loadlib "m4_evaluate"

  # compile code and run it
  .local string expression
  expression = arguments[0]
  .local int evaluated_expression
  .local pmc m4_evaluate
  m4_evaluate = dlfunc m4_evaluate_lib, "m4_evaluate", "it"
  ( evaluated_expression ) = m4_evaluate( expression )
  .local string ret
  ret = evaluated_expression

  .return ( ret )
.end


=head2 m4_format

Frontend for printf like formatting. 

=cut

.sub m4_format 
  .param pmc state
  .param pmc arguments

  .local string arg0
  arg0 = shift arguments

  .local string ret
  ret = sprintf arg0, arguments

  .return ( ret )
.end


=head2 m4_ifdef

A conditional. Check whether a macro is defined.

=cut

.sub m4_ifdef 
  .param pmc state
  .param pmc arguments

  .local string arg0
  arg0 = arguments[0]

  .local pmc symtab
  symtab = state['symtab']

  .local string ret
  .local int symbol_exists
  symbol_exists = exists symtab[arg0] 
  
  unless symbol_exists goto SYMBOL_DOES_NOT_EXIST
  ret = arguments[1]
  goto FINISH_M4_IFDEF
SYMBOL_DOES_NOT_EXIST:
  ret = arguments[2]

FINISH_M4_IFDEF:
  .return ( ret )
.end


=head2 m4_ifelse

A conditional. Can also be used a block comment or as a 
switch statement.

=cut

.sub m4_ifelse 
  .param pmc state
  .param pmc arguments

  .local string ret
  ret = ''

  .local int argc
  if argc == 2 goto USED_AS_BLOCK_QUOTE

  .local string arg0, arg1, arg2, arg3
  arg0 = arguments[0]
  arg1 = arguments[1]
  arg2 = arguments[2]
  arg3 = arguments[3]

  ne arg0, arg1, IS_NOT_EQUAL
  ret = arg2
  goto FINISH_M4_IFELSE
IS_NOT_EQUAL:
  ret = arg3
  goto FINISH_M4_IFELSE

USED_AS_BLOCK_QUOTE:
FINISH_M4_IFELSE:
  .return ( ret )
.end



=head2 m4_incr

Increase a number.

=cut

.sub m4_incr 
  .param pmc state
  .param pmc arguments

  .local int arg0
  arg0 = arguments[0]
  inc arg0

  .local string ret
  ret = arg0

  .return ( ret )
.end


=head2 m4_index

The macro expands to the first index of the second argument 
in the first argument. 

=cut

.sub m4_index 
  .param pmc state
  .param pmc arguments

  .local string arg0, arg1
  arg0 = arguments[0]
  arg1 = arguments[1]

  .local int index_int
  index_int = index arg0, arg1

  # Write integer into a string
  .local string ret
  ret = index_int

  .return ( ret )
.end


=head2 m4_len

Expand to the length of the first argument. 

=cut

.sub m4_len 
  .param pmc state
  .param pmc arguments

  .local string arg0
  arg0 = arguments[0]

  .local int len
  len = length arg0

  .local string ret
  ret = len

  .return ( ret )
.end


=head2 m4_substr

The macro "substr" extracts substrings from the first argument, starting
from the index given by the second argument, extending for a length
given by the third argument.  If the third argument is missing, the
substring extends to the end of the first argument.

=cut

.sub m4_substr 
  .param pmc state
  .param pmc arguments

  .local string ret

  .local int argc
  argc = arguments
  if argc < 2 goto FINISH_SUBSTR
  if argc > 3 goto FINISH_SUBSTR

  .local string in
  in = arguments[0]
  .local int start
  start = arguments[1]

  if argc != 2 goto LENGTH_PASSED
  ret = substr in, start 
  goto FINISH_SUBSTR

LENGTH_PASSED:
  .local int len
  len = arguments[2]
  ret = substr in, start, len 
  goto FINISH_SUBSTR

FINISH_SUBSTR:
  .return ( ret )
.end


=head2 m4_syscmd

Execute a shell command and don't return the return code.

=cut

.sub m4_syscmd 
  .param pmc state
  .param pmc arguments

  .local string arg0
  arg0 = arguments[0]

  .local string shell_cmd
  concat shell_cmd, '', arg0

  .local int exit_status
  exit_status = spawnw shell_cmd

  # Store it as a global for m4_sysval
  .local pmc exit_status_as_pmc
  exit_status_as_pmc = new .Integer
  exit_status_as_pmc  = exit_status
  store_global 'exit_status', exit_status_as_pmc

  .return ( '' )
.end


=head2 m4_sysval

Return the exit status of the last syscmd.

=cut

.sub m4_sysval 
  .param pmc state
  .param pmc arguments

  # Retrieve it as a global set by m4_sysval
  .local pmc exit_status_as_pmc
  find_global exit_status_as_pmc, 'exit_status'

  .local string ret
  ret = exit_status_as_pmc

  .return ( ret )
.end


=head2 m4_undefine

Define a user defined macro.

=cut

.sub m4_undefine 
  .param pmc state
  .param pmc arguments

  .local string arg0
  arg0 = arguments[0]

  .local pmc symtab
  symtab = state['symtab']

  delete symtab[arg0]
 
  .return ( '' )
.end


=head2 m4_not_implemented

A placeholder for unimplemented functions.

=cut

.sub m4_not_implemented 
  .param pmc state
  .param pmc arguments

  .return ( 'not implemented yet' )
.end
