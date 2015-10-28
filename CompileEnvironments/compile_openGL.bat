set srcdir=src
set sources=*.cpp

:: Create a list of source files with local paths
for %%f in (%sources%) do call :appendfile %%f

@ECHO ON
:: Call g++, pass the source files, and link the local libraries
g++ -D_STDCALL_SUPPORTED -std=c++11 -o ./bin/%binfile% %srcfiles% -L ./lib -lglut32win -lopengl32 -lglu32
@ECHO OFF

GOTO END


:: Append the current file to the list of source files to compile
:appendfile
if defined srcfiles (
    set srcfiles=%srcfiles% %srcdir%/%1
) else (
    set srcfiles=%srcdir%/%1
)


:: Pause to read the compile output
:END
pause