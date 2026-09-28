{   Traversing of syntax trees related to variables.
}
module mcomp_syt_var;
define mcomp_syt_var_;
%include 'mcomp.ins.pas';

var
  varblk_p: code_varblk_p_t;           {to vars block being built}
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_VAR_SUB
*
*   Process the syntax tree for the VAR_SUB syntax, which is one subcommand in a
*   VAR block.  The module-level variable VARBLK_P must be pointing to the
*   parent variables block descriptor.
}
procedure mcomp_syt_var_sub;
  val_param;

const
  max_msg_args = 1;                    {max arguments we can pass to a message}

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  name: mcomp_name_t;                  {scratch symbol name string}
  var_p: code_var_p_t;                 {to new variable descriptor}
  scopedat_p: mcomp_scopedat_p_t;      {to our data for the current scope}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status}

begin
  name.max := size_char(name.str);     {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into VAR_SUB syntax}
    mcomp_err_atline ('', 'var_sment_sub_bad', nil, 0);
    end;
{
*   Get the variable name and create the variable symbol.
}
  tag := syn_trav_next_tag (syn_p^);   {get tag for variable name}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, '', 'var_name_bad', nil, 0);
    end;
  mcomp_syt_name (name);               {get name of variable being defined}

  code_var_new (                       {create the new variable and its symbol}
    code_p^,                           {CODE library use state}
    name,                              {variable name}
    var_p,                             {returned pointer to new var descriptor}
    stat);
  if sys_error(stat) then begin
    sys_msg_parm_vstr (msg_parm[1], name);
    syn_error_bomb (syn_p^, stat, '', 'var_define', msg_parm, 1);
    end;

  mcomp_comm_set (                     {save comments hierarchy for the variable}
    var_p^.sym_p^.comm_p);
  mcomp_pos_set (                      {save current source position}
    var_p^.sym_p^.pos);
{
*   Add the new variable to the variables block being built.
}
  code_varblk_var_add (                {add new variable to variables block}
    code_p^,                           {CODE library use state}
    varblk_p^,                         {variables block}
    var_p^);                           {variable to add}

  var_p^.memreg_p :=                   {get memory region, if any, from vars block}
    var_p^.block_p^.memreg_p;
{
*   Process the options for this variable.
}
  while true do begin                  {back here each new tag}
    tag := syn_trav_next_tag (syn_p^); {get next tag}
    if tag = syn_tag_end_k then exit;  {end of this syntax level ?}
    case tag of                        {which tag is it ?}

1: begin                               {data type}
  if var_p^.dtype_p <> nil then begin  {data type already set ?}
    sys_msg_parm_vstr (msg_parm[1], var_p^.sym_p^.name_p^);
    syn_msg_pos_bomb (syn_p^, '', 'dtype_dup', msg_parm, 1);
    end;
  mcomp_syt_dtype (var_p^.dtype_p);    {set data type of this variable}
  end;

2: begin                               {memory region}
  if var_p^.memreg_p <> nil then begin {mem region already set ?}
    sys_msg_parm_vstr (msg_parm[1], var_p^.sym_p^.name_p^);
    syn_msg_pos_bomb (syn_p^, '', 'var_memreg_dup', msg_parm, 1);
    end;
  mcomp_syt_name_memreg (var_p^.memreg_p); {get pointer to mem region}
  if var_p^.memreg_p = nil then begin  {no such memory region ?}
    sys_msg_parm_vstr (msg_parm[1], var_p^.sym_p^.name_p^);
    mcomp_err_atline ('', 'var_define', msg_parm, 1);
    end;
  end;

otherwise                              {unexpected tag}
      sys_msg_parm_vstr (msg_parm[1], var_p^.sym_p^.name_p^);
      syn_msg_tag_bomb (syn_p^, '', 'var_define', msg_parm, 1);
      end;
    end;                               {back for next tag this variable}

  if var_p^.memreg_p = nil then begin  {no memory region defined ?}
    scopedat_p := mcomp_scopedat;      {get pnt to our data for curr scope}
    var_p^.memreg_p :=                 {use default memory region, if any}
      scopedat_p^.default.memreg_p;
    end;

  mcomp_trav_up;                       {back up to parent syntax level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_VAR_
*
*   Process the syntax tree of a VAR statement.  A VAR statement can have
*   parameters as defined by the VAR_ syntax.  It is also a block that contains
*   substatements according to the VAR_SUB syntax.
}
procedure mcomp_syt_var_;              {process VAR statement and its block}
  val_param;

const
  max_msg_args = 1;                    {max arguments we can pass to a message}

var
  tag: sys_int_machine_t;              {tagged syntax ID}
  name: mcomp_name_t;                  {scratch symbol name string}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;
  stat: sys_err_t;                     {completion status}

begin
  name.max := size_char(name.str);     {init local var string}

  code_varblk_new (code_p^, varblk_p); {create and init new vars block}
  mcomp_comm_set (varblk_p^.comm_p);   {set var block comment hierarchy}

  syn_trav_next_down_virt (syn_p^);    {down into VAR_ syntax level}

  while true do begin                  {back here each new tag in VAR_ syntax}
    tag := syn_trav_next_tag (syn_p^); {get next syntax tag}
    if tag = syn_tag_end_k then exit;  {hit end of VAR_ syntax ?}
    case tag of                        {which tag is it ?}

1:    begin                            {NAME name}
        syn_trav_tag_string (syn_p^, name); {get common block name}
        code_varblk_add_name (         {add name to the vars block being built}
          code_p^,                     {CODE library use state}
          name,                        {name to give the vars block}
          varblk_p^,                   {the block to give a name to}
          stat);
        syn_error_bomb (syn_p^, stat, '', '', nil, 0);
        end;

2:    begin                            {IN name}
        if varblk_p^.memreg_p <> nil then begin {mem region already set ?}
          sys_msg_parm_vstr (msg_parm[1], varblk_p^.memreg_p^.sym_p^.name_p^);
          syn_error_bomb (syn_p^, stat, '', 'var_memreg_dup_block', msg_parm, 1);
          end;
        mcomp_syt_name_memreg (varblk_p^.memreg_p); {get pnt to mem region}
        if varblk_p^.memreg_p = nil then begin {no such memory region ?}
          mcomp_err_atline ('', 'varblock_bad', nil, 0);
          end;
        end;

otherwise                              {unexpected or error tag in VAR_ syntax}
      syn_msg_pos_bomb (syn_p^, '', 'varblock_bad', nil, 0);
      end;
    end;                               {back for next tag in VAR_ syntax}

  mcomp_trav_up;                       {back up to parent syntax level}

  mcomp_parse_block (                  {parse the VAR substatements}
    addr(mcomp_syn_var),               {parse routine for each substatement}
    addr(mcomp_syt_var_sub));          {routine to process resulting syntax trees}
  end;
