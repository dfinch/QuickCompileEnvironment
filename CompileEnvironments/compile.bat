set srcdir=src
set sources=

:: If the list of sources is empty, populate it with all .cpp files in srcdir
if "%sources%"=="" (
    if NOT "%srcdir"=="" (
        GOTO GETSOURCES
    ) else (
        GOTO ERRNODIR
    )
) else ECHO ---sources exist: %sources%---
GOTO PATHSOURCES


:: Populate the sources variable from a temp file
:POPSOURCES
set /p sources= < temptocompile
del temptocompile
ECHO Sources:
ECHO %sources%
GOTO PATHSOURCES


:: Create a list of source files with local paths
:PATHSOURCES
::for %%f in (%sources%) do (call :appendfile "%%f")
::for %%f in (%sources%) do (if defined srcfiles (set srcfiles=%srcfiles% %srcdir%/%%f) else (set srcfiles=%srcdir%/%%f))
FOR %%G in (%sources%) do ECHO|set /p=%srcdir%/%%G >> tempcompilelist
set /p srcfiles= < tempcompilelist
del tempcompilelist
ECHO Sourcefiles:
ECHO %srcfiles%
GOTO COMPILE


:COMPILE
@ECHO ON
:: Call g++, pass the list of source files
g++ -D_STDCALL_SUPPORTED -std=c++11 -o ./bin/%binfile% %srcfiles%
@ECHO OFF

echo srcdir=%srcdir%
echo sources=%sources%
echo srcfiles=%srcfiles%
echo binfile=%binfile%

GOTO END


:: Get a list of all source files in srcdir, and add to sources
:GETSOURCES

::cd "%srcdir%"

dir %srcdir% /b /o:-d /T:W /A:-D > tempdirfiles
ECHO TEMPDIRFILES:
type tempdirfiles
ECHO _____________
::                                          %srcdir%/
FOR /F %%G in (tempdirfiles) do ECHO|set /p=%%G >> tempfileslist
ECHO TEMPFILESLIST:
type tempfileslist
ECHO.
ECHO ______________

set /p dirfiles= < tempfileslist
del tempdirfiles
del tempfileslist

ECHO Dirfiles:
ECHO %dirfiles%

ECHO ITER:
FOR %%G in (%dirfiles%) do (ECHO %%G)
ECHO STARTING...

FOR %%G in (%dirfiles%) do (
    if not %%G==%binfile% (
        ECHO|set /p=%%G >> temptocompile
    ) else (
        GOTO POPSOURCES
    )
)
ECHO ---- Finished iterating ----
GOTO POPSOURCES


:: Append the current file to the list of source files to compile
:appendfile
ECHO APPENDING FILE TO SRCFILES
if defined srcfiles (
    set srcfiles=%srcfiles% %srcdir%/%1
) else (
    set srcfiles=%srcdir%/%1
)


:: Errors
:ERRNODIR
echo ERROR: compile.bat - No source directory specified
GOTO END


:: Pause to read the compile output
:END
pause