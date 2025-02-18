module mcomp_syt_qname;
define mcomp_syt_qname;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local function SYT_QNENT (NUP, SYNAME, TYNAME)
*
*   Process the QNENT syntax, which is one list entry in a qualified symbol
*   name.  This syntax can specify either a number of scope levels to pop up, or
*   a symbol name with an optional symbol type.
*
*   When a number of levels to pop up is specified, then the function returns
*   FALSE and NUP is set to the number of levels to pop.   Both SYNAME and
*   TYNAME are the empty string.
*
*   When a symbol name was specified, then the function returns TRUE and SYNAME
*   is set to the symbol name.  TYNAME the optional symbol type name, and is the
*   empty string when no symbol type name was given.  NUP is always set to 0.
}
function syt_qnent (                   {process QNENT syntax}
  out     nup: sys_int_machine_t;      {number of levels to pop up}
  in out  syname: univ string_var_arg_t; {symbol name}
  in out  tyname: univ string_var_arg_t) {symbol type ID name}
  :boolean;                            {got symbol name, not levels to pop}
  val_param; internal;

begin
  nup := 0;                            {init to no levels to pop}
  syname.len := 0;                     {init to no symbol name}
  tyname.len := 0;                     {init to no symbol type name}
  syt_qnent := true;                   {init to returning with symbol name}

  if not syn_trav_down (syn_p^) then begin {down into QNENT syntax}
    syn_msg_pos_bomb (syn_p^, '', 'qname_ent_bad', nil, 0);
    end;

  while true do begin                  {process each of the QNENT tags}
    case syn_trav_next_tag(syn_p^) of  {which tag is it ?}
1:    begin                            {number of scope levels to pop up}
        nup := mcomp_syt_integer;      {get the number of levels}
        syt_qnent := false;            {indicate got levels to pop}
        end;
2:    begin                            {symbol name}
        syn_trav_tag_string (syn_p^, syname); {get the symbol name}
        end;
3:    begin
        syn_trav_tag_string (syn_p^, tyname); {get the symbol type name}
        end;
syn_tag_end_k: ;                       {normal syntax end}
otherwise
      syn_msg_tag_bomb (syn_p^, '', 'qname_ent_bad', nil, 0);
      end;                             {end of tag cases}
    end;                               {back to get next tag}

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
{
********************************************************************************
*
*   Local subroutine UPDATE_SCOPE (SCOPE_P, SYNAME, TYNAME)
*
*   Update the current scope, pointed to by SCOPE_P, to the new symbol name
*   SYNAME.  TYNAME is the symbol type name when not the empty string.  The
*   qualified symbol name entry where SYNAME and TYNAME came from is not the
*   last entry.
}
procedure update_scope (               {update scope to not-last entry}
  in out  scope_p: code_scope_p_t;     {current scope, updated as appropriate}
  in      syname: univ string_var_arg_t; {name of symbol from this entry}
  in      tyname: univ string_var_arg_t); {symbol type name when not empty}
  val_param; internal;

const
  max_msg_args = 2;                    {max arguments we can pass to a message}

var
  sytypes: code_symtype_t;             {symbol types to look for}
  sym_p: code_symbol_p_t;              {to specified symbol}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;

begin
  if tyname.len > 0
    then begin                         {symbol type explicitly specified ?}
      sytypes := [code_symtype_f_name(tyname)]; {only look for this sym type}
      end
    else begin                         {symbol type not specified}
      sytypes := [                     {all the symbol types with subordinate scopes}
        code_symtype_scope_k,
        code_symtype_proc_k,
        code_symtype_prog_k,
        code_symtype_module_k];
      end
    ;
  code_sym_find (                      {find the symbol}
    code_p^, syname, scope_p^, sytypes, sym_p);
  if sym_p = nil then begin            {no such symbol ?}
    sys_msg_parm_vstr (msg_parm[1], syname);
    if tyname.len > 0
      then begin                       {have specific type}
        sys_msg_parm_vstr (msg_parm[2], tyname);
        syn_msg_pos_bomb (syn_p^, '', 'qname_ent_nfnd_ty', msg_parm, 2);
        end
      else begin                       {no specific type}
        syn_msg_pos_bomb (syn_p^, '', 'qname_ent_nfnd', msg_parm, 1);
        end
      ;
    end;
{
*   SYM_P is pointing to the specified symbol.
}
  if sym_p^.subscope_p = nil then begin {no subordinate scope ?}
    sys_msg_parm_vstr (msg_parm[1], syname);
    syn_msg_pos_bomb (syn_p^, '', 'qname_ent_nscope', msg_parm, 1);
    end;

  scope_p := sym_p^.subscope_p;        {go to the subscope of this symbol}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_QNAME (SYMTYPES, SYM_P)
