{   M compiler.
}
program mcomp;
%include 'mcomp.ins.pas';
%include 'builddate.ins.pas';

const
  max_msg_args = 2;                    {max arguments we can pass to a message}

var
  fnam_in:                             {input file name}
    %include '(cog)lib/string_treename.ins.pas';
  e_p: escr_p_t;                       {points to scripting system use state}
  fl_p: fline_p_t;                     {points to FLINE library use state}
  coll_p: fline_coll_p_t;              {points to the preprocessor output lines}
  iname_set: boolean;                  {TRUE if the input file name already set}
  pre_only: boolean;                   {pre-process only}
  showver: boolean;                    {show the program version}

  opt:                                 {upcased command line option}
    %include '(cog)lib/string_treename.ins.pas';
  parm:                                {command line option parameter}
    %include '(cog)lib/string_treename.ins.pas';
  pick: sys_int_machine_t;             {number of token picked from list}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status code}

label
  next_opt, err_parm, parm_bad, done_opts, abort1;

begin
{
*   Initialize before reading the command line.
}
  string_cmline_init;                  {init for reading the command line}
  iname_set := false;                  {no input file name specified}
  pre_only := false;                   {init to do full compile}
  showver := false;                    {init to not show program version}
{
*   Back here each new command line option.
}
next_opt:
  string_cmline_token (opt, stat);     {get next command line option name}
  if string_eos(stat) then goto done_opts; {exhausted command line ?}
  sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0);
  if (opt.len >= 1) and (opt.str[1] <> '-') then begin {implicit pathname token ?}
    if not iname_set then begin        {input file name not set yet ?}
      string_treename(opt, fnam_in);   {set input file name}
      iname_set := true;               {input file name is now set}
      goto next_opt;
      end;
    sys_msg_parm_vstr (msg_parm[1], opt);
    sys_message_bomb ('string', 'cmline_opt_conflict', msg_parm, 1);
    end;
  string_upcase (opt);                 {make upper case for matching list}
  string_tkpick80 (opt,                {pick command line option name from list}
    '-IN -PRE -V',
    pick);                             {number of keyword picked from list}
  case pick of                         {do routine for specific option}
{
*   -IN filename
}
1: begin
  if iname_set then begin              {input file name already set ?}
    sys_msg_parm_vstr (msg_parm[1], opt);
    sys_message_bomb ('string', 'cmline_opt_conflict', msg_parm, 1);
    end;
  string_cmline_token (opt, stat);
  string_treename (opt, fnam_in);
  iname_set := true;
  end;
{
*   -PRE
}
2: begin
  pre_only := true;                    {indicate to only do pre-processing}
  end;
{
*   -V
}
3: begin
  showver := true;                     {show program version}
  end;
{
*   Unrecognized command line option.
}
otherwise
    string_cmline_opt_bad;             {unrecognized command line option}
    end;                               {end of command line option case statement}

err_parm:                              {jump here on error with parameter}
  string_cmline_parm_check (stat, opt); {check for bad command line option parameter}
  goto next_opt;                       {back for next command line option}

parm_bad:                              {jump here on got illegal parameter}
  string_cmline_reuse;                 {re-read last command line token next time}
  string_cmline_token (parm, stat);    {re-read the token for the bad parameter}
  sys_msg_parm_vstr (msg_parm[1], parm);
  sys_msg_parm_vstr (msg_parm[2], opt);
  sys_message_bomb ('string', 'cmline_parm_bad', msg_parm, 2);

done_opts:                             {done with all the command line options}
  if showver then begin                {just show program version and exit ?}
    writeln ('Program MCOMP, built on ', build_dtm_str);
    return;
    end;

  if not iname_set then begin
    sys_message_bomb ('string', 'cmline_input_fnam_missing', nil, 0);
    end;
{
*   Configure the ESCR scripting system for our use.
}
  escr_open (                          {create new use of the ESCR scripting system}
    util_top_mem_context,              {parent memory context, will make subordinate}
    e_p,                               {returned pointer to script system state}
    stat);
  sys_error_abort (stat, 'escr', 'open', nil, 0);

  escr_set_preproc (e_p^, true);       {set preprocessor mode, not script mode}

  escr_set_incsuff (e_p^, '.m'(0));    {special suffixes required for include files}

  string_vstring (e_p^.cmdst, '#', 1); {special sequence to start a script command}

  escr_commdat_clear (e_p^);           {clear any default data file comment delimiters}
  escr_commdat_add (                   {add M source comment identifier}
    e_p^,                              {scripting system state}
    string_v(''''(0)),                 {comment start identifier}
    string_v(''(0)),                   {comment ends at end of line}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  escr_commscr_clear (e_p^);           {clear any default preproc comment delimiters}
  escr_commscr_add (                   {add preprocessor comment identifier}
    e_p^,                              {scripting system state}
    string_v('//'(0)),                 {comment start identifier}
    string_v(''(0)),                   {comment ends at end of line}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  escr_syexcl_clear (e_p^);            {clear any default syntax exclusions}
  escr_syexcl_add (                    {add exclusion for double quoted strings}
    e_p^,                              {state for this use of the ESCR system}
    string_v('"'),                     {quoted string start}
    string_v('"'),                     {quoted string end}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  escr_quotesyn_clear (e_p^);          {clear existing quoted string syntaxes}
  escr_quotesyn_add (e_p^, '"', '"');  {quoted strings start/end with quote chars}

  string_vstring (e_p^.syfunc.st, '{', 1); {set function start/end identification}
  string_vstring (e_p^.syfunc.en, '}', 1);

  fline_coll_new_lmem (                {create object to hold preprocessed source}
    e_p^.fline_p^,                     {FLINE library use state}
    string_v('M-postprocessed'(0)),    {name of the collection of lines}
    coll_p);                           {returned pointer to the collection structure}
  escr_out_to_coll (                   {route output lines to memory}
    e_p^,                              {scripting system state}
    coll_p^);                          {where to write output lines to}
{
*   Do the pre-processing.
}
  escr_run_file (                      {run the preprocessor on the input file}
    e_p^,                              {scripting system state}
    fnam_in, '.m',                     {input file name and allowed suffixes}
    stat);
  sys_error_abort (stat, '', '', nil, 0);

  escr_close_keep_lines (              {end this use of preprocessor, keep output}
    e_p,                               {pointer to scripting system state, returned NIL}
    fl_p);                             {returned pointer to FLINE lib use state}
{
*   The preprocessor output is the collection of lines pointed to by COLL_P,
*   under the FLINE library use pointed to by FL_P.
}
  if pre_only then begin               {pre-process only ?}
    mcomp_dbg_coll (coll_p^);          {show the data in the postprocessed collection}
    goto abort1;
    end;


abort1:                                {jump here to leave with FLINE library open}
  fline_lib_end (fl_p);                {end this use of the FLINE library}
  end.
