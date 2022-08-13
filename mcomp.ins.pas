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

var (mcomp_com)
  syn_p: syn_p_t;                      {SYN library use state}
  code_p: code_p_t;                    {CODE library use state}

procedure mcomp_dbg_coll (             {show contents of a collection}
  in      coll: fline_coll_t);         {the collection to show}
  val_param; extern;

procedure mcomp_parse (                {parse input, build in-memory structures}
  in var  coll: fline_coll_t;          {collection of text lines to parse}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure mcomp_parse_block (          {parse block of code, and all subordinate blocks}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function mcomp_syn_statement (         {parse one top level statement}
  in out  syn: syn_t)
  :boolean;
  val_param; extern;
