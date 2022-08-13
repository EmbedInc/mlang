{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse;
define mcomp_parse_level;
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
  currlevel := 0;                      {init current block nesting level}
  nextlevel := mcomp_lev_unk_k;        {init to level of next statement is unknown}

  mcomp_parse_level (stat);            {process top level and everything under it}
  if sys_error(stat) then return;
{
*   Clean up and leave.
}
  syn_lib_end (syn_p);                 {end SYN lib use, release resources}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_PARSE_LEVEL (STAT)
*
*   Parse the current block of code and everything subordinate to it.  The CODE
*   structures will be updated to include the parsed code.  The routine returns
*   when done with the block, or an error is encountered.
}
procedure mcomp_parse_level (          {parse current level and below}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  startlev: sys_int_machine_t;         {starting level parsed with this call}

begin
  sys_error_none (stat);               {init to no error encountered}
  startlev := currlevel;               {save top level being parsed with this call}
{
*   Back here to process each new statement in or below the original level.
}
  while true do begin
    if nextlevel = mcomp_lev_unk_k then begin {level of next statement not known ?}
      discard(
        syn_parse_next (syn_p^, addr(mcomp_syn_level)) {find level of next statement}
        );
      end;

    if nextlevel = mcomp_lev_eod_k then return; {hit end of data ?}
    if nextlevel < startlev then return; {done with the original level ?}
    currlevel := nextlevel;            {update current level to the next statement}

    errsyn := not syn_parse_next (     {parse next statement, build syntax tree}
      syn_p^,                          {SYN library use state}
      addr(mcomp_syn_statement));      {top level parsing routine}
    if errsyn then begin               {syntax error ?}
      syn_parse_err_reparse (syn_p^);  {build syntax tree up to error}
      end;

    syn_trav_init (syn_p^);            {init for traversing the syntax tree}
    mcomp_syt_statement_lev;           {process syntax tree for STATEMENT}
    end;                               {back to do next statement}
  end;
