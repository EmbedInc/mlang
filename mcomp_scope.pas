{   Routines that handle nested scopes as defined in the CODE library.
}
module mcomp_scope;
define mcomp_scope_new_callback;
define mcomp_scopedat;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine SCOPEDAT_INIT (SCOPEDAT)
*
*   Initialize the per-scope data SCOPEDAT to global hard-coded defaults.
}
procedure scopedat_init (              {init per-scope data to hard coded defaults}
  out     scopedat: mcomp_scopedat_t); {descriptor to initialize}
  val_param; internal;

begin
  mcomp_global_scope_default (scopedat.default);
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SCOPE_NEW_CALLBACK (CODE_P, CALLBACK_P, SCOPE)
*
*   This routine is called automatically by the CODE library whenever a new
*   scope is created.  CODE_P points to the CODE library use state.  CALLBACK_P
*   is not used in this implementation.  SCOPE is the newly created scope.
}
procedure mcomp_scope_new_callback (   {called from CODE lib when new scope created}
  in      code_p: code_p_t;            {to CODE library use state}
  in      callback_p: univ_ptr;        {to private app callback data, unused}
  in out  scope: code_scope_t);        {newly created scope}
  val_param;

var
  scopedat_p: mcomp_scopedat_p_t;      {to our private data for this scope}
  pardat_p: mcomp_scopedat_p_t;        {to our private data in parent scope}

begin
  code_alloc_global (                  {alloc mem for our data for this scope}
    code_p^, sizeof(scopedat_p^), scopedat_p);

  if scope.parscope_p = nil
    then begin                         {no parent scope, this is root scope}
      scopedat_init (scopedat_p^);     {init to hard-coded original defaults}
      end
    else begin                         {have parent scope, inherit from it}
      pardat_p := scope.parscope_p^.app_p; {get pointer to our data in parent scope}
      scopedat_p^ := pardat_p^;        {init data for new scope from parent}
      end
    ;

  scope.app_p := scopedat_p;           {save pointer to our private data in this scope}
  end;
{
********************************************************************************
*
*   Function MCOMP_SCOPEDAT
*
*   Return the pointer to the our private data for the current scope.  In our
*   implementation, every scope has private data managed by this program.  It is
*   therefore a hard error if this data does not exist.
}
function mcomp_scopedat                {get pointer to private data for curr scope}
  :mcomp_scopedat_p_t;                 {to our private data for curr scope, never NIL}
  val_param;

begin
  if code_p^.scope_p = nil then begin  {no current scope ?}
    sys_message_bomb ('', 'scope_none', nil, 0);
    end;

  if code_p^.scope_p^.app_p = nil then begin {no private data for current scope ?}
    mcomp_err_atline ('', 'scope_nodat', nil, 0);
    end;

  mcomp_scopedat := code_p^.scope_p^.app_p; {return pointer to private data this scope}
  end;
