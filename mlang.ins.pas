{   Include file used by modules implementing the MLANG program.
}
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'strflex.ins.pas';
%include 'fline.ins.pas';
%include 'escr.ins.pas';

procedure mlang_dbg_coll (             {show contents of a collection}
  in      coll: fline_coll_t);         {the collection to show}
  val_param; extern;
