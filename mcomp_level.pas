{   Routines to maintain the nesting hierarchy of statements.
*
*   LEVEL_P points to the data for the hierachy chain of nested statements, with
*   the first descriptor being for the current statement.  This list is updated
*   whenever the start of a new statement is found in MCOMP_SYN_STLEVEL.
*   LEVEL_SET indicates this has been done since the last parse, and that the
*   parsing position is at the first content character of the next statement.
*   The level of the next statement is therefore LEVEL_P^.LEVEL whenever
*   LEVEL_SET is TRUE.
*
*   This is different from CURRLEVEL, which indicates the current nesting level
*   expected by tree-traversing code.  MCOMP_PARSE_STATEMENT compares the level
*   of the next statement to the expected level to determine how to hanlde the
*   next statement.
*
*   CURRLEVEL is updated explicitly by tree-traversing code to adjust the
*   expected nesting level.  LEVEL_P^.LEVEL is updated automatically when the
*   start of a new statement is found.  The hierarchy of statements indicated
*   by the chain at LEVEL_P indicates the blocks the current parsing position is
*   within.  This is usually not directly needed for understanding the code, but
*   can be useful for emitting helpful error messages.
}
module mcomp_level;
define mcomp_level;
define mcomp_level_set;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine LEVEL_ALLOC (LEV_P)
*
*   Allocate a level descriptor and return LEV_P pointing to it.
*
*   Level descriptors are allocated as permanent memory under the program memory
*   context.  Instead of deallocating level descriptors when no longer needed,
*   they are added to a list of unused descriptors.  This routine takes an
*   unused descriptor from the list, if available.
}
procedure level_alloc (                {allocate level descriptor}
  out     lev_p: mcomp_level_p_t);     {returned pointer to the new descriptor}
  val_param; internal;

begin
  if level_unused_p <> nil then begin  {there are unused descriptors available ?}
    lev_p := level_unused_p;           {grab the first descriptor in the list}
    level_unused_p := lev_p^.prev_p;   {unlink it from the list}
    lev_p^.prev_p := nil;              {clean link from returned descriptor}
    return;
    end;

  util_mem_grab (                      {allocate new memory for the descriptor}
    sizeof(lev_p^),                    {amount of memory to allocate}
    mem_p^,                            {memory context to allocate under}
    false,                             {will not be individually deallocable}
    lev_p);                            {returned pointer to the new memory}
  end;
{
********************************************************************************
*
*   Local subroutine LEVEL_DEALLOC (LEV_P)
*
*   Deallocate the level descriptor pointed to by LEV_P.  LEV_P is returned NIL.
*
*   Deallcoated descriptors are actually put on a list, from which they will be
*   re-used when new descriptor is needed.
}
procedure level_dealloc (              {deallocate level descriptor}
  in out  lev_p: mcomp_level_p_t);     {pointer to descriptor, returned NIL}
  val_param; internal;

begin
  lev_p^.prev_p := level_unused_p;     {link this descriptor to the unused list}
  level_unused_p := lev_p;
  lev_p := nil;                        {return caller's pointer as invalid}
  end;
{
********************************************************************************
*
*   Local subroutine MCOMP_LEVEL_PUSH
*
*   Create a new empty statement nesting level descriptor and make it current.
*   The new descriptor will be linked to the start of the hierarchy list and
*   its level set, but no other content will be set.
}
procedure mcomp_level_push;            {enter subordinate statements level}
  val_param; internal;

var
  lev_p: mcomp_level_p_t;              {to descriptor for the new level}

begin
  level_alloc (lev_p);                 {allocate memory for the new descriptor}
  lev_p^.prev_p := level_p;            {link back to previous level}
  if level_p = nil
    then begin                         {creating top level descriptor}
      lev_p^.level := 0;
      end
    else begin                         {creating subordinate level descriptor}
      lev_p^.level := level_p^.level + 1;
      end
    ;
  level_p := lev_p;                    {make this new level current}
  end;
{
********************************************************************************
*
*   Local subroutine MCOMP_LEVEL_POP
*
*   Remove the current nested statement level data.  The current level will be
*   the original parent level.
}
procedure mcomp_level_pop;             {pop up to parent statements level}
  val_param; internal;

var
  lev_p: mcomp_level_p_t;              {to old level descriptor}

begin
  if level_p = nil then return;        {above all levels, nothing to do ?}

  lev_p := level_p;                    {temp save pointer to old level}
  level_p := lev_p^.prev_p;            {pop back to previous level}
  level_dealloc (lev_p);               {deallocate old level descriptor}
  end;
{
********************************************************************************
*
*   Function MCOMP_LEVEL
*
*   Return the nesting level of the statement being currently parsed.  The level
*   is 0 in a top-level statement, and one more for each subordinate level.  The
*   special value of -1 is returned when not in any statement, effectively
*   meaning the current position is above all levels.
}
function mcomp_level                   {get nesting level of statement currently in}
  :sys_int_machine_t;                  {nesting level, 0 in top level statement}
  val_param;

begin
  if level_p = nil
    then begin                         {no current level, above all levels ?}
      mcomp_level := -1;
      end
    else begin                         {in a statement}
      mcomp_level := level_p^.level;
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_LEVEL_SET (LEVEL)
*
*   Set the current nested statements state to the level LEVEL, which is assumed
*   to start at the current parsing position.  This routine must not be called
*   with LEVEL more than one level greater than the current level.
}
procedure mcomp_level_set (            {update nested levels state to curr position}
  in      level: sys_int_machine_t);   {nesting level of the statement at start of}
  val_param;

label
  error;

begin
  if level_p = nil
    then begin                         {currently above all levels}
      if level <> 0 then goto error;   {not going to the top level ?}
      mcomp_level_push;                {create the top level descriptor}
      end
    else begin                         {we are in an existing statement}
      if level > (level_p^.level + 1)  {trying to skip down two or more levels ?}
        then goto error;
      if level > level_p^.level
        then begin                     {going down one level}
          mcomp_level_push;            {create the descriptor for the new level}
          end
        else begin                     {going to same or higher level}
          while level_p^.level <> level do begin {pop up to the desired level}
            mcomp_level_pop;
            end;
          end
        ;
      end
    ;
{
*   LEVEL_P points to the descriptor for the desired level.\
*
*   Now fill in the descriptor with the current position.
}
  syn_p_cpos_get (syn_p^, level_p^.pos); {save pos at start of new level statement}
  level_set := true;                   {indicate level set since last parse}
  return;                              {normal return, no error}
{
*   The caller attempted to jump down more than one level.  This is impossible
*   and indicates an internal error.
}
error:
  writeln;
  writeln ('INTERNAL ERROR: Attempt to jump down more than one level in MCOMP_LEVEL_SET.');
  mcomp_err_atline ('', '', nil, 0);   {bomb program showing current parse position}
  end;
