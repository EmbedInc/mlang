{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse;
define mcomp_parse_block;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_PARSE (COLL, STAT)
*
*   Parse the pre-processed input and build the in-memory structured defining
*   the code defined by the input.
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
*   Process the top level block of code, and create the in-memory structures in
*   the CODE library accordingly.
}
  mcomp_parse_block (stat);            {process top block and everything under it}
  if sys_error(stat) then return;
{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end SYN lib use, release resources}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_PARSE_BLOCK (STAT)
*
*   Parse the current block of code and everything subordinate to it.  The CODE
*   structures will be updated to include the parsed code.  The routine returns
*   when done with the block, or an error is encountered.
}
procedure mcomp_parse_block (          {parse block of code, and all subordinate blocks}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}




  end;
