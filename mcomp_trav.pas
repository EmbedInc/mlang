{   Routines to aid in traversing the syntax tree.
}
module mcomp_trav;
define mcomp_trav_up;
define mcomp_trav_end_up;
define mcomp_trav_next_end_up;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_TRAV_UP
*
*   Pop up to the parent syntax tree level.  Nothing is done if already at the
*   top level.
}
procedure mcomp_trav_up;               {to parent level}
  val_param;

begin
  discard( syn_trav_up (syn_p^) );
  end;
{
********************************************************************************
*
*   Function MCOMP_TRAV_END_UP
*
*   Pop up from the current syntax tree level to its parent.  The current syntax
*   tree entry must be end of level.
*
*   The function returns TRUE only to indicate an error, in which case an error
*   message is also written to STDOUT.  The possible error conditions are that
*   the original position was not at the end of a syntax level, or that there is
*   no parent level.
}
function mcomp_trav_end_up             {up to parent syntax, curr tag must be end}
  :boolean;                            {success, no error message written}
  val_param;

begin
  mcomp_trav_end_up := false;          {init to returning with error}

  if syn_trav_type(syn_p^) <> syn_tent_end_k then begin {not at end ?}
    syn_msg_tag_err (syn_p^, '', '', nil, 0);
    return;
    end;

  if not syn_trav_up (syn_p^) then begin {failed to pop to parent level ?}
    syn_msg_pos (syn_p^, '', '', nil, 0);
    return;
    end;

  mcomp_trav_end_up := true;           {indicate success}
  end;
{
********************************************************************************
*
*   Function MCOMP_TRAV_NEXT_END_UP
*
*   Pop up from the current syntax tree level to its parent.  The next syntax
*   tree entry must be end of level.
*
*   The function returns TRUE only to indicate an error, in which case an error
*   message is also written to STDOUT.  The possible error conditions are that
*   the original position was not immediately before the end of a syntax level,
*   or that there is no parent level.
}
function mcomp_trav_next_end_up        {up to parent syntax, next tag must be end}
  :boolean;                            {success, no error message written}
  val_param;

begin
  mcomp_trav_next_end_up := false;     {init to returning with error}

  if syn_trav_next(syn_p^) <> syn_tent_end_k then begin {not at end ?}
    syn_msg_tag_err (syn_p^, '', '', nil, 0);
    return;
    end;

  if not syn_trav_up (syn_p^) then begin {failed to pop to parent level ?}
    syn_msg_pos (syn_p^, '', '', nil, 0);
    return;
    end;

  mcomp_trav_next_end_up := true;      {indicate success}
  end;
