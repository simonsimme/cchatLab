@echo off
REM --- Set the base directory (directory where this script is located) ---
set "BASEDIR=%~dp0"

REM --- Navigate to the base directory ---
cd /d "%BASEDIR%"

REM --- Navigate to the lib directory ---
cd "%BASEDIR%\lib"

REM --- Check if the lib folder exists ---
if not exist "%BASEDIR%\lib" (
    echo lib directory not found! Exiting...
    pause
    exit /b 1
)

REM --- Compile lex.xrl into lex.erl using leex ---
if exist lex.xrl (
    echo Compiling lex.xrl into lex.erl...
    erl -noshell -eval "leex:file(lex)" -s init stop
) else (
    echo lex.xrl not found.
)

REM --- Compile grm.yrl into grm.erl using yecc ---
if exist grm.yrl (
    echo Compiling grm.yrl into grm.erl...
    erl -noshell -eval "yecc:file(grm)" -s init stop
) else (
    echo grm.yrl not found.
)

REM --- Navigate back to the base directory ---
cd "%BASEDIR%"

REM --- Compile all Erlang source files in the main directory ---
echo Compiling Erlang source files in the main directory...
erlc client.erl server.erl

REM --- Compile all .erl files in the lib directory ---
echo Compiling all .erl files in the lib directory...
for %%f in (lib\*.erl) do (
    echo Compiling %%f...
    erlc %%f
)

REM --- Compilation completed ---
echo Compilation completed.

REM --- Clean operation (optional) ---
if /I "%1"=="clean" (
    echo Cleaning up .beam and .erl files...
    del /Q *.beam
    del /Q lib\*.beam
    del /Q lib\lex.erl lib\grm.erl
    echo Clean-up done.
)

REM --- Pause to keep the window open ---
pause
