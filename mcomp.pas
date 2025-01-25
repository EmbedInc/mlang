{   M compiler.
}
program mcomp;
%include 'mcomp.ins.pas';
%include 'builddate.ins.pas';
define mcomp_com;                      {define common block for program global vars}

const
  max_msg_args = 2;                    {max arguments we can pass to a message}

var
  fnam_in:                             {input file name}
    %include '(cog)lib/string_treename.ins.pas';
  iname_set: boolean;                  {TRUE if the input file name already set}
  pre_only: boolean;                   {pre-process only}
  showver: boolean;                    {show the program version}
  show_sym: boolean;                   {show symbols resulting from parsing}
  show_mem: boolean;                   {show memory configuration}
  docomp: boolean;                     {do compilation}

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
  show_sym := false;                   {init to not show symbols from parsing}
  docomp := true;                      {init to do compilation}

  mcomp_global_init (util_top_mem_context); {init global program state}
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
    '-IN -PRE -V -TREE -SYM -MEM',
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
  docomp := false;
  end;
{
*   -V
}
3: begin
  showver := true;                     {show program version}
  docomp := false;
  end;
{
*   -TREE
}
4: begin
  show_tree := true;                   {show syntax tree each statement}
  docomp := false;
  end;
{
*   -SYM
}
5: begin
  show_sym := true;                    {show symbols resulting from parsing input}
  docomp := false;
  end;
{
*   -MEM
}
6: begin
  show_mem := true;                    {show memory config defined in input file}
  docomp := false;
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
*   Pre-process the source file into the collection of lines COLL_P^.
}
  mcomp_pre (fnam_in, stat);           {do the pre-processing}
  sys_error_abort (stat, '', '', nil, 0);

  if pre_only then begin               {pre-process only ?}
    mcomp_dbg_coll (coll_p^);          {show the data in the postprocessed collection}
    goto abort1;
    end;
{
*   Parse the pre-processed result and build the in-memory structures
*   representing the code.
}
  mcomp_comm_init (coll_p^);           {init comment system}

  mcomp_parse (coll_p^, stat);         {parse the pre-processed collection of lines}
  sys_error_abort (stat, '', '', nil, 0);

  if show_mem then begin               {show memory configuration ?}
    writeln;
    code_memsym_show_all (code_p^, 0);
    end;

  if show_sym then begin
    writeln;                           {show tree of symbols ?}
    code_scope_show (code_p^, code_p^.scope_root, 0);
    end;

  if not docomp then goto abort1;      {don't do compilation step ?}

abort1:                                {jump here to leave with FLINE library open}
  mcomp_global_end;                    {end use of global state, release resources}
  end.
