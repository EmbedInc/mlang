@echo off
rem
rem   Build the MCOMP program.
rem
setlocal
call src_pas %srcdir% mcomp

call src_pas %srcdir% mcomp_dbg

call src_lib %srcdir% mcompprog private
call src_msg %srcdir% mcomp

if "%debug_vs%"=="true" (
  set debug=/debug
  ) else (
  set debug=
  )

call src_link mcomp mcomp %debug% mcompprog.lib
call src_exeput mcomp

call src_doc mcomp
