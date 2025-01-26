{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine MCOMP_PARSE_START
*
*   Do the one-time initialization for parsing the collection of input lines at
*   COLL_P.
}
procedure mcomp_parse_start;           {set up for parsing the lines at COLL_P}
  val_param; internal;

var
  inicfg: code_inicfg_t;               {CODE lib initialization parameters}
  stat: sys_err_t;                     {completion status}

begin
  mcomp_comm_init (coll_p^);           {set up comment system to the pre-processed lines}

  syn_lib_new (mem_p^, syn_p);         {start new use of the SYN library}
  syn_parse_pos_coll (syn_p^, coll_p^); {set parse position to start of input}

  if code_p = nil then begin           {CODE library not already open ?}
    code_lib_def (inicfg);             {init CODE config parameters to default}
    inicfg.mem_p := mem_p;             {use our mem context as parent}
    inicfg.symlen_max := symlen_max;   {max length of other symbols}

    code_lib_new (inicfg, code_p, stat); {start new use of the CODE library}
    sys_error_abort (stat, '', '', nil, 0);
    end;

  currlevel := 0;                      {init current block nesting level}

  if show_tree then begin              {will be showing syntax trees ?}
    writeln;                           {insure blank line before first tree listing}
    end;
  end;
{
********************************************************************************
*
*   Local subroutine MCOMP_PARSE_END
*
*   Clean up after done parsing the input lines collection.  Any state that is
*   no longer needed (only used during parsing) is deallocated.
}
procedure mcomp_parse_end;             {clean up after parsing, del temp state}
  val_param; internal;

begin
  syn_lib_end (syn_p);                 {end SYN lib use, release resources}
  end;
{
********************************************************************************
*
*   Local subroutine MCOMP_PARSE_TOPLEV
*
*   Parse one top level syntax construction.  The global variable ERRSYN is
*   left indicating whether a syntax error was found.
}
procedure mcomp_parse_toplev;
  val_param; internal;

begin
  errsyn := not syn_parse_next (       {parse statement, build syntax tree}
    syn_p^,                            {SYN library use state}
    addr(mcomp_syn_statement));        {top level parsing routine}
  if errsyn then begin                 {syntax error ?}
    syn_parse_err_reparse (syn_p^);    {build syntax tree up to error}
    end;

  syn_trav_init (syn_p^);              {init for traversing the syntax tree}
  if show_tree then begin              {show the syntax tree ?}
    syn_dbg_tree_show (syn_p^);        {show the tree of this statement}
    writeln;
    end;

  if errsyn then begin                 {syntax error ?}
    syn_parse_err_show (syn_p^);       {show syntax error location}
    writeln;
    end;

  mcomp_syt_statement;                 {process syntax tree for STATEMENT}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_PARSE
*
*   Parse all the lines in the collection at COLL_P.  The information described
*   by the input lines is added to language-independent data managed by the CODE
*   library instance at CODE_P.  A new instance of the CODE library is opened
*   if one is not already at CODE_P.
*
*   The result of this call is an in-memory language-independent description of
*   the computer code represented by the input lines.
}
procedure mcomp_parse;                 {parse all lines at COLL_P}
  val_param;

begin
  mcomp_parse_start;                   {one-time setup for parsing input collection}

  while true do begin                  {loop over each statement}
    mcomp_parse_toplev;                {parse one top level syntax construction}
    if errsyn then exit;               {don't continue after error}
    if syn_parse_end(syn_p^) then exit; {hit end of input ?}
    end;                               {back to do next statement}

  mcomp_parse_end;                     {release any parsing state no longer needed}
  end;
