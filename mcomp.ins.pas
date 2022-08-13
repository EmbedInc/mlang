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
  mcomp_lev_unk_k = -1;                {level is unknown}
  mcomp_lev_eod_k = -2;                {reached end of data}

var (mcomp_com)
  syn_p: syn_p_t;                      {SYN library use state}
  code_p: code_p_t;                    {CODE library use state}
  currlevel: sys_int_machine_t;        {current block nesting level, 0 = top}
  nextlevel: sys_int_machine_t;        {lev of next statement, 1-N or MCOMP_LEV_xxx_K}
  errsyn: boolean;                     {syntax error, doing error reparse}
{
*   Routines.
}
procedure mcomp_dbg_coll (             {show contents of a collection}
  in      coll: fline_coll_t);         {the collection to show}
  val_param; extern;

procedure mcomp_parse (                {parse input, build in-memory structures}
  in var  coll: fline_coll_t;          {collection of text lines to parse}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure mcomp_parse_level (          {parse current level and below}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function mcomp_syn_level (             {get level of next statement}
  in out  syn: syn_t)
  :boolean;
  val_param; extern;

function mcomp_syn_statement (         {parse one top level statement}
  in out  syn: syn_t)
  :boolean;
  val_param; extern;

procedure mcomp_syt_statement;         {process syntax tree for STATEMENT}
  val_param; extern;

procedure mcomp_syt_statement_lev;     {process syntax tree for STATEMENT, at start tree lev}
  val_param; extern;
