{   Syntax parsing routines that are explicitly written, as opposed to being
*   automatically generated from the MLANG.SYN syntax definition file.
}
module mcomp_syn;
define mcomp_syn_pad;
define mcomp_syn_space;
define mcomp_syn_stlevel;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Local function NEXT_LINE_LEVEL (SYN)
*
*   The current parsing position is at the start of a line.  The function
*   returns the nesting level of the next line containing any content.  Blank
*   and comment lines are processed with the comment state updated accordingly.
*   The parsing position is left at the first non-blank on the first non-comment
*   line.
*
*   A level of 0 is always returned when the end of all data (EOD) is
*   encountered.
}
function next_line_level (             {to start of next content, get nesting level}
  in out  syn: syn_t)                  {SYN library use state}
  :sys_int_machine_t;                  {nesting level of new line, 0 = top}
  val_param; internal;

const
  max_msg_args = 1;                    {max arguments we can pass to a message}

var
  indent: sys_int_machine_t;           {number of spaces first char is indented}
  level: sys_int_machine_t;            {nesting level implied by indentation}
  pos: fline_cpos_t;                   {main saved parsing position}
  c: sys_int_machine_t;                {input character}
  msg_parm:                            {references arguments passed to a message}
    array[1..max_msg_args] of sys_parm_msg_t;

label
  next_line;

begin
next_line:                             {back here to retry on next line}
  indent := 0;                         {init number spaces indentation found}
  while true do begin
    syn_p_cpos_get (syn, pos);         {save parsing postion before this new char}
    c := syn_p_ichar (syn);            {get the new character}
    if c <> ord(' ') then exit;        {found first non-blank ?}
    indent := indent + 1;              {count one more character of indentationz}
    end;                               {back to check next input char}
{
*   C is the first non-blank character found, and POS is its parsing position.
*   INDENT is the number of spaces preceeding C on the line.
}
  if c = syn_ichar_eod_k then begin    {hit end of all data ?}
    next_line_level := 0;              {treat EOD as top level statement, never continuation}
    return;
    end;

  if c = syn_ichar_eol_k then begin    {special case of all-blank line ?}
    syn_p_cpos_set (syn, pos);         {restore position to EOL}
    mcomp_comm_get (                   {get comment, update comment state}
      syn,                             {SYN library use state}
      mcomp_cmlev_blank_k,             {indicate this comment is a blank line}
      true);                           {consume the EOL}
    goto next_line;                    {skip this line, on to next}
    end;

  level := indent div 2;               {make nesting level from indentation}
  if (level * 2) <> indent then begin  {invalid indentation ?}
    syn_p_cpos_set (syn, pos);         {position to offending character}
    sys_msg_parm_int (msg_parm[1], indent);
    mcomp_err_atline ('mcomp_prog', 'indent_bad', msg_parm, 1);
    end;

  if c = ord('''') then begin          {this is a comment line ?}
    mcomp_comm_get (syn, level, true); {process comment, consume EOL}
    goto next_line;                    {done with this line, on to next}
    end;

  syn_p_cpos_set (syn, pos);           {restore parse position to first non-blank}
  next_line_level := level;            {return the nesting level at this new line}
  end;
{
********************************************************************************
*
*   Local function SKIP (SYN)
*
*   Skip over non-content.  The function returns TRUE iff at least one separator
*   was skipped over.  Separators are spaces and end of lines.
*
*   An end of line is only skipped over if the indentation level of the next
*   line with any content is two levels more from the current.  That means the
*   new line is really a continuation of the current.  Otherwise, the EOL is not
*   skipped.  That causes the EOL to be seen by subsequent syntax checking
*   functions, which should end the statement.
}
function skip (
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {skipped over at least one separator}
  val_param; internal;

var
  pos: fline_cpos_t;                   {saved parsing position}
  c: sys_int_machine_t;                {input character}
  level: sys_int_machine_t;            {nesting level of new line}
  commallow: boolean;                  {comment start allowed at next char}

begin
  skip := false;                       {init to no separators skipped over}
  commallow := false;                  {init to comment start not allowed here}

  while true do begin                  {loop over sequential input chars}
    syn_p_cpos_get (syn, pos);         {save parsing position before new char}
    c := syn_p_ichar (syn);            {get this input character}
    {
    *   C is this input stream character, and POS its input stream position.
    }
    if commallow and (c = ord('''')) then begin {end of line comment start ?}
      mcomp_comm_get (syn, mcomp_cmlev_eol_k, false); {process comment, leave EOL}
      next;
      end;

    commallow := c = ord(' ');         {comment start allowed next char ?}

    if (c = ord(' ')) or (c = syn_ichar_eof_k) then begin {separator ?}
      skip := true;                    {found separator}
      next;                            {on to next character}
      end;

    if c = syn_ichar_eol_k then begin  {end of line ?}
      level := next_line_level (syn);  {to start of next line, get nesting level}
      if level = (mcomp_level + 2) then begin {new line is continuation of previous ?}
        skip := true;                  {new line counts as separator}
        return;
        end;
      exit;                            {not continuation line, don't skip this EOL}
      end;

    exit;                              {content character, don't skip over}
    end;                               {back to process next input char}

  syn_p_cpos_set (syn, pos);           {back to before this last character}
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_PAD (SYN)
*
*   Parses the PAD syntax contruction.  PAD allows, but does not require, white
*   space.
}
function mcomp_syn_pad (               {parse PAD syntax}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched syntax template}
  val_param;

begin
  discard( skip (syn) );               {skip over blanks and such, if present}
  mcomp_syn_pad := true;               {this syntax always matches}
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_SPACE (SYN)
*
*   Parses the SPACE syntax contruction.  SPACE requires at least some white
*   space, and allows any additional amount.
}
function mcomp_syn_space (             {parse SPACE syntax}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched syntax template}
  val_param;

var
  pos: fline_cpos_t;                   {main saved parsing position}

begin
  mcomp_syn_space := true;             {init to separator found}

  syn_p_cpos_get (syn, pos);           {save existing parsing position}
  if not skip(syn) then begin          {no separator found ?}
    syn_p_cpos_set (syn, pos);         {restore original parsing position}
    mcomp_syn_space := false;          {indicate syntax not match SPACE}
    end;
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_STLEVEL (SYN)
*
*   Special parsing function that assumes to start on a new line, and finds the
*   start of the next text and its nesting level.  The global statement parsing
*   nesting level is updated accordingly.  The parsing position will be left at
*   the first real statement character.
}
function mcomp_syn_stlevel (           {find start of statement, find nesting level}
  in out  syn: syn_t)
  :boolean;
  val_param;

var
  level: sys_int_machine_t;            {nesting level of next statement}

begin
  level := next_line_level (syn);      {to first content char, get nesting level}
  mcomp_level_set (level);             {update global nested statements state}
  mcomp_syn_stlevel := true;           {this syntax always matches}
  end;
