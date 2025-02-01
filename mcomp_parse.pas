{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse_getlevel;
define mcomp_parse_statement;
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

  nextlev_set := false;                {level of next line not known yet}

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
*   Function MCOMP_PARSE_GETLEVEL
*
*   Returns the nesting level of the next statement.  The current input stream
*   position will be left at the first content character of the next statement.
*
*   This routine can be called either at the start of a new line, or after it
*   was previously called with no other parsing haven taken place since.  In the
*   second case, the the cached value from when this routine was called at the
*   start of a line is returned.
}
function mcomp_parse_getlevel          {get nesting level of next statement}
  :sys_int_machine_t;                  {statement nesting level, 0 = top}
  val_param;

begin
  if nextlev_set then begin            {already found next level previously ?}
    mcomp_parse_getlevel := nextlevel; {returne the previously-found level}
    end;

  discard( syn_parse_next (            {call parse routine to find statement start}
    syn_p^,                            {SYN library use state}
    addr(mcomp_syn_stlevel))           {parsing routine to call, sets NEXTLEVEL}
    );
  mcomp_parse_getlevel := nextlevel;   {return the nesting level of this new statement}
  end;
{
********************************************************************************
*
*   Function MCOMP_PARSE_STATEMENT (PARSEFUNC)
*
*   Parse one statement at the current level.  The routine returns without
*   parsing the statement if it is at a higher nesting level then current.  It
*   is an error if the next statement is at a lower level than current.
*
*   The function returns TRUE if the statement was parsed and a syntax tree
*   built.  It returns FALSE when the statement was at a higher level and
*   nothing was therefore parsed.
}
function mcomp_parse_statement (       {parse one statement at curr nesting level}
  in      syfunc_p: syn_parsefunc_p_t) {statement syntax parsing routine}
  :boolean;                            {statement parsed, syntax tree built}
  val_param;

var
  level: sys_int_machine_t;            {nesting level of next statement}

begin
  mcomp_parse_statement := false;      {init to statement not parsed}
  level := mcomp_parse_getlevel;       {get nesting level of next statement}
  if level < currlevel then return;    {next statement is at a higher level ?}

  if level <> currlevel then begin     {unexpected subordinate statement ?}
    mcomp_err_atline (                 {bomb with error showing subordinate statement}
      '', 'statement_subordinate', nil, 0);
    end;
{
*   This statement is at the expected nesting level.
}
  nextlev_set := false;                {reset to level of next statement not known}

  errsyn := not syn_parse_next (       {parse statement, build syntax tree}
    syn_p^,                            {SYN library use state}
    syfunc_p);                         {routine for statement syntax construction}
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

  mcomp_parse_statement := true;       {indicate statement parsed, syntax tree built}
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

  currlevel := 0;                      {at top statement nesting level}
  while true do begin                  {loop over each statement}
    if mcomp_parse_statement (addr(mcomp_syn_statement)) then begin {parse statement}
      mcomp_syt_statement;             {process syntax tree of the statement}
      end;
    if errsyn then exit;               {don't continue after error}
    if syn_parse_end(syn_p^) then exit; {hit end of input ?}
    end;                               {back to do next statement}

  mcomp_parse_end;                     {release any parsing state no longer needed}
  end;
