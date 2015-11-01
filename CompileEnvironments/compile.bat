set srcdir=src
set sources=

:: If the list of sources is empty, populate it with all .cpp files in srcdir
:BEGIN
if "%sources%"=="" (
    if NOT "%srcdir%"=="" (
        if exist %srcdir% (
            GOTO GETSOURCES
        ) else (
            GOTO ERRBADDIR
        )
    ) else (
        GOTO ERRNODIR
    )
) else (
    GOTO PATHSOURCES
)


:: Get a list of all source files in srcdir, and add to sources
:GETSOURCES
:: Get the number of files in the directory
for /f %%A in ('dir %srcdir%\*.cpp /a-d-s-h /b ^| find /v /c ""') do set filecount=%%A
if "%filecount%"=="0" (
    GOTO ERRNOFILES
)

:: Place a list of all files in srcdir into a temporary file
:: in descending order of their modification (for use in compile control)
dir %srcdir% /b /o:-d /T:W /A:-D > tempdirfiles
FOR /F %%G in (tempdirfiles) do ECHO|set /p=%%G >> tempfileslist
set /p dirfiles= < tempfileslist
del tempdirfiles
del tempfileslist

:: Add source files to the list to be compiled
:: until it hits the file made at the last successful build
FOR %%G in (%dirfiles%) do (
    if not %%G==compilecontrol (
        ECHO|set /p=%%G >> temptocompile
    ) else (
        GOTO POPSOURCES
    )
)
GOTO POPSOURCES


:: Populate the sources variable from a temp file
:POPSOURCES
set /p sources= < temptocompile
del temptocompile
GOTO PATHSOURCES


:: Add paths to the list of source files
:PATHSOURCES
FOR %%G in (%sources%) do ECHO|set /p=%srcdir%/%%G >> tempcompilelist
set /p srcfiles= < tempcompilelist
del tempcompilelist
GOTO CHECKSOURCES


:: Check to make sure that sources exist
:CHECKSOURCES
for %%f in (%srcfiles%) do (if exist %%f (ECHO|set /p=%%f >> tempvalidlist))
set /p srcfiles= < tempvalidlist
del tempvalidlist
::for %%f in (%sources%) do (call :appendfile "%%f")
if NOT "%srcfiles%"=="" (
    GOTO COMPILE
) else (
    GOTO ERRNOFILES
)


:COMPILE
echo Compiling files: %sources%
echo ________________________________________________________________________________
@ECHO ON
:: Call g++, pass the list of source files
g++ -D_STDCALL_SUPPORTED -std=c++11 -o ./bin/%binfile% %srcfiles%
@ECHO OFF

if errorlevel 1 GOTO COMPILEFAILURE
GOTO COMPILESUCCESS


:: Create hidden file named after executable (for use in getting recent sources)
:COMPILESUCCESS
cd %srcdir%
DEL /A:H compilecontrol
cd ..
echo ::: Compilation control file. Delete this file to compile everything. ::: > %srcdir%/compilecontrol
ATTRIB +H %srcdir%/compilecontrol
echo ________________________________________________________________________________
echo Compilation succeeded! Executable created in /bin/
GOTO END


:: Tell user that compilation failed and exit
:COMPILEFAILURE
echo ________________________________________________________________________________
echo Compile failed. g++ returned error(s) (see above)
GOTO END


:: Errors
:ERRNODIR
echo ERROR: compile.bat - No source directory specified.
GOTO END

:ERRBADDIR
echo ERROR: compile.bat - Specified source directory does not exist.
GOTO END

:ERRNOFILES
echo ERROR: compile.bat - No valid source files.
GOTO END

:ERRBADFILE
echo ERROR: compile.bat - File "%%1" does not exist.
GOTO LAST

:: Pause to read the compile output
:END
pause

:: End the program, but don't pause (use in called subroutines)
:LAST
