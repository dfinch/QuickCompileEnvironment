@ECHO OFF

:BEGIN
CLS


:: Set utilities paths
set utilpath=C:\UTILITIES\CompileEnvironments


:: Prompt the user for a project name (for the directory)
set rootdir=HelloWorld
set /p rootdir="Project name? "

:: Prompt the user for an executable name within the batch compile script
set bf=a.exe
set /p bf="Executable name? "


:: Prompt the user for whether to use the OpenGL compile environment or not
:GLCHOICE

::CHOICE /N /C:12 /M "Use regular or OpenGL batch compile script? (1=Regular, 2=OpenGL)"%1

::set usegl=%errorlevel%
::IF %usegl% ==2 GOTO YESGL
::IF %usegl% ==1 GOTO NOGL
::GOTO END

set usegl=n
set /p usegl="Include OpenGL runtime libraries? "
IF %usegl% ==y GOTO YESGL
IF %usegl% ==Y GOTO YESGL
IF %usegl% ==yes GOTO YESGL
IF %usegl% ==YES GOTO YESGL
GOTO NOGL


:: Set up build environment for OpenGL use
:YESGL
ECHO Creating build environment for OpenGL...
mkdir %rootdir%
cd %rootdir%
mkdir lib
copy %utilpath%\OpenGL\* lib

:: Prepend the executable file name to the compile script
ECHO @ECHO OFF > temp.bat
ECHO set binfile=%bf% >> temp.bat
type %utilpath%\compile_openGL.bat >> temp.bat
type temp.bat > compile_openGL.bat
del temp.bat
GOTO DIRS


:: Set up build environment for non-OpenGL use
:NOGL
ECHO Creating build environment...
mkdir %rootdir%
cd %rootdir%
mkdir lib

:: Prepend the executable file name to the compile script
ECHO @ECHO OFF > temp.bat
ECHO set binfile=%bf% >> temp.bat
type %utilpath%\compile.bat >> temp.bat
type temp.bat > compile.bat
del temp.bat
GOTO DIRS


:: Create the remainder of the directories for the build environment
:DIRS
mkdir bin
mkdir src
cd src
mkdir include
cd ..
GOTO END


:END
ECHO Process complete.
pause