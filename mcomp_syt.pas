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
*   level.  Any SYT routine not following this convention must be clearly marked
*   so.
}
module mcomp_syt;
define mcomp_syt_statement;
%include 'mcomp.ins.pas';
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

  {*** NOT IMPLEMENTED YET, temp code ***}

  if not syn_trav_next_down (syn_p^) then begin {down into STATEMENT}
    syn_msg_pos_bomb (syn_p^, '', '', nil, 0);
    end;

  tag := syn_trav_next_tag(syn_p^);    {get first mandatory tag}
  write ('Tag ', tag, ': ');
  case tag of
syn_tag_end_k: write ('END');
syn_tag_err_k: write ('ERR');
syn_tag_sub_k: write ('SUB');
syn_tag_lev_k: write ('LEV');
1:  write ('EOD');
2:  write ('memory');
3:  write ('address');
4:  write ('address');
5:  write ('adrregion');
6:  write ('set');
otherwise
    write ('-- unknown --');
    end;
  writeln;

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
