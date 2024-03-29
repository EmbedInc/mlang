@echo off
rem
rem   Set up for building a Pascal module.
rem
call build_vars

call src_go %srcdir%
call src_getfrom sys base.ins.pas
call src_getfrom sys sys.ins.pas
call src_getfrom util util.ins.pas
call src_getfrom string string.ins.pas
call src_getfrom file file.ins.pas
call src_getfrom strflex strflex.ins.pas
call src_getfrom fline fline.ins.pas
call src_getfrom escr escr.ins.pas
call src_getfrom syn syn.ins.pas
call src_getfrom code code.ins.pas
call src_getfrom mlang mcomp.ins.pas

make_debug debug_switches.ins.pas
call src_builddate "%srcdir%"
