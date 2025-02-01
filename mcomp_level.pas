module mcomp_level;
define mcomp_level_none;
define mcomp_level_push;
define mcomp_level_pop;
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
*   Subroutine MCOMP_LEVEL_NONE
*
*   Set the block statement nesting state to above all levels.  The next
*   statement must be at the top level.
}
procedure mcomp_level_none;            {set above all levels, next statement top level}
  val_param;

begin
  while level_p <> nil do begin        {release levels until there are none}
    mcomp_level_pop;
    end;

  currlevel := -1;                     {indicate above all levels}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_LEVEL_PUSH
*
*   Update the block statement nesting state to one level down.  The statement
*   to start a new block is assumed to start at the current parsing position.
}
procedure mcomp_level_push;            {enter subordinate statements level}
  val_param;

var
  lev_p: mcomp_level_p_t;              {to descriptor for the new level}

begin
  level_alloc (lev_p);                 {create descriptor for the new level}
  lev_p^.prev_p := level_p;            {link back to previous level}
  lev_p^.level := currlevel + 1;       {one level down from parent}
  syn_p_cpos_get (syn_p^, lev_p^.pos); {save start position for this level}

  currlevel := lev_p^.level;           {update current nesting level to one deeper}
  level_p := lev_p;                    {make this new level current}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_LEVEL_POP
*
*   Pop back to the parent nested statement blocks level.
}
procedure mcomp_level_pop;             {pop up to parent statements level}
  val_param;

var
  lev_p: mcomp_level_p_t;              {to old level descriptor}

begin
  if level_p = nil then return;        {above all levels, nothing to do ?}

  lev_p := level_p;                    {temp save pointer to old level}
  level_p := lev_p^.prev_p;            {pop back to previous level}
  if level_p = nil                     {update current nesting level}
    then currlevel := -1
    else currlevel := level_p^.level;

  level_dealloc (lev_p);               {deallocate old level descriptor}
  end;
