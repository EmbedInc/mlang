{   Syntax parsing routines that are explicitly written, as opposed to being
*   automatically generated from the MLANG.SYN syntax definition file.
}
module mcomp_syn;
define mcomp_syn_pad;
define mcomp_syn_space;
define mcomp_syn_endst;
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
  mcomp_syn_space := true;
  end;
{
********************************************************************************
*
*   Function MCOMP_SYN_ENDST (SYN)
*
*   Parses the ENDST syntax contruction.  ENDST consumes all the white space at
*   the end of a statement, up to and including the EOL.  Nothing other than
*   white space is allowed.
}
function mcomp_syn_endst (             {parse ENDST syntax}
  in out  syn: syn_t)                  {SYN library use state}
  :boolean;                            {TRUE iff input matched syntax template}
  val_param;

begin
  mcomp_syn_endst := true;
  end;
