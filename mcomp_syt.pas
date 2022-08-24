{   Routines for traversing the syntax tree for various syntax constructions.
*   These routines are all named MCOMP_SYT_xxx, where XXX is the name of the
*   syntax construction expected to be on the tree.
*
*   This module contains the "small" syntax tree traversing routines.  Larger
*   and more complicated syntax tree traversing routines are in their own
*   module.
*
*   Most syntax tree traversing routines expect the current position to be at
*   the entry immediately before the downlink to the syntax construction the
*   routine is supposed to interpret.  When done, the routine leaves the
*   position at the downlink.  This apprears to advance one entry at the current
*   level.  In any case, syntax interpretation routines should leave the syntax
*   tree position so that the next tree entry is the next thing to process.  For
*   example if the next expected tree item is a tag, the calling routine should
*   be able to call SYN_TRAV_NEXT_TAG immediately after the previous syntax
*   interpretation routine returns.
}
module mcomp_syt;
define mcomp_currline;
define mcomp_syt_integer;
define mcomp_syt_accesstype;
define mcomp_syt_statement;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Function MCOMP_CURRLINE
*
*   Returns the globally unique source line number for the current syntax tree
*   position.
}
function mcomp_currline                {get line number of current syntax tree position}
  :sys_int_machine_t;
  val_param;

var
  pos: fline_cpos_t;                   {input stream position}

begin
  mcomp_currline := 0;                 {init return value to unknown line}

  syn_trav_pos (syn_p^, pos);          {get position for current syntax tree entry}

  if pos.line_p = nil then return;     {no source line indicated ?}
  mcomp_currline := pos.line_p^.lnum;  {return the globally unique line number}
  end;
{
********************************************************************************
*
*   Function MCOMP_SYT_INTEGER
*
*   Interpret the INTEGER syntax and return the resulting value.
}
function mcomp_syt_integer             {interpret INTEGER syntax}
  :sys_int_max_t;
  val_param;

var
  tk: string_var32_t;                  {integer token}
  ii: sys_int_max_t;                   {the integer value}
  stat: sys_err_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  syn_trav_tag_string (syn_p^, tk);    {get the integer string}
  string_t_int_max (tk, ii, stat);     {convert string to integer}
  syn_error_bomb (syn_p^, stat, '', '', nil, 0);
  mcomp_syt_integer := ii;             {pass back the integer value}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_ACCESSTYPE (ACCS, PARENT)
*
*   Interpret the ACCESSTYPE syntax.  ACCS is the list of accesses to modify.
*   PARENT are the parent's accesses.
}
procedure mcomp_syt_accesstype (       {interpret ACCESSTYPE syntax}
  in out  accs: code_memaccs_t;        {access list to update}
  in      parent: code_memaccs_t);     {parent code accsibutes}
  val_param;

var
  tag: sys_int_machine_t;              {syntax tag ID}
  remove: boolean;                     {removed new accesses instead of adding them}
  accnew: code_memaccs_t;              {accesses to add or remove}
  acc: code_memaccs_t;                 {scratch accesses}

begin
  if not syn_trav_next_down (syn_p^) then begin {down into ACCESSTYPE syntax}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'accty_err', nil, 0);
    end;

  accs := [];                          {init to no access}
  while true do begin                  {loop thru the options}

    tag := syn_trav_next_tag (syn_p^); {get tag for optional preceeding "-"}
    case tag of
syn_tag_end_k: begin                   {end of options}
        discard( syn_trav_up (syn_p^) ); {back up to parent level}
        return;
        end;
1:    remove := false;
2:    remove := true;
otherwise
      syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'accty_err', nil, 0);
      end;

    accnew := [];                      {init to no accesses being added or removed}
    tag := syn_trav_next_tag (syn_p^); {get tag for the access type}
    case tag of                        {which access is it ?}
1:    begin                            {READ}
        accnew := [code_memaccs_rd_k];
        end;

2:    begin                            {WRITE}
        accnew := [code_memaccs_wr_k];
        end;

3:    begin                            {EXECUTE}
        accnew := [code_memaccs_ex_k];
        end;

4:    begin                            {INHERIT}
        accnew := parent;
        end;
otherwise                              {unexpected tag}
      syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'accty_err', nil, 0);
      end;                             {end of tag cases}

    if not remove then begin           {adding accesses, not removing them ?}
      acc := accnew - parent;          {access trying to add but not in parent}
      if not (acc = []) then begin     {tring to add unavailable access}
        syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'accty_npar', nil, 0); {bomb with error}
        end;
      end;

    if remove
      then begin                       {remove the new accesses in ACCNEW}
        accs := accs - accnew;
        end
      else begin                       {add the new accesses in ACCNEW}
        accs := accs + accnew;
        end
      ;
    end;                               {back to get next command option}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_STATEMENT
*
*   Interpret STATEMENT syntax.
}
procedure mcomp_syt_statement;
  val_param;

var
  tag: sys_int_machine_t;              {syntax tag ID}

begin
  if not syn_trav_next_down (syn_p^) then begin {down into STATEMENT}
    syn_msg_pos_bomb (syn_p^, '', '', nil, 0);
    end;

  tag := syn_trav_next_tag(syn_p^);    {get first mandatory tag}
  case tag of                          {what kind of statement ?}
1:  begin                              {end of data}
      return;
      end;
2:  begin                              {MEMORY}
      mcomp_syt_memory_;
      end;
3:  begin                              {MEMREGION}
      mcomp_syt_memregion_;
      end;
4:  begin                              {ADRSPACE}
      mcomp_syt_adrspace_;
      end;
5:  begin                              {ADRREGION}
      mcomp_syt_adrregion_;
      end;
6:  begin                              {SET (assignment)}
      end;
otherwise                              {unexpected tag}
    syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'statement_bad', nil, 0);
    end;

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
