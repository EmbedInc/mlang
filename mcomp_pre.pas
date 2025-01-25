{   Pre-process raw M language input files.
}
module mcomp_pre;
define mcomp_pre;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine MCOMP_PRE_CONFIG (ESCR, STAT)
*
*   Configure the Embed scripter (ESCR) for pre-processing M source code.  ESCR
*   ESCR is the state for the ESCR use to configure.
}
procedure mcomp_pre_config (           {configure ESCR as M language preprocessor}
  in out  escr: escr_t;                {ESCR use state}
  out     stat: sys_err_t);            {completion status}
  val_param; internal;

begin
  escr_set_preproc (escr, true);       {set preprocessor mode, not script mode}

  escr_set_incsuff (escr, '.m'(0));    {special suffixes required for include files}

  string_vstring (escr.cmdst, '#', 1); {special sequence to start a script command}

  escr_commdat_clear (escr);           {clear any default data file comment delimiters}
  escr_commdat_add (                   {add M source comment identifier}
    escr,                              {scripting system state}
    string_v(''''(0)),                 {comment start identifier}
    string_v(''(0)),                   {comment ends at end of line}
    stat);
  if sys_error(stat) then return;

  escr_commscr_clear (escr);           {clear any default preproc comment delimiters}
  escr_commscr_add (                   {add preprocessor comment identifier}
    escr,                              {scripting system state}
    string_v('//'(0)),                 {comment start identifier}
    string_v(''(0)),                   {comment ends at end of line}
    stat);
  if sys_error(stat) then return;

  escr_syexcl_clear (escr);            {clear any default syntax exclusions}
  escr_syexcl_add (                    {add exclusion for double quoted strings}
    escr,                              {state for this use of the ESCR system}
    string_v('"'),                     {quoted string start}
    string_v('"'),                     {quoted string end}
    stat);
  if sys_error(stat) then return;

  escr_quotesyn_clear (escr);          {clear existing quoted string syntaxes}
  escr_quotesyn_add (escr, '"', '"');  {quoted strings start/end with quote chars}

  string_vstring (escr.syfunc.st, '{', 1); {set function start/end identification}
  string_vstring (escr.syfunc.en, '}', 1);
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_PRE (FNAM, STAT)
*
*   Pre-process the M language input file FNAM.  The result is written to a
*   collection of lines managed by the FLINE library.  A pointer to the FLINE
*   library use state is saved in FLINE_P, and a pointer to the collection of
*   output lines in COLL_P.  All other state used by the preprocessor is
*   deallocated to the extent possible.
}
procedure mcomp_pre (                  {pre-process raw input into COLL_p^}
  in      fnam: univ string_var_arg_t; {top level source file to pre-process}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  escr_p: escr_p_t;                    {to preprocessor use state}

begin
  escr_open (                          {create new use of the ESCR scripting system}
    mem_p^,                            {parent memory context, will make subordinate}
    escr_p,                            {returned pointer to script system state}
    stat);
  if sys_error(stat) then return;

  mcomp_pre_config (escr_p^, stat);    {configue ESCR for MCOMP preprocessor use}
  sys_error_abort (stat, '', '', nil, 0);

  fline_coll_new_lmem (                {create object to hold preprocessed source}
    escr_p^.fline_p^,                  {FLINE library use state}
    string_v('M-postprocessed'(0)),    {name of the collection of lines}
    coll_p);                           {returned pointer to the collection structure}

  escr_out_to_coll (escr_p^, coll_p^); {route output lines to memory}

  escr_run_file (                      {run the preprocessor on the input file}
    escr_p^,                           {scripting system state}
    fnam, '.m',                        {input file name and allowed suffixes}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  escr_close_keep_lines (              {end this use of preprocessor, keep output}
    escr_p,                            {pointer to scripting system state, returned NIL}
    fline_p);                          {returned pointer to FLINE lib use state}
  end;
