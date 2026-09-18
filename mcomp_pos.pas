{   Routines related to source code positions.
}
module mcomp_pos;
define mcomp_pos_set;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_POS_SET (POS)
*
*   Set POS to the source code position of the current syntax tree entry.
}
procedure mcomp_pos_set (              {save current source code position}
  out     pos: fline_cpos_t);          {position descriptor to write to}
  val_param;

begin
  syn_trav_tag_start (syn_p^, pos);    {get the position into POS}
  end;
