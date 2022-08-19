{   Error handling.
}
module mcomp_err;
define mcomp_err_atline;
%include 'mcomp.ins.pas';
{
********************************************************************************
*
*   Subroutine MCOMP_ERR_ATLINE (SUBSYS, MSG_NAME, PARMS, N_PARMS)
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

var
  pos: fline_cpos_t;                   {input stream parsing position}

begin
  writeln;
  sys_message_parms (subsys, msg, parms, n_parms); {show caller's message}

  syn_p_cpos_get (syn_p^, pos);        {get current parsing position}
  fline_cpos_show (pos);               {show the position}

  sys_bomb;                            {bomb program with error}
  end;
