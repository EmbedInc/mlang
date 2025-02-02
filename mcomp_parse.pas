{   Routines for parsing the pre-processed input.
}
module mcomp_parse;
define mcomp_parse_getlevel;
define mcomp_parse_statement;
define mcomp_parse_block;
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

  level_set := false;                  {level of next line not known yet}

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
  if not level_set then begin          {level of next statement not already found ?}
    discard( syn_parse_next (          {call parse routine to find statement start}
      syn_p^,                          {SYN library use state}
      addr(mcomp_syn_stlevel))         {parsing routine to call, updates levels state}
      );
    end;

  mcomp_parse_getlevel := level_p^.level; {return the level of the next statement}
  end;
{
********************************************************************************
*
*   Function MCOMP_PARSE_STATEMENT (PARSEFUNC)
*
*   Parse one statement at the current level as indicated by CURRLEVEL.  The
*   routine returns without parsing the statement if it is at a higher nesting
*   level then current.  It is an error if the next statement is at a lower
*   level than current.
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
  if errsyn then begin                 {there was a previous syntax error ?}
    mcomp_err_atline ('', 'statement_err', nil, 0); {bomb program with error message}
    end;

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
  level_set := false;                  {reset to level of next statement not known}

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
*   Subroutine MCOMP_PARSE_BLOCK (SYFUNC_P, TREEWALK_P)
*
*   Parse and process all the statements in a block.  SYFUNC_P points to the
*   syntax parsing function to parse each statement.  TREEWALK_P points to the
*   routine to walk and process the resulting syntax tree.
*
*   This routine returns when the next statement is at a higher level than the
*   statements in the block.  The expected statement level must be at that of
*   the parent statement of the block, and will be restored to that before exit.
}
procedure mcomp_parse_block (          {parse and process all substatements in a block}
  in      syfunc_p: syn_parsefunc_p_t; {sub-statement syntax parsing routine}
  in      treewalk_p: mcomp_treewalk_p_t); {syntax tree walking routine}
  val_param;

begin
  mcomp_level_exp_down;                {expect statements down one level}

  while true do begin                  {back here after each statement in block}
    if mcomp_parse_statement(syfunc_p) {parse statement at inside block level}
      then begin                       {statement parsed, syntax tree built}
        treewalk_p^;                   {process the data on the syntax tree}
        end
      else begin                       {statement is at higher level}
        exit;
        end
      ;
    if errsyn then exit;               {don't continue after error}
    end;                               {back to do next statement}

  mcomp_level_exp_up;                  {back up to level of block start statement}
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

  currlevel := 0;                      {indicate expected level of next statement}
  while true do begin                  {loop over each statement}
    if mcomp_parse_statement (addr(mcomp_syn_statement)) then begin {parse statement}
      mcomp_syt_statement;             {process syntax tree of the statement}
      end;
    if errsyn then exit;               {don't continue after error}
    if syn_parse_end(syn_p^) then exit; {hit end of input ?}
    end;                               {back to do next statement}

  mcomp_parse_end;                     {release any parsing state no longer needed}
  end;
