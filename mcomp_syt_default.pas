{   Process DEFAULT statement.
}
module mcomp_syt_default;
define mcomp_syt_default_;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine MCOMP_SYT_DEFAULT_SUB
*
*   Process the syntax tree for one DEFAULT block substatement.
}
procedure mcomp_syt_default_sub;
  val_param; internal;

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  scopedat_p: mcomp_scopedat_p_t;      {to our data for the current scope}
  name: mcomp_name_t;                  {name of data type being defined}

begin
  name.max := size_char(name.str);     {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into DEFAULT_SUB syntax}
    syn_msg_pos_bomb (syn_p^, '', 'default_bad', nil, 0);
    end;

  tag := syn_trav_next_tag (syn_p^);   {get tag for which substatement}
  case tag of                          {which substatement is it ?}
{
*   INTBITS int
}
1: begin
  scopedat_p := mcomp_scopedat;        {get pnt to our data for curr scope}
  scopedat_p^.default.intbits :=       {get int value, set new def int bit size}
    mcomp_syt_integer;
  end;
{
*   IN memregion
}
2: begin
  scopedat_p := mcomp_scopedat;        {get pnt to our data for curr scope}
  mcomp_syt_name_memreg (              {process NAME syntax to get memory region}
    scopedat_p^.default.memreg_p);     {returned pointer to memory region or NIL}
  if scopedat_p^.default.memreg_p = nil then begin {no such memory region ?}
    mcomp_err_atline ('', 'default_in_err', nil, 0);
    end;
  end;
{
*   Unexpected substatement ID tag.
}
otherwise
    syn_msg_pos_bomb (syn_p^, '', 'default_bad', nil, 0);
    end;                               {end of DEFAULT substatement cases}

  if syn_trav_next_tag(syn_p^) <> syn_tag_end_k then begin
    syn_msg_tag_bomb (syn_p^, '', 'default_bad', nil, 0);
    end;

  if not syn_trav_up (syn_p^) then begin {back up to parent syntax level}
    syn_msg_pos_bomb (syn_p^, '', 'default_bad', nil, 0);
    end;
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_DEFAULT_
*
*   Process the syntax tree of a DEFAULT statement.
}
procedure mcomp_syt_default_;          {process DEFAULT statement block}
  val_param;

begin
  mcomp_parse_block (                  {process the substatements in the TYPE block}
    addr(mcomp_syn_default),           {address of syntax checking routine}
    addr(mcomp_syt_default_sub));      {routine to walk and process resulting syntax trees}
  end;
