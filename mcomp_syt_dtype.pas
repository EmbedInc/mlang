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
  dtype_p: code_dtype_p_t;             {to dtype specified by TYPE substatement}
  sym_p: code_symbol_p_t;              {to new data type symbol}

begin
  name.max := size_char(name.str);     {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into TYPE_SUB syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_bad', nil, 0);
    end;
{
*   Create the new data type symbol.
}
  tag := syn_trav_next_tag (syn_p^);   {get tag for name of data type being defined}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_name_bad', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get name of data type being defined}
  code_dtype_sym_new (code_p^, name, sym_p); {create new data type symbol}
  syn_trav_tag_start (syn_p^, sym_p^.pos); {save source code position}
  code_comm_find (                     {tag the new structure with comment, if any}
    code_p^,                           {CODE library use state}
    mcomp_currline,                    {current global sequential source line number}
    currlevel,                         {current nesting level}
    sym_p^.comm_p);                    {returned pointer to comments}
{
*   Process the data type syntax.
}
  tag := syn_trav_next_tag (syn_p^);   {get tag for data type definition or reference}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;

  mcomp_syt_dtype (dtype_p);           {get pointer to found or created data type}
  code_dtype_sym_set (code_p^, sym_p^, dtype_p^); {assign data type to symbol}
  code_comm_find (                     {tag the new structure with comment, if any}
    code_p^,                           {CODE library use state}
    mcomp_currline,                    {current global sequential source line number}
    currlevel,                         {current nesting level}
    sym_p^.dtype_dtype_p^.comm_p);     {returned pointer to comments}

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
*   Subroutine MCOMP_SYT_DTYPE (DTYPE_P)
*
*   Process the DTYPE syntax and return DTYPE_P pointing to the data type the
*   DTYPE syntax specifies.  DTYPE_P may be returned a pointer to an existing
*   data type that matches the specification, or a newly created data type
*   descriptor.  In the latter case, the new data type descriptor will not have
*   a symbol associated with it.
}
procedure mcomp_syt_dtype (            {process DTYPE syntax}
  out     dtype_p: code_dtype_p_t);    {to found or created data type, never NIL}
  val_param;

const
  max_msg_args = 1;                    {max arguments we can pass to a message}

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  sym_p: code_symbol_p_t;              {scratch symbol pointer}
  pos: syn_treepos_t;                  {scratch syntax tree traversing position}
  dt: code_dtype_t;                    {scratch internal data type descriptor}
  name: string_var80_t;                {scratch string}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;

label
  int_dsyn;

begin
  name.max := size_char(name.str);     {init local var string}
  dtype_p := nil;                      {init to return pointer not set yet}

  if not syn_trav_next_down (syn_p^) then begin {down into DTYPE syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for top level data type}
  case tag of                          {which top level data type is it ?}
{
*   QNAME.  Tag is name of another data type symbol.
}
1: begin
  syn_trav_save (syn_p^, pos);         {save position at start of dtype symbol ref}
  mcomp_syt_qname (                    {process QNAME syntax}
    [code_symtype_dtype_k],            {set of allowable symbol types}
    sym_p);                            {returned pnt to symbol, NIL = not found}
  if sym_p = nil then begin            {no such data type ?}
    syn_trav_goto (syn_p^, pos);       {go back to start of data type sym reference}
    syn_trav_tag_string (syn_p^, name); {get the data type sym reference string}
    sys_msg_parm_vstr (msg_parm[1], name);
    syn_msg_pos_bomb (syn_p^, '', 'type_sym_nfnd', msg_parm, 1);
    end;

  dtype_p := sym_p^.dtype_dtype_p;     {return symbol's data type}
  if dtype_p = nil then begin          {symbol doesn't have data type set ?}
    syn_trav_goto (syn_p^, pos);       {go back to start of data type sym reference}
    syn_trav_tag_string (syn_p^, name); {get the data type sym reference string}
    sys_msg_parm_vstr (msg_parm[1], name);
    syn_msg_pos_bomb (syn_p^, '', 'type_sym_ndef', msg_parm, 1);
    end;
  end;
{
*   INTEGER.
}
2: begin
  code_dtype_init (dt);                {init temp data type descriptor}
  dt.typ := code_typid_int_k;          {set to INT data type}
  dt.bits_min := code_p^.default.int_bits; {init number of bits to default}
  dt.int_sign := false;                {init to unsigned}
  dt.int_exactbits := false;           {init to not exactly BITS_MIN bits}

  while true do begin                  {back here each new INTEGER tag}
    tag := syn_trav_next_tag (syn_p^); {get INTEGER parameter tag}
    case tag of                        {which INTEGER parameter ?}
1:    begin                            {SIGNED}
        dt.int_sign := true;
        end;
2:    begin                            {BITS n}
        dt.bits_min := mcomp_syt_integer;
        end;
3:    begin                            {BITSEXACT n}
        dt.bits_min := mcomp_syt_integer;
        dt.int_exactbits := true;
        end;
syn_tag_end_k: begin
      goto int_dsyn;
      end;
otherwise
      syn_msg_pos_bomb (syn_p^, '', 'type_int_bad', nil, 0);
      end;
    end;                               {back to get next INTEGER parameter}

int_dsyn:                              {done processing INTEGER syntax}
  code_dtype_int_find (code_p^, dt, dtype_p); {return pnt to base int type}
  end;
{
*   Unexpected or invalid top level DTYPE tag.
}
otherwise
    syn_msg_tag_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;

  if dtype_p = nil then begin          {trying to return NIL pointer ?}
    syn_msg_pos_bomb (syn_p^, '', 'syt_dtype_nil', nil, 0);
    end;

  if not syn_trav_up (syn_p^) then begin {back up to parent syntax level}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;
  end;
