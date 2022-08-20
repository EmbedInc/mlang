{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_PARSE (COLL, STAT)
*
*   Parse the pre-processed input and build the in-memory structures for the
*   code defined by that input.
}
procedure mcomp_parse (                {parse input, build in-memory structures}
  in var  coll: fline_coll_t;          {collection of text lines to parse}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  inicfg: code_inicfg_t;               {CODE lib initialization parameters}

begin
  sys_error_none (stat);               {init to no error encountered}
{
*   Set up the SYN library for parsing each statement.
}
  syn_lib_new (util_top_mem_context, syn_p); {start new use of the SYN library}
  syn_parse_pos_coll (syn_p^, coll);   {set parse position to start of input}
{
*   Set up the CODE library for maintaining the description of the parsed code.
}
  code_lib_def (inicfg);               {init CODE config parameters to default}
  inicfg.memnam_len := 32;             {max length of mem and adr space names}
  inicfg.symlen_max := 32;             {max length of other symbols}

  code_lib_new (inicfg, code_p, stat); {start new use of the CODE library}
{
*   Process all the statements, update the in-memory description of the code
*   accordingly.
}
  currlevel := 0;                      {init current block nesting level}

  while true do begin                  {loop over each statement}
    errsyn := not syn_parse_next (     {parse statement, build syntax tree}
      syn_p^,                          {SYN library use state}
      addr(mcomp_syn_statement));      {top level parsing routine}
    if errsyn then begin               {syntax error ?}
      syn_parse_err_reparse (syn_p^);  {build syntax tree up to error}
      end;

    syn_trav_init (syn_p^);            {init for traversing the syntax tree}
    writeln;
    syn_dbg_tree_show (syn_p^);        {show the syntax tree}
    writeln;

    mcomp_syt_statement;               {process syntax tree for STATEMENT}
    if syn_parse_end(syn_p^) then exit; {hit end of input ?}
    end;                               {back to do next statement}
{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end SYN lib use, release resources}
  end;
