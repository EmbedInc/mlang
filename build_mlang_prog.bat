@echo off
rem
rem   Build the MLANG program.
rem
setlocal
call src_pas %srcdir% mlang

call src_pas %srcdir% mlang_dbg

call src_lib %srcdir% mlangprog private
call src_msg %srcdir% mlang

if "%debug_vs%"=="true" (
  set debug=/debug
  ) else (
  set debug=
  )

call src_link mlang mlang %debug% mlangprog.lib
call src_exeput mlang
