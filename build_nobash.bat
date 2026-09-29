@echo off
rem =====================================================================
rem build_nobash.bat ¡ª Build script that runs directly without a bash login shell
rem
rem Mechanism: Adds mingw32\bin (toolchain) and usr\bin (recipe tools like
rem sh/mkdir/rm/git) to the PATH and calls make directly; make automatically
rem selects sh.exe to execute recipes. The build output is identical to
rem that of build_mingw32.bat (the bash-based approach).
rem
rem Note: This file must be saved with GBK/ANSI encoding and CRLF line endings
rem       (a strict requirement of cmd); saving Chinese comments in UTF-8
rem       causes cmd to misinterpret them as GBK, corrupting the commands. rem
rem Usage:
rem   build_nobash.bat                 Default = Jiuyuan Team Build (1117 driver)
rem   build_nobash.bat -j4             Passes arbitrary make arguments through
rem   build_nobash.bat REGENIE=1 ...   Must add REGENIE=1 after modifying SOURCES
rem =====================================================================

setlocal
set "MSYS2_ROOT=G:\msys64-20241208"

rem --- Environment variables equivalent to mingw32.exe (bypasses /etc/profile; set manually) ---
set "MSYSTEM=MINGW32"
set "MINGW_PREFIX=%MSYS2_ROOT:\=/%/mingw32"

rem --- PATH: mingw32 toolchain takes precedence; usr\bin provides fallback build tools ---
set "PATH=%MSYS2_ROOT%\mingw32\bin;%MSYS2_ROOT%\usr\bin;%PATH%"

rem --- Output to RAM disk (same mechanism as build_mingw32.bat) ---
set "MAME_BUILDDIR=rdisk"
set "BUILDDIR_ARG="
if not "%MAME_BUILDDIR%"=="" set "BUILDDIR_ARG=BUILDDIR=%MAME_BUILDDIR:\=/%"

rem --- Default make arguments (Jiuyuan Team Build; see XP32-BUILD-NOTES.md 6.1) ---
set "MAKE_ARGS=SUBTARGET=tinymame SOURCES=src/mame/capcom/cps1.cpp,src/mame/capcom/cps2.cpp,src/mame/capcom/cps3.cpp,src/mame/capcom/fcrash.cpp,src/mame/capcom/cps1bl_5205.cpp,src/mame/capcom/cps1bl_pic.cpp,src/mame/neogeo/neogeo.cpp,src/mame/igs/pgm.cpp,src/mame/igs/pgm2.cpp %*"

cd /d "%~dp0"
echo === build_nobash: cmd directly connected to make, without bash ===
echo === out : %MAME_BUILDDIR% ===
echo === make : %MAKE_ARGS% ===
echo.

make %BUILDDIR_ARG% %MAKE_ARGS%
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo === BUILD OK ===) else (echo === BUILD FAILED, rc=%RC% ===)
endlocal & timeout -t 10 & exit /b %RC%