{   Manage program global state.
}
module mcomp_global;
define mcomp_global_init;
define mcomp_global_end;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_GLOBAL_INIT (MEM)
*
*   Initialize the MCOMP program global state.  MEM is the parent memory context
*   to allocate the private program state memory context under.
}
procedure mcomp_global_init (          {init global MCOMP program state}
  in out  mem: util_mem_context_t);    {parent mem context, will create subordinate}
  val_param;

begin
  util_mem_context_get (mem, mem_p);   {create our private memory context}

  fline_p := nil;
  coll_p := nil;
  syn_p := nil;
  code_p := nil;
  currlevel := -1;
  level_p := nil;
  level_unused_p := nil;
  level_set := false;
  errsyn := false;
  show_tree := false;
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_GLOBAL_END
*
*   End the current use of the global state.  Resources allocated to the global
*   state will be released, and the global state will be left invalid.
}
procedure mcomp_global_end;            {end use of global state, release resources}
  val_param;

begin
  if code_p <> nil then begin
    code_lib_end (code_p);
    end;

  if syn_p <> nil then begin
    syn_lib_end (syn_p);
    end;

  if fline_p <> nil then begin
    fline_lib_end (fline_p);
    end;

  if mem_p <> nil then begin
    util_mem_context_del (mem_p);
    end;
  end;
