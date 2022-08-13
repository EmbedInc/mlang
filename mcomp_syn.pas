{   Syntax parsing routines that are explicitly written, as opposed to being
*   automatically generated from the MLANG.SYN syntax definition file.
}
module mcomp_syn;
define mcomp_syn_pad;
define mcomp_syn_space;
define mcomp_syn_stend;
define mcomp_syn_level;
%include 'mcomp.ins.pas';
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
  mcomp_syn_pad := true;
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

begin
  mcomp_syn_space := true;             {NOT IMPLEMENTED YET}
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_STEND (SYN)
*
*   Parses the STEND syntax contruction.  STEND consumes all the white space at
*   the end of a statement, up to and including the EOL.  Nothing other than
*   white space is allowed.
}
function mcomp_syn_stend (             {parse STEND syntax}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched syntax template}
  val_param;

begin
  mcomp_syn_stend := true;             {NOT IMPLEMENTED YET}
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_LEVEL (SYN)
*
*   Special parsing function that assumes to start on a new line, and finds the
*   start of the next text and its nesting level.  The global variable NEXTLEVEL
*   is set accordingly.  The parsing position will be left at the first real
*   statement character.
}
function mcomp_syn_level (             {get level of next statement}
  in out  syn: syn_t)
  :boolean;
  val_param;

begin
  mcomp_syn_level := true;             {NOT IMPLEMENTED YET}
  nextlevel := mcomp_lev_eod_k;
  end;
