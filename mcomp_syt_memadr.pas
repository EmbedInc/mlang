{   Interpretation of syntaxes related to memories, address spaces, and thier
*   regions.
}
module mcomp_syt_memadr;
define mcomp_syt_memory_;
define mcomp_syt_memregion_;
define mcomp_syt_adrspace_;
define mcomp_syt_adrregion_;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_MEMORY_
*
*   Interpret the MEMORY_ syntax.
}
procedure mcomp_syt_memory_;           {interpret MEMORY_ syntax}
  val_param;

var
  tag: sys_int_machine_t;              {syntax tag ID}
  name: string_var32_t;                {memory name}
  mem_p: code_memory_p_t;              {pointer to the new memory descriptor}
  stat: sys_err_t;

label
  done_syn;

begin
  name.max := size_char(name.str);     {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into MEMORY_ syntax}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'mem_err', nil, 0);
    end;
{
*   Create and initialize the memory descriptor.
}
  tag := syn_trav_next_tag (syn_p^);   {get tag for memory name}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'mem_name_none', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get the new memory name}
  code_mem_new (code_p^, name, mem_p, stat); {create the new memory descriptor}
  syn_error_bomb (syn_p^, stat, 'mcomp_prog', 'mem_err', nil, 0);
  syn_trav_tag_start (syn_p^, mem_p^.sym_p^.pos); {save source code position}
  code_comm_find (                     {tag the new structure with comment, if any}
    code_p^,                           {CODE library use state}
    mcomp_currline,                    {current global sequential source line number}
    currlevel,                         {current nesting level}
    mem_p^.sym_p^.comm_p);             {returned pointer to comments}
{
*   Process the command options.
}
  while true do begin                  {loop thru optional parameters}
    tag := syn_trav_next_tag (syn_p^); {get tag for next option}
    case tag of                        {which option is it ?}

syn_tag_end_k: begin                   {end of options}
        goto done_syn;
        end;

1:    begin                            {ADRBITS}
        mem_p^.bitsadr := mcomp_syt_integer;
        end;

2:    begin                            {DATBITS}
        mem_p^.bitsdat := mcomp_syt_integer;
        end;

3:    begin                            {ACCESS}
        mcomp_syt_accesstype (         {interpret the ACCESSTYPE syntax}
          mem_p^.accs,                 {access type to update}
          ~setof(code_memaccs_t));     {parent access types, all for top level}
        end;

otherwise                              {unexpected tag}
      syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'mem_opt_bad', nil, 0);
      end;
    end;                               {back to get next command option}

done_syn:                              {done interpreting syntax}
  if mem_p^.accs = [] then begin       {no access to this memory ?}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'access_none', nil, 0);
    end;

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_MEMREGION_
*
*   Interpret the MEMREGION_ syntax.
}
procedure mcomp_syt_memregion_;        {interpret MEMREGION_ syntax}
  val_param;

var
  tag: sys_int_machine_t;              {syntax tag ID}
  name: string_var32_t;                {new memory region name}
  memname: string_var32_t;             {referenced memory name}
  memreg_p: code_memregion_p_t;        {pointer to the new memory region descriptor}
  len: sys_int_conv32_t;               {length of memory region}
  len_set: boolean;                    {memory region length was specified}
  end_set: boolean;                    {memory region end address was specified}
  access: boolean;                     {ACCESS specified}
  stat: sys_err_t;

label
  done_syn;

begin
  name.max := size_char(name.str);     {init local var strings}
  memname.max := size_char(memname.str);

  if not syn_trav_next_down (syn_p^) then begin {down into MEMORY_ syntax}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'memreg_err', nil, 0);
    end;
{
*   Create and initialize the memory region descriptor.
}
  tag := syn_trav_next_tag (syn_p^);   {get the new memory region name}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'memreg_name_none', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get the new memory region name}

  tag := syn_trav_next_tag (syn_p^);   {get the name of the parent memory}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'mem_name_none', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, memname); {get name of the referenced memory}

  code_memreg_new (                    {create the new memory region descriptor}
    code_p^,                           {CODE library use state}
    name,                              {name of new memory region}
    memname,                           {name of parent memory}
    memreg_p,                          {returned pointer to new memory region}
    stat);
  syn_error_bomb (syn_p^, stat, 'mcomp_prog', 'memreg_err', nil, 0);

  syn_trav_tag_start (syn_p^, memreg_p^.sym_p^.pos); {save source code position}
  code_comm_find (                     {tag the new structure with comment, if any}
    code_p^,                           {CODE library use state}
    mcomp_currline,                    {current global sequential source line number}
    currlevel,                         {current nesting level}
    memreg_p^.sym_p^.comm_p);          {returned pointer to comments}
{
*   Process the command options.
}
  len_set := false;                    {init to adr length not specified}
  end_set := false;                    {init to end adr not specified}
  access := false;                     {init to ACCESS not specified}

  while true do begin                  {loop thru optional parameters}
    tag := syn_trav_next_tag (syn_p^); {get tag for next option}
    case tag of                        {which option is it ?}

