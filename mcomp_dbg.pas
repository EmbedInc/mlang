{   Routines intended to be useful in debugging the MCOMP program.
}
module mcomp_dbg;
define mcomp_dbg_coll;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_DBG_COLL (COLL)
*
*   Show the contents of the collection COLL.
}
procedure mcomp_dbg_coll (             {show contents of a collection}
  in      coll: fline_coll_t);         {the collection to show}
  val_param;

var
  fl_p: fline_p_t;                     {pointer to FLINE library use state}
  line_p: fline_line_p_t;              {pointer to current line}
  nlines: sys_int_machine_t;           {number of lines found}
  lpos_p: fline_lpos_p_t;              {pointer to current logical position level}
  lnum: sys_int_machine_t;             {scratch line number}
  name_p: string_var_p_t;              {scratch pointer to collection or other name}

begin
  fl_p := coll.fline_p;                {get pointer to FLINE library use state}

  writeln ('Collection "', coll.name_p^.str:coll.name_p^.len, '"');

  write ('Type: ');
  case coll.colltyp of
fline_colltyp_file_k: write ('file');
fline_colltyp_lmem_k: write ('lmem');
fline_colltyp_virt_k: write ('virt');
otherwise
    write ('ID ', ord(coll.colltyp));
    end;
  writeln;

  nlines := 0;                         {init number of lines found}
  line_p := coll.first_p;              {init to first line}
  while line_p <> nil do begin         {back here each new line in this collection}
    nlines := nlines + 1;              {count one more line in the collection}
    writeln (line_p^.lnum:5, ': ', line_p^.str_p^.str:line_p^.str_p^.len);

    if line_p^.virt_p <> nil then begin {virtual location exists ?}
      writeln ('       Virt line ', line_p^.virt_p^.lnum, ' of "',
        line_p^.virt_p^.coll_p^.name_p^.str:line_p^.virt_p^.coll_p^.name_p^.len, '"');
      end;

    if line_p^.lpos_p <> nil then begin {logical position is defined ?}
      writeln ('       Logical position:');
      lpos_p := line_p^.lpos_p;        {init to lowest logical position level}
      while lpos_p <> nil do begin     {up the logical position levels}
        fline_line_name_virt (lpos_p^.line_p^, name_p); {get virt source name}
        lnum := fline_line_lnum_virt (lpos_p^.line_p^); {get virt source line number}
        writeln ('         "', name_p^.str:name_p^.len, '" ', lnum);
        lpos_p := lpos_p^.prev_p;      {up to next higher logical position level}
        end;                           {back to show this new logical position level}
      end;

    line_p := line_p^.next_p;
    end;

  writeln (nlines, ' lines found');
  end;
