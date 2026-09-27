//   Messages used by the MCOMP program.
//
msg access_none
  lan english -def
    No access specified.  Some access is required.
msg adrreg_err
  lan english -def
    Error in ADDRESS REGION statement.
msg adrreg_name_none
  lan english -def
    Unable to get address region name.
msg adrreg_opt_bad
  lan english -def
    Invalid ADDRESS REGION option.
msg accty_err
  lan english -def
    Invalid access type.
msg accty_npar
  lan english -def
    Parent does not have this access type.  Only access types that the
    parent has can be added.
msg adr_err
  lan english -def
    Error in ADRSPACE statement.
msg adr_name_none
  lan english -def
    Unable to get address space name.
msg adr_opt_bad
  lan english -def
    Invalid adrspace option.

msg default_bad
  lan english -def
    Invalid DEFAULT statement.
msg default_in_err
  lan english -def
    Error in IN statement within DEFAULT block.

msg end_len_diff
  lan english -def
    Mismatch between address length and end address.
msg end_len_none
  lan english -def
    Missing end address or length.
msg indent_bad
  lan english -def
    Invalid indentation of %p1i found.  Indentation must be an even number
    of blanks.
msg mem_err
  lan english -def
    Error in MEMORY statement.
msg mem_name_none
  lan english -def
    Unable to get memory name.
msg mem_opt_bad
  lan english -def
    Invalid MEMORY option.
msg memreg_bad
  lan english -def
    "%p1s" is not a valid memory region.
msg memreg_err
  lan english -def
    Error in MEMORY REGION statement.
msg memreg_name_none
  lan english -def
    Unable to get memory region name.
msg memreg_nfound
  lan english -def
    Memory region not previously defined.
msg memreg_opt_bad
  lan english -def
    Invalid MEMORY REGION option.
msg qname_bad
  lan english -def
    Invalid qualified symbol name.
msg qname_ent_bad
  lan english -def
    Invalid qualified symbol name component.
msg qname_ent_nfnd
  lan english -def
    Component "%p1s" in qualified symbol type name does not exist or is
    not a symbol type that has a scope.
msg qname_ent_nfnd_ty
  lan english -def
    Component "%p1s" of type %p2s in qualified symbol type name not found.
msg qname_ent_nscope
  lan english -def
    Component "%p1s" in qualified symbol type name does not have a
    subordinate scope, but is not last component.  All components of a
    qualified symbol name except the last must identify scopes.

msg scope_nodat
  lan english -def
    INTERNAL ERROR: Current scope has no private app data.
msg scope_none
  lan english -def
    INTERNAL ERROR: No current scope on call to MCOMP_SCOPEDAT.

msg statement_bad
  lan english -def
    Invalid statement.
msg statement_err
  lan english -def
    INTERNAL ERROR: Attempt to parse a new statement when a syntax error
    was previously encountered.
msg statement_subordinate
  lan english -def
    A subordinate statement is not allowed here.
msg syt_dtype_nil
  lan english -def
    INTERNAL ERROR: Returned data type pointer NIL in MCOMP_SYT_DTYPE.

msg type_bad
  lan english -def
    Invalid TYPE statement.
msg type_def_bad
  lan english -def
    Not a valid data type definition or reference.
msg type_int_bad
  lan english -def
    Invalid INTEGER data type parameter.
msg type_name_bad
  lan english -def
    Not a valid data type name.
msg type_sym_ndef
  lan english -def
    The data type of "%p1s" has not been defined yet.
msg type_sym_nfnd
  lan english -def
    No such data type as "%p1s".

msg var_define
  lan english -def
    Error on attempt to define variable "%p1s".
msg var_dtype_dup
  lan english -def
    Data type for variable "%p1s" already defined.
msg var_memreg_dup
  lan english -def
    A memory region was previously set for the variable "%p1s".
msg var_memreg_dup_block
  lan english -def
    Memory region "%1ps" was previously set for this VAR block.
msg var_name_bad
  lan english -def
    Not a valid variable name.
msg var_sment_sub_bad
  lan english -def
    Invalid VAR block sub-statement.

msg varblock_bad
  lan english -def
    Error in VARBLOCK statement.
