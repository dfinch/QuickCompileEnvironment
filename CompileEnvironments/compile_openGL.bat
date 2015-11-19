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
dir %srcdir%\*.cpp /A:-D-S-H /b 1> numfiles 2> fnferror
for /f %%A in ('type numfiles ^| find /v /c ""') do set filecount=%%A
del numfiles
del fnferror
:: If no source files exist, go to the appropriate error
if "%filecount%"=="0" (
	GOTO ERRNOFILES
)


:: Place a list of all files in srcdir into a temporary file
:: in descending order of their modification (for use in compile control)
dir %srcdir% /b /o:-d /T:W /A:-D > tempdirfiles
FOR /F %%G in (tempdirfiles) do (
	if not "%%~xG"==".o" (
		ECHO|set /p=%%G >> tempfileslist
	)
)
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
if exist temptocompile (
	set /p sources= < temptocompile
	del temptocompile
) else (
	if "%dirfiles%"=="" (
		GOTO ERRNOFILES
	) else (
		GOTO CHECKBIN
	)
)
GOTO PATHSOURCES


:: Check if the executable file exists, and recompile if missing
:CHECKBIN
dir /b bin\%binfile%.exe 1> binfoundfile 2> fnferror
set /p binfound= < binfoundfile
del binfoundfile
del fnferror
if "%binfound%"=="" (
	GOTO RESETCOMPILE
) else (
	GOTO WARNNOFILES
)


:: Reset the compile process after deleting the compilecontrol file
:RESETCOMPILE
cd %srcdir%
if exist compilecontrol DEL /A:H compilecontrol
cd ..
GOTO BEGIN


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
if NOT "%srcfiles%"=="" (
    GOTO COMPILE
) else (
    GOTO ERRNOFILES
)


:: Get a list of object files in the source directory
:GETOBJECTS
for /f %%A in ('dir %srcdir%\*.o /a-d-s-h /b ^| find /v /c ""') do set objectcount=%%A
if "%objectcount%"=="0" (
    GOTO ERRNOOBJECTS
)

:: Place a list of all object files into a temporary file
dir %srcdir%\*.o /b > tempobjfiles
FOR /F %%G in (tempobjfiles) do ECHO|set /p=%%G >> tempobjectlist
:: Set the objects variable equal to this list of unpathed object files
set /p objects= < tempobjectlist
del tempobjfiles
del tempobjectlist
GOTO PATHOBJECTS


:: Add paths to the list of objects
:PATHOBJECTS
FOR %%G in (%objects%) do ECHO|set /p=%srcdir%/%%G >> templinklist
set /p objfiles= < templinklist
del templinklist
GOTO LINK


:: Compile the source files into object files
:COMPILE
echo Compiling files: %sources%
echo ________________________________________________________________________________
cd %srcdir%
@ECHO ON
:: Call g++, pass the list of source files
g++ -D_STDCALL_SUPPORTED -std=c++11 -Wall -c %sources%
@ECHO OFF

if errorlevel 1 GOTO COMPILEFAILURE
cd ..
GOTO GETOBJECTS


:: Link compiled object files together to make the executable
:LINK
@ECHO ON
g++ -D_STDCALL_SUPPORTED -std=c++11 -Wall -o ./bin/%binfile% %objfiles% -L ./lib -lglut32win -lopengl32 -lglu32
@ECHO OFF

if errorlevel 1 GOTO LINKFAILURE
GOTO COMPILESUCCESS


:: Create hidden file named compilecontrol (for use in getting recent sources)
:COMPILESUCCESS
cd %srcdir%
if exist compilecontrol DEL /A:H compilecontrol
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


:: Tell user that linking failed and exit
:LINKFAILURE
echo ________________________________________________________________________________
echo Linking failed. g++ returned error(s) (see above)
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

:ERRNOOBJECTS
echo ERROR: compile.bat - No valid object files.
GOTO END

:ERRBADFILE
echo ERROR: compile.bat - File "%%1" does not exist.
GOTO LAST

:WARNNOFILES
echo compile.bat - Nothing to do. Sources have already been compiled.
GOTO END

:: Pause to read the compile output
:END
pause

:: End the program, but don't pause (use in called subroutines)
:LAST
