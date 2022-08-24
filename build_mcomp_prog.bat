@echo off
rem
rem   Build the MCOMP program.
rem
setlocal
call src_pas %srcdir% mcomp

call src_pas %srcdir% mcomp_comm
call src_pas %srcdir% mcomp_dbg
call src_pas %srcdir% mcomp_err
call src_pas %srcdir% mcomp_mem
call src_pas %srcdir% mcomp_parse
call src_pas %srcdir% mcomp_syn
call src_pas %srcdir% mcomp_syt
call src_pas %srcdir% mcomp_syt_memadr
call src_syn mlang

call src_lib %srcdir% mcompprog private
call src_msg %srcdir% mcomp_prog

if "%debug_vs%"=="true" (
  set debug=/debug
  ) else (
  set debug=
  )

call src_link mcomp mcomp %debug% mcompprog.lib
call src_exeput mcomp

call src_doc mcomp
