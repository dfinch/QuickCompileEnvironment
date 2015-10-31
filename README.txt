Summary:
The Quick Compile Environment builder uses Windows batch files to create a compile environment for small projects, with a minimal amount of input or copy-pasting from the user. Paired with a text editor, and with g++ (MinGW) installed, this program aims to remove the need for a cumbersome IDE and its various project settings files, for smaller C++ projects. It also provides the option of automatically linking C++ OpenGL runtime libraries in the compile line of the compilation batch file, for those programs that are intended to use OpenGL for graphics.


Requirements:
- Must be using Windows
- Must have a valid installation of the g++ (MinGW) compiler


Usage:
# Setting up build environment
	1. Copy all files into a directory (known in the program as the utilities directory)
	2. Edit EnvBuilder.bat, changing the line "set utilpath=[...]" to reflect the utilities directory
	3. Copy EnvBuilder.bat into any directory you wish to start a coding project in
	4. Run EnvBuilder.bat, folloiwng its prompts and inputting the desired information
# Compiling the code
	5. Place source code files (.cpp) in the source directory ("src", by default), and header files (.h) in "include"
	6. Run compile.bat (or compile_openGL.bat) from your project directory
# Executing the code
	7. Assuming g++ was successful, open the "bin" directory, and run the executable file that you named earlier


Notes:
- If you rename the source directory (starts as "src"), make sure the srcdir variable in EnvBuilder.bat reflects this
- If you do not wish to compile all of (and only) the recently modified source files, specify the ones to compile on the line 
  "set sources=" in compile.bat (including file extentions, but excluding the path)


Errors:
- Currently does not work properly without some source files in place to compile