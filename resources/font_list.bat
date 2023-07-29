@echo off
cd /d "%~dp0"&chcp 65001 >nul
for /f "tokens=1,2 delims=:" %%I in ('convert.exe -list font') do (
	set /a count+=1
	if /i "%%I"=="  Font" set "font=%%J"
	if /i "%%I"=="    style" set "info_style=[90mStyle:[90m%%J"
	if /i "%%I"=="    stretch" set "info_stretch=[90mStretch:[90m%%J"
	if /i "%%I"=="    weight" set "info_weight=[90mWeight:[90m%%J"
	if /i "%%I"=="    glyphs" set "info_glyphs=[90mGlyphs:[90m%%J"&call :info
)
echo.&echo.&echo  [90mPress [31mx [90mto close this window.&CHOICE /N /C x

:info
if not "%fontinfo%"=="%font%" (set "fontinfo=%font%") else exit /b
if %count% equ 7 del "font_list.txt" 
>>"font_list.txt" echo "%font:~1%"

echo [30m"[0m%font:~1%[30m"[0m
echo  %info_style%	%info_stretch%	%info_weight%	%info_glyphs%
echo.
exit /b