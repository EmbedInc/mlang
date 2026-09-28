{   Error handling.
}
module mcomp_err;
define mcomp_err_atline;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_ERR_ATLINE (SUBSYS, MSG, PARMS, N_PARMS)
*
*   Show the caller's error message, the current source code position, and then
*   bomb the program with error.
}
procedure mcomp_err_atline (           {show error, source line, and bomb program}
  in      subsys: string;              {subsystem name of caller's message}
  in      msg: string;                 {name of caller's message within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  options (val_param, noreturn);

begin
  syn_msg_pos_bomb (syn_p^, subsys, msg, parms, n_parms);
  end;
