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
  dtype_p: code_dtype_p_t;             {to data type being assigned to NAME}

begin
  if not syn_trav_next_down (syn_p^) then begin {down into TYPE_SUB syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_bad', nil, 0);
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for name of data type being defined}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_name_bad', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get name of data type being defined}

  tag := syn_trav_next_tag (syn_p^);   {get for data type definition or reference}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;
  mcomp_syt_dtype (dtype_p);           {process DTYPE syntax, return pnt to data type}



  writeln ('Defined data type "', name.str:name.len, '"');


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
*   Process the DTYPE syntax and return a pointer to the data type being
*   described.
}
procedure mcomp_syt_dtype (            {process DTYPE syntax}
  out     dtype_p: code_dtype_p_t);    {returned pointer to resulting data type}
  val_param;

begin
  if not syn_trav_next_down (syn_p^) then begin {down into DTYPE syntax}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;


  dtype_p := nil;                      {placeholder for now}


  if not syn_trav_up (syn_p^) then begin {back up to parent syntax level}
    syn_msg_pos_bomb (syn_p^, '', 'type_def_bad', nil, 0);
    end;
  end;
