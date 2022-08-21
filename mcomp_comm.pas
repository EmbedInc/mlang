{   Comment handling.
}
module mcomp_comm;
define mcomp_comm_init;
define mcomp_comm_get;
%include 'mcomp.ins.pas';
{
*   Since there can be at most one comment per source line, each comment is
*   uniquely identified by the source line number.  The COMMLINE array contains
*   one entry for each source line.
*
*   The syntax parser can attempt to parse over the same source code multiple
*   times.  This can result in MCOMP_COMM_GET getting called with the same
*   comment multiple times.  The COMMLINE array is the means to identify and
*   ignore redundant comments being provided to the comments system.
}
type
  commline_ent_t = record
    cmlev: sys_int_machine_t;          {0-N nesting level or MCOMP_CMLEV_xxx_K}
    str_p: string_var_p_t;             {pointer to comment string, NIL when none}
    end;

  commline_p_t = ^commline_t;
  commline_t =                         {array template, sized for num of input lines}
    array[1..1] of commline_ent_t;

var
  commline_p: commline_p_t;            {pointer to array of comments by source line}
  nlines: sys_int_machine_t;           {number of lines in COMMLINE array}
{
********************************************************************************
*
*   Subroutine MCOMP_COMM_INIT (COLL)
*
*   Initialize the comment system to the collection of lines that will be
*   parsed.  This must be the first call into this module.  All subsequent
*   comments must be from this collection.
}
procedure mcomp_comm_init (            {init comments system}
  in      coll: fline_coll_t);         {collection of lines that will be parsed}
  val_param;

var
  line: sys_int_machine_t;             {line number}

begin
  if coll.last_p = nil
    then begin                         {no input lines}
      nlines := 1;                     {set to minimum}
      end
    else begin                         {there is a known last input line}
      nlines := coll.last_p^.lnum;     {init size to number of lines}
      end
    ;
  mcomp_mem_perm (                     {allocate memory for comment lines array}
    sizeof(commline_ent_t) * nlines,   {amount of memory to allocate}
    commline_p);                       {returned pointer to the new memory}

  for line := 1 to nlines do begin     {init the comment lines array}
    commline_p^[line].cmlev := mcomp_cmlev_none_k; {init to no comm from this line}
    commline_p^[line].str_p := nil;
    end;
  end;
{
********************************************************************************
*
*   Local subroutine COMM_PUT (COMM, LEVEL, POS)
*
*   Update the comments state with the new comment string COMM.  LEVEL is the
*   nesting level of the new comment, or one of the special cases
*   MCOMP_CMLEV_xxx_K.  POS is the character position of the start of the
*   comment.  Each comment is uniquely identified with a different POS.
}
procedure comm_put (                   {add new comment to comments state}
  in      comm: univ string_var_arg_t; {comment string}
  in      level: sys_int_machine_t;    {nesting level or MCOMP_CMLEV_xxx_K}
  in      pos: fline_cpos_t);          {input stream position at start of comment}
  val_param; internal;

var
  lnum: sys_int_machine_t;             {line number}

begin
  if pos.line_p = nil then return;     {source line is unknown (shouldn't happen) ?}
  lnum := pos.line_p^.lnum;            {get the source line number}
  if (lnum < 0) or (lnum > nlines) then return; {out of range of comm lines array ?}

  if commline_p^[lnum].str_p <> nil then return; {already know about this comment ?}

  commline_p^[lnum].cmlev := level;    {save info about comment from this line}
  string_alloc (                       {allocate memory for the comment string}
    comm.len,                          {max length of string to allocate}
    mem_p^,                            {parent memory context}
    false,                             {won't individually deallocate this mem}
    commline_p^[lnum].str_p);          {returned pointer to the new empty}
  string_copy (comm, commline_p^[lnum].str_p^); {save comm text in new string}


  {*** NOT IMPLEMENTED YET, temporary code ***}


  write ('Comm on line ', lnum, ' col ', pos.ind, ', ');
  case level of
mcomp_cmlev_eol_k: begin               {end of line comment}
      writeln ('EOL: ', comm.str:comm.len);
      end;
mcomp_cmlev_blank_k: begin             {blank line}
      writeln ('Blank line');
      end;
otherwise
    writeln ('lev ', level:2, ': ', comm.str:comm.len);
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
  poscomm: fline_cpos_t;               {position at comment start}
  pos: fline_cpos_t;                   {temp saved parsing position}
  noblank: boolean;                    {ignoring leading blanks}

begin
  comm.max := size_char(comm.str);     {init local var string}

  syn_p_cpos_get (syn, poscomm);       {save position at comment start}
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
      comm_put (comm, level, poscomm); {update comment state with this new comment}
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
