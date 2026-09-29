@echo off
rem =====================================================================
rem build_nobash.bat —— 不经 bash 登录壳的直连版构建脚本
rem
rem 原理:把 mingw32\bin(工具链)与 usr\bin(sh/mkdir/rm/git 等配方工具)
rem 加进 PATH 后直接调用 make,由 make 自动选用 sh.exe 执行配方,
rem 构建结果与 build_mingw32.bat(bash 路线)完全一致。
rem
rem 注意:本文件必须保存为 GBK/ANSI 编码 + CRLF 行尾(cmd 硬性要求),
rem       用 UTF-8 存中文注释会被 cmd 按 GBK 误读导致命令损坏。
rem
rem 用法:
rem   build_nobash.bat                 缺省 = 九源组队(1117 驱动)
rem   build_nobash.bat -j4             任意 make 参数透传
rem   build_nobash.bat REGENIE=1 ...   改 SOURCES 后必须加 REGENIE=1
rem =====================================================================

setlocal
set "MSYS2_ROOT=G:\msys64-20241208"

rem --- 与 mingw32.exe 等价的环境变量(不经 /etc/profile,手工设齐) ---
set "MSYSTEM=MINGW32"
set "MINGW_PREFIX=%MSYS2_ROOT:\=/%/mingw32"

rem --- PATH:mingw32 工具链优先,usr\bin 兜底配方工具 ---
set "PATH=%MSYS2_ROOT%\mingw32\bin;%MSYS2_ROOT%\usr\bin;%PATH%"

rem --- 输出到内存盘 rdisk(与 build_mingw32.bat 相同机制) ---
set "MAME_BUILDDIR=rdisk"
set "BUILDDIR_ARG="
if not "%MAME_BUILDDIR%"=="" set "BUILDDIR_ARG=BUILDDIR=%MAME_BUILDDIR:\=/%"

rem --- 缺省 make 参数(九源组队,详见 XP32-BUILD-NOTES.md 6.1) ---
set "MAKE_ARGS=%*"
if "%MAKE_ARGS%"=="" set "MAKE_ARGS=SUBTARGET=tinymame SOURCES=src/mame/capcom/cps1.cpp -j3"
rem ,src/mame/capcom/cps2.cpp,src/mame/capcom/cps3.cpp,src/mame/capcom/fcrash.cpp,src/mame/capcom/cps1bl_5205.cpp,src/mame/capcom/cps1bl_pic.cpp,src/mame/snk/neogeo.cpp,src/mame/igs/pgm.cpp,src/mame/igs/pgm2.cpp"

cd /d "%~dp0"
echo === build_nobash: cmd 直连 make,不经 bash ===
echo === out  : %MAME_BUILDDIR% ===
echo === make : %MAKE_ARGS% ===
echo.

make %BUILDDIR_ARG% %MAKE_ARGS%
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo === BUILD OK ===) else (echo === BUILD FAILED, rc=%RC% ===)
endlocal & timeout -t 10 & exit /b %RC%
