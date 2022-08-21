{   Include file used by modules implementing the MLANG program.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'strflex.ins.pas';
%include 'fline.ins.pas';
%include 'escr.ins.pas';
%include 'syn.ins.pas';
%include 'code.ins.pas';

const
  {
  *   Special values for comment levels.  Normal nesting levels are 0-N.
  }
  mcomp_cmlev_eol_k = -1;              {end of line comment}
  mcomp_cmlev_blank_k = -2;            {blank line, no comment start char}

var (mcomp_com)
  syn_p: syn_p_t;                      {SYN library use state}
  code_p: code_p_t;                    {CODE library use state}
  currlevel: sys_int_machine_t;        {current block nesting level, 0 = top}
  nextlevel: sys_int_machine_t;        {lev of next statement}
  errsyn: boolean;                     {syntax error, doing error reparse}
  show_tree: boolean;                  {show syntax tree each statement, for debuggin}
{
*   Routines.
}
procedure mcomp_comm_get (             {read comment to end of line}
  in out  syn: syn_t;                  {SYN library use state}
  in      level: sys_int_machine_t;    {comment nesting level or MCOMP_CMLEV_xxx_K}
  in      noeol: boolean);             {consume EOL at end of comment}
  val_param; extern;

procedure mcomp_comm_newline;          {tell comment system now on new line}
  val_param; extern;

procedure mcomp_dbg_coll (             {show contents of a collection}
  in      coll: fline_coll_t);         {the collection to show}
  val_param; extern;

procedure mcomp_err_atline (           {show error, source line, and bomb program}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  options (val_param, extern, noreturn);

procedure mcomp_parse (                {parse input, build in-memory structures}
  in var  coll: fline_coll_t;          {collection of text lines to parse}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function mcomp_syn_statement (         {parse one top level statement}
  in out  syn: syn_t)
  :boolean;
  val_param; extern;

procedure mcomp_syt_statement;         {interpret STATEMENT}
  val_param; extern;
