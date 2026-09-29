@echo off
rem =====================================================================
rem build_mingw32.bat  (ASCII only -- cmd parses .bat in GBK/ANSI CP,
rem                     UTF-8 Chinese comments will corrupt the parser)
rem
rem Reproduces the environment of G:\msys64-20241208\mingw32.exe:
rem   mingw32.exe presets MSYSTEM=MINGW32 and starts "bash --login".
rem   /etc/profile + /etc/msystem.d/MINGW32 then inject (matches env.txt):
rem     MSYSTEM=MINGW32
rem     MINGW_PREFIX=/mingw32          MSYSTEM_PREFIX=/mingw32
rem     MINGW_CHOST=i686-w64-mingw32   MSYSTEM_CHOST=i686-w64-mingw32
rem     MSYSTEM_CARCH=i686             MINGW_PACKAGE_PREFIX=mingw-w64-i686
rem     PATH=/mingw32/bin:/usr/local/bin:/usr/bin:/bin:<windows path>
rem     PKG_CONFIG_PATH=/mingw32/lib/pkgconfig:/mingw32/share/pkgconfig
rem     PKG_CONFIG_SYSTEM_INCLUDE_PATH=/mingw32/include
rem     PKG_CONFIG_SYSTEM_LIBRARY_PATH=/mingw32/lib
rem     ACLOCAL_PATH=/mingw32/share/aclocal:/usr/share/aclocal
rem     CONFIG_SITE=/etc/config.site   TMP/TEMP=/tmp   HOME=/home/<user>
rem   We launch bash --login the same way; profile sets everything above.
rem   MAME makefile then picks: MSYSTEM=MINGW32 -> x86, OVERRIDE_CC=clang
rem   (makefile line 93) -> target windows_x86_clang (32-bit clang build).
rem
rem Usage:
rem   build_mingw32.bat
rem       (default: tinymame, 9 driver sources = cps1/cps2/cps3/fcrash/
rem        cps1bl_5205/cps1bl_pic/neogeo/pgm/pgm2, 1117 drivers)
rem   build_mingw32.bat -j4
rem   build_mingw32.bat REGENIE=1 SUBTARGET=tinymame SOURCES=<cpp list> -j4
rem   (REGENIE=1 is REQUIRED after changing SOURCES, or project makefiles
rem    won't be regenerated)
rem =====================================================================

setlocal
set "MSYS2_ROOT=G:\msys64-20241208"
set "MAKE_EXE=%MSYS2_ROOT%\usr\bin\bash.exe"

if not exist "%MAKE_EXE%" (
    echo [build_mingw32] ERROR: %MAKE_EXE% not found
    exit /b 1
)

rem --- same as mingw32.exe: preset MSYSTEM, let /etc/profile do the rest ---
set "MSYSTEM=MINGW32"

rem --- default make args (9-source driver team; see XP32-BUILD-NOTES.md 6.1) ---
set "MAKE_ARGS=%*"
if "%MAKE_ARGS%"=="" set "MAKE_ARGS=SUBTARGET=tinymame SOURCES=src/mame/capcom/cps1.cpp,src/mame/capcom/cps2.cpp,src/mame/capcom/cps3.cpp,src/mame/capcom/fcrash.cpp,src/mame/capcom/cps1bl_5205.cpp,src/mame/capcom/cps1bl_pic.cpp,src/mame/snk/neogeo.cpp,src/mame/igs/pgm.cpp,src/mame/igs/pgm2.cpp -j3"

rem --- build output location (obj/generated/projects/libs). rdisk is a
rem     symlink -> R:\Mame (RAM disk): genie.lua line 19 CONCATS build-dir
rem     onto MAME_DIR, so BUILDDIR must stay relative; routing it through
rem     the symlink puts all output physically on R:. The exe itself always
rem     lands at the repo root (genie targetdir = MAME_DIR, depth-adjusted),
rem     so no extra "build" level is needed and the relative paths in the
rem     generated makefiles stay identical to the in-tree layout.
rem     Clear MAME_BUILDDIR ("set MAME_BUILDDIR=") to build in-tree build\ .
set "MAME_BUILDDIR=rdisk"
set "BUILDDIR_ARG="
if not "%MAME_BUILDDIR%"=="" set "BUILDDIR_ARG=BUILDDIR=%MAME_BUILDDIR:\=/%"

rem --- convert this script's dir to forward-slash path bash understands ---
set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"
set "REPO_UNIX=%REPO_DIR:\=/%"

echo === build_mingw32: MSYS2=%MSYS2_ROOT% MSYSTEM=%MSYSTEM% ===
echo === repo : %REPO_UNIX% ===
if not "%BUILDDIR_ARG%"=="" echo === out  : %MAME_BUILDDIR% ===
echo === make : %MAKE_ARGS% ===
echo.

"%MAKE_EXE%" --login -c "cd '%REPO_UNIX%' && make %BUILDDIR_ARG% %MAKE_ARGS%"
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo === BUILD OK ===) else (echo === BUILD FAILED, rc=%RC% ===)
endlocal & timeout -t 10 & exit /b %RC%
