@echo off
rem ===========================================================================
rem  build_padwrite.bat - builds PadWrite.exe with MinGW-w64.
rem
rem  Usage:
rem    build_padwrite.bat [Release|Debug] [run]
rem
rem  The first argument selects configuration (default: Release).
rem  Pass "run" as any argument to launch the executable after a successful build.
rem ===========================================================================
setlocal enabledelayedexpansion

set "MINGW=C:\Users\pr30565\Nim_code\mingw64\bin"
set "GXX=%MINGW%\g++.exe"
set "WINDRES=%MINGW%\windres.exe"
set "HERE=%~dp0"
if "%HERE:~-1%"=="\" set "HERE=%HERE:~0,-1%"
set "OBJ=%HERE%\obj"

if not exist "%GXX%" (
  echo [ERRORE] g++ non trovato in "%GXX%"
  exit /b 1
)
if not exist "%WINDRES%" (
  echo [ERRORE] windres non trovato in "%WINDRES%"
  exit /b 1
)

rem --- parse args ---
set "CONFIG=Release"
set "RUN="
for %%A in (%*) do (
  if /I "%%~A"=="Debug" set "CONFIG=Debug"
  if /I "%%~A"=="Release" set "CONFIG=Release"
  if /I "%%~A"=="run" set "RUN=1"
)

if /I not "%CONFIG%"=="Debug" if /I not "%CONFIG%"=="Release" (
  echo [ERRORE] Configurazione sconosciuta "%CONFIG%". Usa Release o Debug.
  exit /b 1
)

set "OUTDIR=%HERE%\%CONFIG%_mingw"
if not exist "%OBJ%" mkdir "%OBJ%"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

set "CXXFLAGS=-std=gnu++14 -municode -mwindows -Wall -Wextra -DUNICODE -D_UNICODE -DWIN32 -D_WINDOWS -D_WIN32_WINNT=0x0601 -I."
if /I "%CONFIG%"=="Debug" (
  set "CXXFLAGS=%CXXFLAGS% -g -O0 -DDEBUG"
) else (
  set "CXXFLAGS=%CXXFLAGS% -O2 -DNDEBUG -s"
)

set "LDFLAGS=-municode -mwindows"
set "LIBS=-ld2d1 -lwindowscodecs -lole32 -lgdi32 -luser32 -ldwrite -luuid -lmsimg32 -lpropsys -lshlwapi -limm32 -lcomdlg32"

echo ============================================================
echo  PadWrite - build %CONFIG% (MinGW-w64)
echo ============================================================

echo [1/3] Compilazione risorse...
"%WINDRES%" "%HERE%\PadWrite.rc" -O coff -o "%OBJ%\PadWrite.res"
if errorlevel 1 goto :fail

echo [2/3] Compilazione sorgenti...
set "OBJS="
for %%F in (EditableLayout.cpp InlineImage.cpp PadWrite.cpp RenderTarget.cpp TextEditor.cpp) do (
  echo   %%F
  "%GXX%" %CXXFLAGS% -c "%HERE%\%%F" -o "%OBJ%\%%~nF.o"
  if errorlevel 1 goto :fail
  set "OBJS=!OBJS! "%OBJ%\%%~nF.o""
)

echo [3/3] Link...
"%GXX%" %LDFLAGS% -o "%OUTDIR%\PadWrite.exe" !OBJS! "%OBJ%\PadWrite.res" %LIBS%
if errorlevel 1 goto :fail

echo.
echo Build OK: %OUTDIR%\PadWrite.exe
if defined RUN (
  echo Avvio PadWrite.exe...
  start "" "%OUTDIR%\PadWrite.exe"
)
exit /b 0

:fail
echo.
echo Build FALLITA.
exit /b 1
