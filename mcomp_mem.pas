{   Memory management.
}
module mcomp_mem;
define mcomp_mem_perm;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_MEM_PERM (SIZE, NEW_P)
*
*   Allocate memory under the program's private memory context.  The new memory
*   can not be deallocated later.  It is only deallocated when the memory
*   context is deleted.  No additional memory is used per block allocated.
*
*   SIZE is the requested size of the new memory, and NEW_P is returned pointing
*   to the start address of the newly allocated region.
}
procedure mcomp_mem_perm (             {get new memory, can't deallocate later}
  in      size: sys_int_adr_t;         {min size of new memory, bytes}
  out     new_p: univ_ptr);            {returned pointer to the new memory}
  val_param;

var
  stat: sys_err_t;                     {error status}

begin
  util_mem_grab (                      {allocate the new memory}
    size,                              {amount of memory required}
    mem_p^,                            {context to allocate the memory under}
    false,                             {will not need to individually deallocate}
    new_p);                            {returned pointer to the new memory}

  if new_p <> nil then return;         {got the memory ?}
  discard( util_mem_grab_err (new_p, size, stat) ); {set STAT to indicate the error}
  sys_error_print (stat, '', '', nil, 0); {write error message}
  sys_bomb;                            {abort program with error status}
  end;
