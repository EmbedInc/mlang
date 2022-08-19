{   Routines for traversing the syntax tree for various syntax constructions.
*   These routines are all named MCOMP_SYTS_xxx or MCMP_SYTL_XXX, where XXX is
*   the name of the syntax construction expected to be on the tree.  This module
*   contains the "small" syntax tree traversing routines.  Larger and more
*   complicated syntax tree traversing routines are in their own module.
*
*   The syntax tree traversing routines can either expect to be at the start of
*   the syntax, or in a parent syntax at the down-link to the nested syntax.
*   Which starting position each routine expects is denoted in the name.  The
*   MCOMP_SYTS_xxx routines assume the position is the start of their syntax,
*   and MCOMP_SYTL_xxx at the link down to their syntax.
}
module mcomp_syt;
define mcomp_sytl_statement;
define mcomp_syts_statement;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_SYTL_STATEMENT
*
*   Process the STATEMENT syntax.  The current position is the link to the
*   STATEMENT subordinate level.
}
procedure mcomp_sytl_statement;
  val_param;

begin
  if not syn_trav_down (syn_p^) then return; {no subordinate level here ?}
  mcomp_syts_statement;                {process STATEMENT from current level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYTS_STATEMENT_LEV
*
*   Process the STATEMENT syntax.  The current position is at the start of the
*   STATEMENT level.
}
procedure mcomp_syts_statement;
  val_param;

begin

  {*** NOT IMPLEMENTED YET ***}

  end;
