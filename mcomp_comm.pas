{   Comment handling.
}
module mcomp_comm;
define mcomp_comm_get;
define mcomp_comm_newline;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local subroutine COMM_PUT (COMM, LEVEL)
*
*   Update the comments state with the new comment string COMM.  LEVEL is the
*   nesting level of the new comment, or one of the special cases
*   MCOMP_CMLEV_xxx_K.
}
procedure comm_put (                   {add new comment to comments state}
  in      comm: univ string_var_arg_t; {comment string}
  in      level: sys_int_machine_t);   {nesting level or MCOMP_CMLEV_xxx_K}
  val_param; internal;

begin

  {*** NOT IMPLEMENTED YET, temporary code ***}

  case level of
mcomp_cmlev_eol_k: begin               {end of line comment}
      writeln ('EOL comm: ', comm.str:comm.len);
      end;
mcomp_cmlev_blank_k: begin             {blank line}
      writeln ('Blank line');
      end;
otherwise
    writeln ('Comm lev ', level:2, ': ', comm.str:comm.len);
    end;
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_COMM_GET (SYN, LEVEL, NOEOL)
*
*   The content of a comment starts at the current position of the input stream.
*   The comment start character, if any, has already been read.
*
*   LEVEL is the 0-N nesting of the comment, or one of the special cases
*   MCOMP_CMLEV_xxx_K:
*
*     MCOMP_CMLEV_EOL_K
*
*       This is an end of line comment, with real content preceeding the comment
*       on the same line.
*
*     MCOMP_CMLEV_BLANK_K
*
*       This line is empty or contains only blanks.  There was no comment start
*       character.
*
*   When NOEOL is true, the end of line ending the comment is consumed.  When
*   false, the next character will be the EOL.
}
procedure mcomp_comm_get (             {read comment to end of line, consumes EOL}
  in out  syn: syn_t;                  {SYN library use state}
  in      level: sys_int_machine_t;    {comment nesting level or MCOMP_CMLEV_xxx_K}
  in      noeol: boolean);             {consume EOL at end of comment}
  val_param;

var
  comm: string_var132_t;               {comment content}
  c: sys_int_machine_t;                {character code of current charcter}
  pos: fline_cpos_t;                   {saved parsing position}
  noblank: boolean;                    {ignoring leading blanks}

begin
  comm.max := size_char(comm.str);     {init local var string}

  comm.len := 0;                       {init comment string to empty}
  noblank := level < 0;                {ignore leading blanks unless explicit comment line}

  while true do begin                  {loop over characters until EOL}
    if not noeol then begin            {need to save position of this char ?}
      syn_p_cpos_get (syn, pos);
      end;
    c := syn_p_ichar (syn);            {get this character}

    if c = syn_ichar_eol_k then begin  {hit EOL that ends comment ?}
      if not noeol then begin          {leave parse position at EOL ?}
        syn_p_cpos_set (syn, pos);
        end;
      string_unpad (comm);             {remove trailing blanks from comment string}
      comm_put (comm, level);          {update comment state with this new comment}
      return;
      end;

    if noblank
      then begin                       {ignoring blanks}
        if c <> ord(' ') then begin
          string_append1 (comm, chr(c)); {add this char to end of comment string}
          noblank := false;            {any further blanks won't be leading}
          end
        end
      else begin                       {save char whether blank or not}
        string_append1 (comm, chr(c)); {add this char to end of comment string}
        end
      ;
    end;                               {back for next input stream character}
  end;
{
********************************************************************************
*
*   Subroutine MCOMP_COMM_NEWLINE
*
*   Indicate to the comment system that parsing is now on a new line.
}
procedure mcomp_comm_newline;          {tell comment system now on new line}
  val_param;

begin

  {*** NOT IMPLEMENTED YET ***}

  end;
