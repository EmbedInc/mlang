{   Traversing of syntax trees related to data types.
}
module mcomp_syt_dtype;
define mcomp_syt_type_;
define mcomp_syt_dtype;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_TYPE_SUB
*
*   Walk and process the syntax tree resulting from one TYPE block substatement.
}
procedure mcomp_syt_type_sub;
  val_param; internal;

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  name: mcomp_name_t;                  {name of data type being defined}
  dtype: code_dtype_t;                 {data type name being defined as}
  sym_p: code_symbol_p_t;              {to new data type symbol}

begin
  if not syn_trav_next_down (syn_p^) then begin {down into TYPE_SUB syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_bad', nil, 0);
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for name of data type being defined}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_name_bad', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get name of data type being defined}

  tag := syn_trav_next_tag (syn_p^);   {get tag for data type definition or reference}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;
  mcomp_syt_dtype (dtype);             {process DTYPE syntax, fill in data type}

  code_dtype_sym_new (code_p^, name, sym_p); {create new data type symbol}
  code_dtype_sym_set (code_p^, sym_p^, dtype); {assign data type to symbol}

  if not syn_trav_up (syn_p^) then begin {back up to parent syntax level}
    syn_msg_pos_bomb (syn_p^, '', 'type_bad', nil, 0);
    end;
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_TYPE_
*
*   Process the syntax tree of a TYPE statement.
}
procedure mcomp_syt_type_;             {process TYPE statement block}
  val_param;

begin
  mcomp_parse_block (                  {process the substatements in the TYPE block}
    addr(mcomp_syn_type),              {address of syntax checking routine}
    addr(mcomp_syt_type_sub));         {routine to walk and process resulting syntax trees}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_DTYPE (DTYPE)
*
*   Process the DTYPE syntax and fill in DTYPE accordingly.
}
procedure mcomp_syt_dtype (            {process DTYPE syntax}
  out     dtype: code_dtype_t);        {data type to fill in}
  val_param;

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  sym_p: code_symbol_p_t;              {scratch symbol pointer}

label
  have_dtype;

begin
  if not syn_trav_next_down (syn_p^) then begin {down into DTYPE syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;

  code_dtype_init (dtype);             {init returned data type to benign or default}

  tag := syn_trav_next_tag (syn_p^);   {get tag for top level data type}
  case tag of                          {which top level data type is it ?}
{
*   QNAME.  Tag is name of another data type symbol.
}
1: begin
  mcomp_syt_qname (                    {process QNAME syntax}
    [code_symtype_dtype_k],            {set of allowable symbol types}
    sym_p);                            {returned pnt to symbol, NIL = not found}




  end;
{
*   INTEGER.
}
2: begin
  dtype.typ := code_typid_int_k;       {set to INT data type}
  dtype.bits_min := code_p^.default.int_bits; {init number of bits to default}
  dtype.int_sign := false;             {init to unsigned}
  dtype.int_exactbits := false;        {init to not exactly BITS_MIN bits}

  while true do begin                  {back here each new INTEGER tag}
    tag := syn_trav_next_tag (syn_p^); {get INTEGER parameter tag}
    case tag of                        {which INTEGER parameter ?}
1:    begin                            {SIGNED}
        dtype.int_sign := true;
        end;
2:    begin                            {BITS n}
        dtype.bits_min := mcomp_syt_integer;
        end;
3:    begin                            {BITSEXACT n}
        dtype.bits_min := mcomp_syt_integer;
        dtype.int_exactbits := true;
        end;
syn_tag_end_k: begin
      goto have_dtype;
      end;
otherwise
      syn_msg_pos_bomb (syn_p^, '', 'type_int_bad', nil, 0);
      end;
    end;                               {back to get next INTEGER parameter}
  end;
{
*   Unexpected or invalid top level DTYPE tag.
}
otherwise
    syn_msg_tag_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;

have_dtype:                            {syntax was valid, DTYPE all filled in}
  if not syn_trav_up (syn_p^) then begin {back up to parent syntax level}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;
  end;