syn_tag_end_k: begin                   {end of options}
        goto done_syn;
        end;

1:    begin                            {STARTADR}
        memreg_p^.adrst := mcomp_syt_integer;
        end;

2:    begin                            {LENGTH}
        len := mcomp_syt_integer;
        len_set := true;
        end;

3:    begin                            {ENDADR}
        memreg_p^.adren := mcomp_syt_integer;
        end_set := true;
        end;

4:    begin                            {ACCESS}
        mcomp_syt_accesstype (         {interpret the ACCESSTYPE syntax}
          memreg_p^.accs,              {access type to update}
          memreg_p^.mem_p^.accs);      {parent access types}
        access := true;                {remember that ACCESS was specified}
        end;

otherwise                              {unexpected tag}
      syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'memreg_opt_bad', nil, 0);
      end;
    end;                               {back to get next command option}

done_syn:                              {done interpreting syntax}
  if (not len_set) and (not end_set) then begin {end not specified either way ?}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'end_len_none', nil, 0);
    end;
  if len_set and end_set then begin    {both length and end specified}
    if len <> (memreg_p^.adren - memreg_p^.adrst + 1) then begin {specs conflict ?}
      syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'end_len_diff', nil, 0);
      end;
    end;
  if not end_set then begin            {length specified but not end address ?}
    memreg_p^.adren := memreg_p^.adrst + (len - 1); {set end address from length}
    end;

  if not access then begin             {access not specified ?}
    memreg_p^.accs := memreg_p^.mem_p^.accs; {default to parent's access}
    end;
  if memreg_p^.accs = [] then begin    {no access to this memory ?}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'access_none', nil, 0);
    end;

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_ADRSPACE_
*
*   Interpret the ADRSPACE_ syntax.
}
procedure mcomp_syt_adrspace_;         {interpret ADRSPACE_ syntax}
  val_param;

var
  tag: sys_int_machine_t;              {syntax tag ID}
  name: string_var32_t;                {address space name}
  adr_p: code_adrspace_p_t;            {pointer to the new address space descriptor}
  stat: sys_err_t;

label
  done_syn;

begin
  name.max := size_char(name.str);     {init local var string}

  if not syn_trav_next_down (syn_p^) then begin {down into ADRSPACE_ syntax}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'adr_err', nil, 0);
    end;
{
*   Create and initialize the memory descriptor.
}
  tag := syn_trav_next_tag (syn_p^);   {get tag for address space name}
  if tag <> 1 then begin
    syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'adr_name_none', nil, 0);
    end;
  syn_trav_tag_string (syn_p^, name);  {get the new address space name}
  code_adrsp_new (code_p^, name, adr_p, stat); {create the new address space descriptor}
  syn_error_bomb (syn_p^, stat, 'mcomp_prog', 'adr_err', nil, 0);
  syn_trav_tag_start (syn_p^, adr_p^.sym_p^.pos); {save source code position}
  code_comm_find (                     {tag the new structure with comment, if any}
    code_p^,                           {CODE library use state}
    mcomp_currline,                    {current global sequential source line number}
    currlevel,                         {current nesting level}
    adr_p^.sym_p^.comm_p);             {returned pointer to comments}
{
*   Process the command options.
}
  while true do begin                  {loop thru optional parameters}
    tag := syn_trav_next_tag (syn_p^); {get tag for next option}
    case tag of                        {which option is it ?}

syn_tag_end_k: begin                   {end of options}
        goto done_syn;
        end;

1:    begin                            {ADRBITS}
        adr_p^.bitsadr := mcomp_syt_integer;
        end;

2:    begin                            {DATBITS}
        adr_p^.bitsdat := mcomp_syt_integer;
        end;

3:    begin                            {ACCESS}
        mcomp_syt_accesstype (         {interpret the ACCESSTYPE syntax}
          adr_p^.accs,                 {access type to update}
          ~setof(code_memaccs_t));     {parent access types, all for top level}
        end;

otherwise                              {unexpected tag}
      syn_msg_tag_bomb (syn_p^, 'mcomp_prog', 'adr_opt_bad', nil, 0);
      end;
    end;                               {back to get next command option}

done_syn:                              {done interpreting syntax}
  if adr_p^.accs = [] then begin       {no access to this address space ?}
    syn_msg_pos_bomb (syn_p^, 'mcomp_prog', 'access_none', nil, 0);
    end;

  discard( syn_trav_up (syn_p^) );     {back up to parent level}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_SYT_ADRREGION_
*
*   Interpret the ADRREGION_ syntax.
}
procedure mcomp_syt_adrregion_;        {interpret ADRREGION_ syntax}
  val_param;

begin
  end;
