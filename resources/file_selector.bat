@echo off
mode con: cols=37 lines=3
echo.
echo  %I_%%CC_% Opening file selection dialog... %_%
for /f "delims=" %%I in ('powershell -noprofile -command "%OpenFileSelector%"') do echo "%%I">"%SelectorSelectedFile%"
EXIT
