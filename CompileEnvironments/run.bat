set killwhendone=false

:: If the user inputs the /c argument for run.bat, kill the program's cmd window when done.
if "%1"=="/c" (
	set killwhendone=true
)

:: Run the executable from the bin directory level, if it exists
cd bin
if exist %binfile%.exe (
	if "%killwhendone%"=="true" (
		start cmd /c %binfile%.exe
	) else (
		start cmd /k %binfile%.exe
	)
) else (
	:: Warn the user if it doesn't exist
	ECHO run.bat - Error: %binfile%.exe does not exist. Run compile.bat to create it.
)

:: If the user ran run.bat from cmd, prompt them if they don't know about the /c argument
if "%killwhendone%"=="false" (
	if exist %binfile%.exe (
		ECHO run.bat - If you wish to close the cmd window for your program when done,
		ECHO           use the /c argument with run.bat or set killwhendone=true
	)
	cd ..
	:: Pause if the program isn't set to exit when finished
	PAUSE
) else (
	:: Close run.bat if the program is set to exit after running
	cd ..
)