*
*   Interpret the QNAME syntax, which describes a symbol name that may be fully
*   qualified.
*
*   SYMTYPES is the set of symbol types that the symbol is allowed to be.  The
*   special value of the empty set allows all symbol types.
*
*   SYM_P is returned pointing to the symbol descriptor, or NIL when no symbol
*   was found that matched the name and required types.
}
procedure mcomp_syt_qname (            {interpret QNAME syntax}
  in      symtypes: code_symtype_t;    {allowable symbol types}
  out     sym_p: code_symbol_p_t);     {to symbol, or NIL for not found}
  val_param;

var
  scope_p: code_scope_p_t;             {to current scope at current list entry}
  nent: sys_int_machine_t;             {number of list entries processed so far}
  nup: sys_int_machine_t;              {number of scope levels to pop up}
  syname: string_var32_t;              {symbol name}
  tyname: string_var32_t;              {symbol type name}
  tyid: code_symtype_k_t;              {symbol type specified by TYNAME}
  sytypes: code_symtype_t;             {symbol types to look for}

label
  done_scan;

begin
  syname.max := size_char(syname.str); {init local var strings}
  tyname.max := size_char(tyname.str);

  if not syn_trav_down (syn_p^) then begin {down into QNAME syntax}
    syn_msg_pos_bomb (syn_p^, '', 'qname_bad', nil, 0);
    end;

  scope_p := code_p^.scope_p;          {init current scope}
  nent := 0;                           {init to no list entries processed yet}

  while true do begin                  {process top level QNAME tags}
    case syn_trav_next_tag(syn_p^) of  {which tag is here ?}
1:    begin                            {leading optional ":"}
        scope_p := addr(code_p^.scope_root); {go to root scope}
        end;
2:    begin                            {entry in hierarchy list}
        nent := nent + 1;              {make 1-N number of this hierarchy list entry}
        if syt_qnent (nup, syname, tyname)
          then begin                   {this entry is a symbol name}
            syn_trav_push (syn_p^);    {save syn tree position here}
            if syn_trav_next_tag(syn_p^) = syn_tag_end_k then begin {last entry ?}
              syn_trav_popdel (syn_p^); {delete saved syntax tree position}
              goto done_scan;          {done scanning the hierarchy syntax}
              end;
            syn_trav_pop (syn_p^);     {restore syntax tree position}
            update_scope (scope_p, syname, tyname); {update the current scope}
            end
          else begin                   {this entry is number of levels to pop up}
            if nent = 1 then begin     {this is first entry in hierarchy list ?}
              scope_p := code_p^.scope_p; {sym is relative, start at curr scope}
              end;
            while nup > 0 do begin     {pop up the levels}
              if scope_p^.parscope_p = nil then exit; {can't go up from here ?}
              scope_p := scope_p^.parscope_p; {go up to parent scope}
              end;                     {back to pop more levels}
            end
          ;
        end;
otherwise
      syn_msg_tag_bomb (syn_p^, '', 'qname_bad', nil, 0);
      end;
    end;                               {back for next name in hierarchy}
done_scan:                             {done scanning whole QNAME syntax}
{
*   The whole QNAME syntax has been scanned.  SYNAME is the final symbol in the
*   qualified name hiearchy list.  When TYNAME is not empty, then it is the type
*   ID name for the symbol.  Otherwise, no symbol type was specified.
}
  sytypes := symtypes;                 {init the set of allowed symbols}

  if tyname.len > 0 then begin         {symbol string specified a type ?}
    tyid := code_symtype_f_name (tyname); {get the symbol type from its name}
    if symtypes <> [] then begin       {caller only allows some symbol types ?}
      if not (tyid in symtypes) then begin {specified symbol not allowed type ?}
        sym_p := nil;                  {indicate no symbol matches the spec}
        return;
        end;
      end;
    sytypes := [tyid];                 {allow only the specified type}
    end;

  code_sym_find (                      {go find the final symbol}
    code_p^,                           {CODE library use state}
    syname,                            {name of the symbol to find}
    scope_p^,                          {scope to look for the symbol in}
    sytypes,                           {allowed symbol types}
    sym_p);                            {pointer to the symbol, NIL = not found}
  end;
