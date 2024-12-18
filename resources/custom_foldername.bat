@echo off
chcp 65001 >nul
for %%F in ("%cd%") do set "foldername=%%~nxF"
set "InputFolderName=_0"
set "InputLogo=_0"
set "custom-FolderName-HaveTheLogo="
title Custom folder name for "%FolderName%"
echo.
echo.
echo                  %W_%%I_%     Custom Folder Name     %_%       
echo.
echo %TAB%Folder Name: %ESC%%YY_%%FolderName%%ESC%
echo %TAB%Template   : %ESC%%CC_%%Templatename%%ESC%
echo.
echo.
echo %_% • %G_%%G_%Press "%C_%O%G_%" and hit Enter to %C_%open%G_% the file selection dialog.%_%
echo %_% • %G_%%G_%Press "%C_%C%G_%" and hit  Enter to  open the %C_%Collections%G_%  folder.%_%
echo %_% • %G_%You  can  also %PP_%drag and  drop%_%%G_% an %C_%image%G_%  into  this window.%_%
echo %_% • %G_%Leave it empty  to  skip and  use  the default  settings.%_%
echo.
echo %W_% ► %G_%Enter a folder name or an image file path:
set /p "InputFolderName=%W_%  %_%%C_% "
set "InputFolderName=%InputFolderName:"=%"
if exist "%cfn1%" del /q "%cfn1%"

if /i "%InputFolderName%"=="o" call :file_selector

if /i "%InputFolderName%"=="_0" (
	echo    %G_%%I_% Skipped %_%
	echo set "custom-FolderName=No">>"%cfn1%"
	goto exit
)
if /i "%InputFolderName%"=="." goto empty
if /i "%InputFolderName%"==" " goto empty
if /i "%InputFolderName%"=="_" goto empty

if exist "%InputFolderName%" for %%I in ("%InputFolderName%") do (
	for %%X in (%ImageSupport%) do if "%%X"=="%%~xI" (
		echo set "Logo=%%~fI">>"%cfn1%"
		echo set "LogoName=%%~nxI">>"%cfn1%"
		echo set "use-Logo-instead-FolderName=Yes">>"%cfn1%"
		echo set "custom-FolderName-HaveTheLogo=Yes">>"%cfn1%"
		goto exit
	)
)
echo set "foldername=%InputFolderName%">>"%cfn1%"
echo set "display-FolderName=Yes">>"%cfn1%"
echo set "use-Logo-instead-FolderName=No">>"%cfn1%"
goto exit

:empty
echo set "display-FolderName=no">>"%cfn1%"
echo set "use-Logo-instead-FolderName=no">>"%cfn1%"
goto exit

:exit
if /i not "%multi-FolderName%"=="yes" exit
set "InputFolderName2="
echo.
echo %W_% ► %G_%Enter the second folder name, or leave it empty to skip:
set /p "InputFolderName2=%W_%  %_%%C_% "
type nul "%cfn2%"
set InputFolderName2=%InputFolderName2:"=%
if defined InputFolderName2 echo "%InputFolderName2%">>"%cfn2%"
exit