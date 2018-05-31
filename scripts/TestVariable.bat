@echo off
set VarArgument1=%~1
set VarArgument2=%~2
IF %VarArgument1%==%VarArgument2% ( goto noerror ) ELSE ( goto error )

:noerror
echo "Values are identics"
EXIT /b 0
:error
echo "Values are differents"
EXIT /B 1
:end
