{   Routines for traversing the syntax tree for various syntax constructions.
*   These routines are all named MCOMP_SYT_xxx, where XXX is the name of the
*   syntax construction expected to be on the tree.  This module contains the
*   "small" syntax tree traversing routines.  Larger and more complicated syntax
*   tree traversing routines are in their own module.
*
*   The current syntax tree entry is assumed to be the the down-link to the
*   subordinate level for the particular syntax.  If the subroutine name has
*   "_lev" appended to it, then the current position is assumed to be the start
*   of the particular syntax.
}
module mcomp_syt;
define mcomp_syt_statement;
define mcomp_syt_statement_lev;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_STATEMENT
*
*   Process the STATEMENT syntax.  The current position is the link to the
*   STATEMENT subordinate level.
}
procedure mcomp_syt_statement;
  val_param;

begin
  if not syn_trav_down (syn_p^) then return; {no subordinate level here ?}
  mcomp_syt_statement_lev;             {process STATEMENT from current level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_STATEMENT_LEV
*
*   Process the STATEMENT syntax.  The current position is at the start of the
*   STATEMENT level.
}
procedure mcomp_syt_statement_lev;
  val_param;

begin
  end;
