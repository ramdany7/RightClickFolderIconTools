@echo off
:: Update v0.4
:: 2024-06-27 Fixed: "LabelExpected ' @ error/annotate.c/GetMultilineTypeMetrics/804." on Windows 11, DVDBox, and BeOrigin templates.
:: 2024-06-27 Fixed: Couldn't open 'Choose template' and 'Define keywords' menus in the root/drive directory.
:: 2024-06-28 Fixed: "The syntax of the command is incorrect." on the 'Change folder icon' right-click menu.
:: 2024-06-29 Added: Progress info on the title bar when generating folder icons.
:: 2024-07-06 Added: Capability to scan, generate, and remove folder icons in all subfolders (recursive).
:: 2024-07-06 Added: "More..." button to the background right-click menu to open RCFI Tools extended features.
:: 2024-07-09 Added: Ability to rename the icon's file name.
:: 2024-07-10 Added: Config option to set the icon's file name when applying it to a folder.
:: 2024-07-11 Added: Rules to the folder icon remover to avoid deleting non-.ico files, preventing accidental deletion of important files.
:: 2024-07-15 Resolved: Issue #12 – Network drive/UNC paths not supported. [SOLVED]
:: 2024-07-19 Added: Ability to move the icon's path.
:: 2024-07-24 Added: Use "#ID" in config 'IconFileName' to generate a random 6-digit string, which helps avoid the icon cache displaying 
::            the previous icon instead of the newly assigned one (unless you refresh the icon cache by restarting Explorer).
:: 2024-07-30 Added: 'Move' and 'Rename' features to the folder right-click menu.
:: 2024-07-31 Added: Ability to hide and unhide "icon.ico" and "desktop.ini" files.
:: 2024-08-14 Fixed: 'Move' and 'Rename' functions to display the correct icon file name and show the proper stats.
:: 2024-08-24 Added: Ability to 'Define keywords', 'Rename Icons', and 'Move Icons' features to maintain a history of previously inserted values.
:: 2024-09-20 Removed: [Template: Win11Folderify] "Picture-opacity" option because it caused transparency to render as black. 
::            (Might fix and add it back later if anyone needs it?)
:: 2024-09-20 Added: [Template: Win11Folderify] config "Picture-Drawing=original" to display the picture as is. Requested #13
:: 2024-09-20 Added: [Template: Win11Folderify] config to change the shadow.
:: 2024-09-30 Added: [Template: Kometa] New template. Requested #11
:: 2024-09-30 Relocated: [Template: All] "NFO-file extractor" script to /resources/extract-NFO.bat.
:: 2024-09-30 Added: [Template: All] Option to choose the preferred rating available inside the .nfo file.
:: 2024-09-30 Fixed: Unable to replace the folder icon when IconFileName doesn’t include #ID.
:: 2024-10-01 Fixed: Unable to use "*" (wildcard only) as a keyword.
:: 2024-10-01 Fixed: No need to run as admin to install or uninstall RCFI Tools.
:: 2024-10-11 Fixed: Opening 'Define Keywords' from the folder right-click menu didn't display correctly.


setlocal
set name=RCFI Tools
set version=v0.4
chcp 65001 >nul
PUSHD    "%~dp0"
title %name%   "%cd%"

:Start                            
set "SelectedThing=%~f1"
set "SelectedThingPath=%~dp1"
call :Config-Varset
call :Config-Startup
call :Setup
if defined Context goto Input-Context

:Intro                            
echo.
echo.
echo.
echo. 
if not defined OpenFrom (
	echo                             %I_% %name% %version% %_%%-%
	echo.
	echo                %GN_%Activate%G_%/%GN_%Act%G_%   to activate Folder Icon Tools.
	echo                %GN_%Deactivate%G_%/%GN_%Dct%G_% to deactivate Folder Icon Tools. 
	echo.
) else (
echo %TAB%                  %PP_%Drag and  drop%_%%G_% an %C_%image%G_% into  this  window,
echo %TAB%                  then press Enter to change the folder icon.%_%
echo.
)
goto Options-Input

:Status                           
%p1%
echo   %_%------- Current Status ----------------------------------------
echo   Directory	:%ESC%%U_%%cd%%-%%ESC%
echo   Keywords	: %KeywordsPrint%
if exist "%Template%" ^
echo   Template	:%ESC%%CC_%%templatename%%_%%ESC%
if not exist "%Template%" ^
echo   Template	: %R_%%I_% Not Found! %ESC%%R_%%U_%%Template%%ESC%
echo   %_%---------------------------------------------------------------
goto Options-Input

:Options                          
title %name% %version%  "%CD%"
echo.&echo.&echo.&echo.
set "Already="
set "referer="
if defined timestart call :timer-end
set "timestart="
if /i "%Context%"=="refresh.NR" exit
if defined Context (
	if %exitwait% GTR 99 (
		echo.&echo.
		echo %TAB%%G_%%processingtime% Press Any Key to Close this window.
		endlocal
		pause>nul&exit
	)
	echo. &echo.
	if /i "%input%"=="Scan" (
		echo %TAB%%TAB%%G_%%processingtime% Press any key to close this window.
		endlocal
		pause >nul &exit
	)
	if /i "%cdonly%"=="true" (
		echo %TAB%%G_%%processingtime% This window will close in %ExitWait% sec.
		endlocal
		ping localhost -n %ExitWait% >nul&exit
	)
	if /i "%input%"=="Generate" (
		echo %TAB%%TAB%%G_%%processingtime% Press any key to close this window.
		endlocal
		pause >nul &exit
	)
	echo %TAB%%G_%%processingtime% This window will close in %ExitWait% sec.
	endlocal
	ping localhost -n %ExitWait% >nul&exit
)

:Options-Input                    
rem if not defined OpenFrom echo %_%%GG_%Keywords%G_%^|%GG_%Scan%G_%^|%GG_%Template%G_%^|%GG_%Generate%G_%^|%GG_%Refresh%G_%^|%GG_%RefreshFc%G_%^|%GG_%Search%G_%^|%GG_%ON%G_%^|^
rem %GG_%OFF%G_%^|%GG_%Remove%G_%^|%GG_%Config%G_%^|%GG_%Setup%G_%^|%GG_%RCFI%G_%^|%GG_%O%G_%^|%GG_%S%G_%^|%GG_%Help%G_%^|..
if defined OpenFrom if /i not "%TemplateAlwaysAsk%"=="yes" echo %G_%Template:%ESC%%CC_%%TemplateName%%ESC%
echo %G_%--------------------------------------------------------------------------------------------------
title %name% %version%  "%cd%"
call :Config-Save
call :Config-UpdateVar
call :Config-Load

:Input-Command                    
for %%F in ("%cd%") do set "FolderName=%%~nxF"
if not defined OpenFrom set "FolderName=%cd%"
set "Command=(none)"
set "FolderName=%FolderName:&=^&%"
echo %G_%%FolderName%
set /p "Command=%I_%%GN_% %_%%GN_% "
set "Command=%Command:"=%"
echo %-% &echo %-% &echo %-%
if /i "%Command%"=="keyword"		goto FI-Keyword
if /i "%Command%"=="keywords"	goto FI-Keyword
if /i "%Command%"=="keyword:"	goto Status
if /i "%Command%"=="ky"			goto FI-Keyword
if /i "%Command%"=="key"			goto FI-Keyword
if /i "%Command%"=="scan"		set "recursive=no"	&set "input=Scan"		&goto FI-Scan
if /i "%Command%"=="sc"			set "recursive=no"	&set "input=Scan"		&goto FI-Scan
if /i "%Command%"=="scans"		set "recursive=yes"	&set "input=Scan"		&goto FI-Scan
if /i "%Command%"=="scs"			set "recursive=yes"	&set "input=Scan"		&goto FI-Scan
if /i "%Command%"=="generate"	set "recursive=no"	&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="gen"			set "recursive=no"	&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="generates"	set "recursive=yes"	&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="gens"		set "recursive=yes"	&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="Remove"		set "recursive=no" 	&set "cdonly=false"	&set "delete=ask"		&goto FI-Remove
if /i "%Command%"=="Rem"			set "recursive=no" 	&set "cdonly=false"	&set "delete=ask"		&goto FI-Remove
if /i "%Command%"=="Removes"		set "recursive=yes"	&set "cdonly=false"	&set "delete=ask"		&goto FI-Remove	
if /i "%Command%"=="Rems"		set "recursive=yes"	&set "cdonly=false"	&set "delete=ask"		&goto FI-Remove	
if /i "%Command%"=="Rename"		set "recursive=no"	&set "rename=Ask"		&goto FI-Rename
if /i "%Command%"=="Ren"			set "recursive=no"	&set "rename=Ask"		&goto FI-Rename
if /i "%Command%"=="Renames"		set "recursive=yes"	&set "rename=Ask"		&goto FI-Rename
if /i "%Command%"=="Rens"		set "recursive=yes"	&set "rename=Ask"		&goto FI-Rename
if /i "%Command%"=="Move"			set "recursive=no"	&set "rename=Ask"		&goto FI-Move
if /i "%Command%"=="Mov"			set "recursive=no"	&set "Move=Ask"		&goto FI-Move
if /i "%Command%"=="Moves"		set "recursive=yes"	&set "Move=Ask"		&goto FI-Move
if /i "%Command%"=="Movs"		set "recursive=yes"	&set "Move=Ask"		&goto FI-Move

if /i "%Command%"=="Hide"		set "recursive=no"	&goto FI-Hide
if /i "%Command%"=="Hid"			set "recursive=no"	&goto FI-Hide
if /i "%Command%"=="Hides"		set "recursive=yes"	&goto FI-Hide
if /i "%Command%"=="Hids"		set "recursive=yes"	&goto FI-Hide

if /i "%Command%"=="on"			set "refreshopen=index"	&goto FI-Activate
if /i "%Command%"=="off"			set "refreshopen=index"	&goto FI-Deactivate
if /i "%Command%"=="copy"			goto CopyFolderIcon
if /i "%Command%"=="refresh"		echo %TAB%%CC_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%Command%"=="refreshforce"	echo %TAB%%CC_%Refreshing icon cache..%_%&set "act=Refresh"	&start "" "%~f0" &goto options
if /i "%Command%"=="rf"			echo %TAB%%CC_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%Command%"=="rff"			echo %TAB%%CC_%Refreshing icon cache..%_%&set "act=Refresh"		&start "" "%~f0" &goto options
if /i "%Command%"=="template"	set "refer=Choose.Template"&goto FI-Template
if /i "%Command%"=="template:"	goto Status 
if /i "%Command%"=="tp"			set "refer=Choose.Template"&goto FI-Template
if /i "%Command%"=="Tes"			goto FI-Template-Sample
if /i "%Command%"=="s"			goto Status
if /i "%Command%"=="help"		goto Help
if /i "%Command%"=="cd.."		PUSHD    .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"==".."			PUSHD    .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"=="RCFI"		echo %TAB%%_% Opening..   &echo %TAB%%ESC%%I_%%~dp0%ESC% &echo. &explorer.exe "%~dp0" &goto options
if /i "%Command%"=="open"		echo %TAB%%_% Opening..   &echo %TAB%%ESC%%I_%%~dp0%ESC% &echo. &explorer.exe "%~dp0" &goto options
if /i "%Command%"=="o"			echo %TAB%%_% Opening..   &echo %TAB%%ESC%%I_%%~dp0%ESC% &echo. &explorer.exe "%~dp0" &goto options
if /i "%Command%"=="cls"			cls&goto options
if /i "%Command%"=="r"			start "" "%~f0" &exit
if /i "%Command%"=="tc"			goto Colour
if /i "%Command%"=="search"		set "Context=FI.Search.Folder.Icon.Here"&echo %TAB%Opening search..&start "" "%~f0" &set "Context="&goto options
if /i "%Command%"=="sr"			set "Context=FI.Search.Folder.Icon.Here"&echo %TAB%Opening search..&start "" "%~f0" &set "Context="&goto options
if /i "%Command%"=="setup"		goto Setup-Options
if /i "%Command%"=="Activate"	set "Setup_Select=1" &goto Setup-Choice
if /i "%Command%"=="Deactivate"	set "Setup_Select=2" &goto Setup-Choice
if /i "%Command%"=="uninstall"	set "Setup_Select=2" &goto Setup-Choice
if /i "%Command%"=="Act"			set "Setup_Select=1" &goto Setup-Choice
if /i "%Command%"=="Dct"			set "Setup_Select=2" &goto Setup-Choice
if /i "%Command%"=="Deact"		set "Setup_Select=2" &goto Setup-Choice
if /i "%Command%"=="config"		goto config
if /i "%Command%"=="cfg"			goto config
if /i "%Command%"=="cmd"			cls&cmd.exe
if exist "%Command%" set "input=%command:"=%"&goto directInput
goto Input-Error


:Input-Context                    
title %name% %version% ^| "%cd%"
set Dir=PUSHD    "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls
echo. &echo. &echo.
REM Selected Image
if /i "%Context%"=="IMG-Actions"				goto IMG-Actions
if /i "%Context%"=="IMG-Set.As.Folder.Icon"	PUSHD    "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput
if /i "%Context%"=="IMG-Choose.and.Set.As"		PUSHD    "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput
if /i "%Context%"=="IMG.Choose.Template"		%setIMG%&set "refer=Choose.Template"&goto FI-Template
if /i "%Context%"=="IMG.Edit.Template"			start "" notepad.exe "%template%"&exit
if /i "%Context%"=="IMG.Template.Samples"		%setIMG%&goto FI-Template-Sample-All
if /i "%Context%"=="IMG.Generate.icon"			goto IMG-Generate_icon
if /i "%Context%"=="IMG.Generate.PNG"			goto IMG-Generate_icon
if /i "%Context%"=="IMG-Set.As.Cover"			%setIMG%&goto IMG-Set_as_MKV_cover
if /i "%Context%"=="IMG-Convert"				goto IMG-Convert
if /i "%Context%"=="IMG-Resize"					goto IMG-Resize
if /i "%Context%"=="IMG-Compress"				goto IMG-Compress
REM Selected Dir
if /i "%Context%"=="Change.Folder.Icon"		%Dir% &call :Config-Save	&set "Context="&set "OpenFrom=Context" &cls &echo.&echo.&echo.&goto Intro
if /i "%Context%"=="Select.And.Change.Folder.Icon" goto FI-Selected_folder
if /i "%Context%"=="DIR.Choose.Template"		set "refer=Choose.Template"&goto FI-Template
if /i "%Context%"=="FI.Search.Folder.Icon"		goto FI-Search
if /i "%Context%"=="FI.Search.Poster"			goto FI-Search
if /i "%Context%"=="FI.Search.Logo"				goto FI-Search
if /i "%Context%"=="FI.Search.Icon"				goto FI-Search
if /i "%Context%"=="FI.Search.Folder.Icon.Here" set "Context="&goto FI-Search
if /i "%Context%"=="Scan"						set "input=Scan" 			&set "cdonly=true" &goto FI-Scan
if /i "%Context%"=="DefKey"						goto FI-Keyword
if /i "%Context%"=="Move"							set "cdonly=true"&goto FI-Move
if /i "%Context%"=="Rename"						set "cdonly=true"&goto FI-Rename
if /i "%Context%"=="GenKey"						set "input=Generate"&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenJPG"						set "input=Generate"&set "Keywords=.jpg"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenPNG"						set "input=Generate"&set "Keywords=.png"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenPosterJPG"				set "input=Generate"&set "Keywords=Poster.jpg"	&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenLandscapeJPG"			set "input=Generate"&set "Keywords=Landscape.jpg"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon"		set "cdonly=true"&goto FI-Activate-Ask
if /i "%Context%"=="DeactivateFolderIcon"		set "cdonly=true"&goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon"				set "delete=confirm"&set "cdonly=true"		&goto FI-Remove
REM Background Dir	                         	
if /i "%Context%"=="DIRBG.Choose.Template"		set "refer=Choose.Template"		&goto FI-Template
if /i "%Context%"=="Scan.Here"					%Dir% &set "input=Scan" 			&goto FI-Scan
if /i "%Context%"=="DefKey.Here"				%DIR% &goto FI-Keyword
if /i "%Context%"=="GenKey.Here"				%Dir% &set "input=Generate"		&set "cdonly=false" 		&goto FI-Generate
if /i "%Context%"=="GenJPG.Here"				%Dir% &set "input=Generate"		&set "Keywords=.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPNG.Here"				%Dir% &set "input=Generate"		&set "Keywords=.png"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPosterJPG.Here"			%Dir% &set "input=Generate"		&set "Keywords=Poster.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="Move.Here"					%Dir% &goto FI-Move
if /i "%Context%"=="Rename.Here"					%Dir% &goto FI-Rename
if /i "%Context%"=="GenLandscapeJPG.Here"		%Dir% &set "input=Generate"		&set "Keywords=Landscape.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon.Here"	%Dir% &goto FI-Activate-Ask
if /i "%Context%"=="DeactivateFolderIcon.Here" %Dir% &goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon.Here"		%Dir% &set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%Context%"=="Edit.Config"				start "" notepad.exe "%RCFI%\RCFI.config.ini"&exit
if /i "%Context%"=="Edit.Template"				goto FI-Template-Edit
if /i "%Context%"=="More.Context"				goto FI-More_Tools
REM Other
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error


:Input-Error                      
echo %TAB%%TAB%%R_% Invalid input.  %_%
echo.
if defined Context echo %ESC%%TAB%%TAB%%I_%%R_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%I_%%R_%%Command%%_%
echo.
echo %TAB%%G_%The command, file path, or directory path is unavailable. 
rem echo %TAB%Use %GN_%Help%G_% to see available commands.
goto options

:FI-More_Tools
set "__=   %GG_%"
set "_/_=%G_%/%GG_%"
set "_I_=%G_%^:"
PUSHD    "%SelectedThing%"
set "Context="
echo                             %I_% %name% %version% %_%%-%
echo.
echo %__%Open%_/_%o         %_I_% Open RCFI Tools folder.
echo %__%Keyword%_/_%key    %_I_% Set the keywords to search and select the image inside each folder.
echo %__%Scans%_/_%scs      %_I_% Scan and check which image will be selected to generate the folder icon.
echo %__%Generates%_/_%gens %_I_% Generate folder icons on current directory including all subfolders ^(recursive^).
echo %__%Removes%_/_%rems   %_I_% Remove all folder icons on current directory including all subfolders ^(recursive^).
echo %__%Renames%_/_%rens   %_I_% Rename all icons on current directory including all subfolders ^(recursive^).
echo %__%Moves%_/_%movs     %_I_% Move all icons on current directory including all subfolders ^(recursive^).
echo %__%Hides%_/_%hids     %_I_% Hide/Unhide "desktop.ini" and "icon.ico" for all folders on current directory 
echo                     including all subfolders ^(recursive^).
echo %__%Activate%_/_%act%G_%   %_I_% Activate Folder Icon Tools.
echo %__%Deactivate%_/_%dct%G_% %_I_% Deactivate Folder Icon Tools.
echo.
echo %G_%Template:%ESC%%CC_%%TemplateName%%ESC%   %G_%Keywords:%ESC%%KeywordsPrint%%ESC%
goto Options-Input

:DirectInput                      
set "cdonly=true"
PUSHD "%input%" 2>nul &&goto directInput-folder ||goto directInput-file
POPD&goto options
:DirectInput-Folder               
PUSHD    "%input%"
echo %TAB% Changing directory
echo %TAB%%ESC%%I_%%input%%-%
call :Config-Save
call :Config-UpdateVar
goto options
:DirectInput-File                 
set "RefreshOpen=Select"
set "Selected="
for %%I in ("%input%") do (
		set "filename=%%~nxI"
		set "filepath=%%~dpI"
		set "fileext=%%~xI"
		for %%X in (%ImageSupport%) do if "%%X"=="%%~xI" goto DirectInput-Generate
		)
echo %TAB%%R_%File format not supported.%-%
echo %TAB%%G_%^(supported file: %ImageSupport%^)
goto options

:DirectInput-Generate             
if /i "%TemplateAlwaysAsk%"=="Yes" if /i not "%Already%"=="Asked" (call :FI-Template-AlwaysAsk&echo.)
if /i "%Context%"=="IMG-Choose.and.Set.As" if /i not "%Already%"=="Asked" (call :FI-Template-AlwaysAsk&echo.)
for %%D in ("%cd%") do set "foldername=%%~nD%%~xD" &set "folderpath=%%~dpD"
if /i "%Direct%"=="Confirm" (
	echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	goto DirectInput-Generate-Confirm
)
if not exist desktop.ini (
	echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	goto DirectInput-Generate-Confirm
)
for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do set "%%C=%%D" 2>nul
if not exist "%IconResource:"=%" (
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	goto DirectInput-Generate-Confirm
)
echo %TAB%%Y_%┌%Y_%📁%ESC%%W_%%foldername%%ESC%
echo %TAB%%Y_%└%Y_%🏞%ESC%%Y_%%IconResource:"=%%ESC%
attrib -s -h "%IconResource:"=%"
attrib |EXIT /B
echo %TAB%%G_% This folder already has a folder icon.
echo %TAB%%G_% Do you want to replace it%R_%^? %GN_%Y%_%/%GN_%N%bk_%
echo %TAB%%G_% Press %GG_%Y%G_% to confirm.%_%%bk_%
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="1" (
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
)
IF "%ERRORLEVEL%"=="2" (
	echo %_%%TAB% %I_%     Canceled     %_%
	Attrib %Attrib% "%IconResource:"=%"
	attrib -|EXIT /B
	goto options
)
IF "%ERRORLEVEL%"=="1" if defined Context cls &echo.&set "Direct=Confirm"&echo.&echo.&echo.&echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 

:DirectInput-Generate-Confirm     
if exist "%IconResource:"=%" set "ReplaceThis=%IconResource:"=%"
attrib -s -h "%filepath%%filename%"
attrib |EXIT /B
call :timer-start
call :FI-Generate-Folder_Icon
goto options

:FI-Selected_folder
set "input=_0"
set "cdonly=true"
set "context="
set "target=0.0"
set "replace="
set "Already="
del "%appdata%\RCFI Tools\replaceALL.RCFI" 2>nul
if not defined SFproceed call :FI-Selected_folder-Get
for %%S in (%xSelected%) do (
	PUSHD "%%~fS" 2>nul &&for %%F in (%%S) do (
		set "FolderPath=%%~fF"
		set "FolderName=%%~nxF"
		set "ReplaceThis="
		if exist "%%~fF\desktop.ini" for /f "usebackq tokens=1,2 delims==" %%C in ("%%~fF\desktop.ini") do set "%%C=%%D" 2>nul
		call :FI-Selected_folder-input
	POPD
	)
)

set /a SFproceed+=1
rem echo.&echo.
rem echo %TAB%              %CC_%%I_%          Done!          %_%
echo.&echo.&echo.
goto FI-Selected_folder

:FI-Selected_folder-Get
echo %TAB%%I_%  Change folder icon for selected folders.  %_%
echo %TAB%%_%--------------------------------------------------------------------%_%
set /a FolderCount=0
set "referer=MultiFolderRightClick"
for %%S in (%xSelected%) do (
	set "SelectedThing=%%~fS"
	PUSHD "%%~fS" 2>nul &&(
		set "location=%%~fS" &set "folderpath=%%~dpS" &set "foldername=%%~nxS"
		call :FI-Scan-Desktop.ini
		set /a FolderCount+=1
	)
	POPD
)
if %FolderCount% EQU 1 set "Context=Change.Folder.Icon"&set "xSelected=%SelectedThing%"&goto Input-Context
echo %TAB%%_%--------------------------------------------------------------------%_%
echo %TAB%%G_%Template:%ESC%%CC_%%TemplateName%%ESC%
echo.
EXIT /B

:FI-Selected_folder-Input
set "referer="
if not exist "%input%" (
	echo  %_%• %G_%%PP_%Drag and drop%_%%G_% an %C_%image%G_% into this window, then press Enter to change the folder icon.%_%
	echo  %_%• %G_%%G_%Press %C_%1%G_%, then hit Enter to change them separately in each different window.%_%
	echo %G_%-------------------------------------------------------------------------------
	set /p "Input=%_%%W_%Enter the image path:%_%%C_%"
)
set "Input=%Input:"=%"
if "%input%"=="1" goto FI-Selected_folder-Separate
echo.
if not exist "%Input%" (
	echo.
	echo.
	echo %TAB% %_%Invalid path.
	echo %TAB%%ESC%%R_%%I_%%input%%ESC%
	echo %TAB% %G_%Make sure to enter a valid file path.%_%
	echo.
	echo.
	goto FI-Selected_folder-input
)


set "RefreshOpen=Select"
set "Selected="
for %%I in ("%input%") do (set "filename=%%~nxI"&set "filepath=%%~dpI"&set "fileext=%%~xI")
for %%X in (%ImageSupport%) do (
	if "%%X"=="%fileext%" (
		if /i "%TemplateAlwaysAsk%"=="yes" call :FI-Template-AlwaysAsk
		call :FI-Selected_folder-Act
		echo %G_%-------------------------------------------------------------------------------
		set "iconresource="
		EXIT /B
	)
)
echo.
echo %TAB% %R_%File format not supported.%-%
echo %TAB% %G_%^(supported file: %ImageSupport%^)
echo.
set "input="
call :FI-Selected_folder-input
EXIT /B

:FI-Selected_folder-Act
if not defined iconresource (
	if not defined timestart call :Timer-start
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
	EXIT /B
) else if not exist "%IconResource:"=%" (
	echo %TAB%%W_%┌%Y_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
	EXIT /B
)
if /i "%replace%"=="all" (
	set "ReplaceThis=%IconResource:"=%"
	if not defined timestart call :Timer-start
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
	EXIT /B
)
if not exist "%IconResource:"=%" (
	if not defined timestart call :Timer-start
	call :FI-Generate-Folder_Icon
	EXIT /B
)
echo %TAB%%Y_%┌%Y_%📁%ESC%%W_%%foldername%%ESC%
echo %TAB%%Y_%└%Y_%🏞%ESC%%Y_%%IconResource:"=%%ESC%
attrib -s -h "%IconResource:"=%"
attrib |EXIT /B
echo %TAB%%G_% This folder already has a folder icon.
echo %TAB%%G_% Do you want to replace it%R_%^? %GN_%A%_%/%GN_%Y%_%/%GN_%N%bk_%
echo %TAB%%G_% Press %GG_%Y%G_% to confirm.%_%%G_% Press %GG_%A%G_% to confirm all.%bk_%
CHOICE /N /C AYN
IF "%ERRORLEVEL%"=="1" set "replace=all"
IF "%ERRORLEVEL%"=="3" (
	echo %G_%%TAB% %I_%    Skip    %_%
	Attrib %Attrib% "%IconResource:"=%"
	attrib -|EXIT /B
	set "iconresource="
	EXIT /B
)
set "ReplaceThis=%IconResource:"=%"
if not defined timestart call :Timer-start
echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
call :FI-Generate-Folder_Icon
EXIT /B


:FI-Selected_folder-Separate
set "referer=MultiSelectFolder"
for %%S in (%xSelected%) do (
	PUSHD "%%~fS" 2>nul &&(
		start "" cmd.exe /c set "Context=Change.Folder.Icon"^&call "%~f0" "%%~fS"
	)
	POPD
)
exit


:FI-Scan                          
set "y_result=0"
set "g_result=0"
set "r_result=0"
set "h_result=0"
set "yy_result=0"
set "success_result=0"
set "fail_result=0"
set "Y_d=1"
set "G_d=1"
set "R_d=1"
set "YY_d=1"
set "Y_s="
set "G_s="
set "R_s="
set "YY_s="
set "Y_FolderDisplay="
set "G_FolderDisplay="
set "R_FolderDisplay="
set "YY_FolderDisplay="

echo %TAB%%TAB%%W_%%I_%  Scanning Folders.. %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
Echo %TAB%Keywords  : %KeywordsPrint%
echo %TAB%Directory :%ESC%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :timer-start
call :FI-GetDir
echo %TAB%%W_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
set /a "hy_result=%yy_result%-%h_result%"
echo.
echo.

set "num=%result%" &call :Spaces
set "s=%__%"       &set "num=%R_result%"  &call :Spaces
set "R_s=%__%"     &set "num=%Y_result%"  &call :Spaces
set "Y_s=%__%"     &set "num=%G_result%"  &call :Spaces
set "G_s=%__%"     &set "num=%YY_result%" &call :Spaces
set "YY_s=%__%"    &set "num=%H_result%"  &call :Spaces
set "H_s=%__%"

echo %TAB%%s%%U_%%result% Folders found.%_%
IF /i %YY_result%		GTR 0 IF NOT %hy_result% EQU 0 echo %TAB%%YY_%%YY_s%%HY_result%%_% Folders can be processed.
IF /i %h_result%		GTR 0 echo %TAB%%rr_%%H_s%%H_result%%_% Folders can't be processed.
IF /i %R_result%		GTR 0 echo %TAB%%R_%%R_s%%R_result%%_% Folder's icons are missing and can be changed.
IF /i %Y_result%		GTR 0 echo %TAB%%Y_%%Y_s%%Y_result%%_% Folders already have an icon.
IF /i %G_result%		GTR 0 echo %TAB%%G_%%G_s%%G_result%%_% Folders have no files matching the keywords.
IF /i %YY_result%		LSS 1 echo %TAB%%R_% Couldn't find any files matching the keywords.%_%
echo.
set "result=0" &goto options


:FI-GetDir                        
set "locationCheck=Start"
set "StartDir=%CD%"
REM Current dir only
if /i "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		title %name% %version%  "%%~nxD"
		set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
		PUSHD "%%~fD"
		call :FI-Scan-Desktop.ini
		POPD
	)
	EXIT /B
)
REM All inside current dir including subfolders
if /i "%Recursive%"=="yes" (
	FOR /r %%D in (.) do (
		title %name% %version%  "%%~fD"
		if /i not "%%~fD"=="%CD%" (
			set "location=%%D" &set "folderpath=%%~dpD" &set "foldername=%%~fD"
			PUSHD "%%D"
			call :FI-Scan-Desktop.ini
			POPD
		)
	)
	EXIT /B
)
REM All inside current dir only
FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
	title %name% %version%  "%%~nxD"
	set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
	PUSHD "%%~fD"
	call :FI-Scan-Desktop.ini
	POPD
)
EXIT /B

:FI-GetDir-SubDir
set "SubDirSeparator=%W_%\%_%"
call set "FolderNameCD=%%Location:%CD%\=%%
title %name% %version%  "%FolderNameCD%"
call set "FolderName=%%FolderNameCD:\=%SubDirSeparator%%%"
EXIT /B

:FI-Scan-Display_Result           
if not defined Selected (
	set "Selected=%Filename%" 
	echo   %ESC%%W_%└%C_%🏞 %C_%%Filename%%ESC%
)
EXIT /B

:FI-Scan-Desktop.ini              
if "%locationCheck%"=="%location%" EXIT /B
set "locationCheck=%location%" &set "Selected="
REM          Get New Line
REM  define new line
IF  %Y_result%  NEQ %Y_d%  (set "Y_n=echo."   ) else (set "Y_n="   )
IF  %G_result%  NEQ %G_d%  (set "G_n=echo."   ) else (set "G_n="   )
IF  %R_result%  NEQ %R_d%  (set "R_n=echo."   ) else (set "R_n="   )
IF  %R_result%  EQU %R_d%  (set "R_nx=echo."  ) else (set "R_nx="  )
IF  %R_result%  LSS %R_d%  (set "R_nxx=echo." ) else (set "R_nxx=" )
IF  %YY_result% NEQ %YY_d% (set "YY_n=echo."  ) else (set "YY_n="  )
IF  %YY_result% EQU %YY_d% (set "YY_nx=echo." ) else (set "YY_nx=" )
IF  %YY_result% LSS %YY_d% (set "YY_nxx=echo.") else (set "YY_nxx=")

if /i "%referer%"=="MultiFolderRightClick" (
	set "Y_n="   
	set "G_n="   
	set "R_n="   
	set "R_nx="  
	set "R_nxx=" 
	set "YY_n="  
	set "YY_nx=" 
	set "YY_nxx="
)

REM  display number correction +1
IF  %Y_result% EQU %Y_d%  set /a  "Y_d+=1"
IF  %G_result% EQU %G_d%  set /a  "G_d+=1"
IF  %R_result% EQU %R_d%  set /a  "R_d+=1"
IF %YY_result% EQU %YY_d% set /a "YY_d+=1"

REM             Showing Number
REM  display number indentation so all can be aligned.
REM IF  %Y_d% LSS 10 (set  "Y_s=  %Y_d%")
REM IF  %G_d% LSS 10 (set  "G_s=  %G_d%")
REM IF  %R_d% LSS 10 (set  "R_s=  %R_d%")
REM IF %YY_d% LSS 10 (set "YY_s=  %YY_d%")
REM 
REM IF  %Y_d% GTR 9 (set  "Y_s= %Y_d%")
REM IF  %G_d% GTR 9 (set  "G_s= %G_d%")
REM IF  %R_d% GTR 9 (set  "R_s= %R_d%")
REM IF %YY_d% GTR 9 (set "YY_s= %YY_d%")
REM 
REM IF  %Y_d% GTR 99 (set  "Y_s=%Y_d%")
REM IF  %G_d% GTR 99 (set  "G_s=%G_d%")
REM IF  %R_d% GTR 99 (set  "R_s=%R_d%")
REM IF %YY_d% GTR 99 (set "YY_s=%YY_d%")


REM  Display folder name
set Y_FolderDisplay=echo %TAB%%Y_%%Y_s%📁%ESC%%_%%foldername%%ESC%
set G_FolderDisplay=echo %TAB%%G_%%G_s%📁%ESC%%_%%foldername%%ESC%
set R_FolderDisplay=echo %TAB%%W_%%R_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
set YY_FolderDisplay=echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 

if /i "%recursive%"=="yes" call :FI-Scan-Desktop.ini-Recursive

if /i "%referer%"=="MultiFolderRightClick" (
	set    R_FolderDisplay=echo %TAB%%W_%%R_s%%RR_%📁%ESC%%_%%foldername%%ESC%
	set   YY_FolderDisplay=echo %TAB%%W_%%YY_s%%YY_%📁%ESC%%_%%foldername%%ESC% 
)
	
set "IconResource="
if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
if not defined IconResource (
	for %%F in (%KeywordsFind%) do (
		for %%X in (%ImageSupport%) do (
			if /i "%%X"=="%%~xF" (
				if exist "desktop.ini" (
				REM "Access denied" if i put it up there, idk why?
					attrib -s -h "desktop.ini"
					attrib |EXIT /B
					copy "desktop.ini" "desktop.backup.ini" 2>nul
					Attrib %Attrib% "desktop.ini"
					Attrib %Attrib% "desktop.backup.ini"
					attrib |EXIT /B
				)
				%YY_n%
				%YY_FolderDisplay%
				set /a YY_result+=1
				set "Filename=%%~nxF"
				set "FilePath=%%~dpF"
				set "FileExt=%%~xF"
				if /i "%input%"=="Scan" call :FI-Scan-Display_Result
				if /i "%input%"=="Generate" call :FI-Generate-Folder_Icon
				%YY_nx%
				%YY_nxx%
				EXIT /B
			)
		)
	)
	REM %G_n%
	%G_FolderDisplay%
	set /a G_result+=1
	set "newline=yes"
	EXIT /B
)

if exist "desktop.ini" if not exist "%IconResource:"=%" (
	for %%F in (%KeywordsFind%) do (
		for %%X in (%ImageSupport%) do (
			if /i "%%X"=="%%~xF" (
				%R_n%
				%R_FolderDisplay%
				set /a R_result+=1
				if /i not "%referer%"=="MultiFolderRightClick" (
					echo %TAB%%W_%│%R_%🏞%ESC%%_%%IconResource:"=% %G_%(file not found!)%ESC%
					echo %TAB%%W_%│%G_%This folder previously had a folder icon, but the icon file is missing.%_%
					echo %TAB%%W_%│%G_%The icon will be replaced with the selected image.%_%
				)
				set "newline=no"
				set "Filename=%%~nxF"
				set "FilePath=%%~dpF"
				set "FileExt=%%~xF"
				if /i "%input%"=="Scan" call :FI-Scan-Display_Result
				if /i "%input%"=="Generate" call :FI-Generate-Folder_Icon
				set "iconresource="
				%R_nx%
				%R_nxx%
				EXIT /B
			)
		)
	)
REM %G_n%
%G_FolderDisplay%
set /a G_result+=1
EXIT /B
)

if exist "desktop.ini" if exist "%IconResource:"=%" (
	REM %Y_n%
	%Y_FolderDisplay%
	set /a Y_result+=1
)

set "iconresource="
if /i "%Context%"=="Create" (
	for %%F in (%KeywordsFind%) do (echo.&echo.&echo %R_%%TAB%   Something when wrong^?. :/  &pause>nul)
)
EXIT /B

:FI-Scan-Desktop.ini-Recursive
call set "FolderName=%%Location:%StartDir%\=%%
if /i "%FolderName:~-2%"=="\." set "FolderName=%FolderName:~0,-2%"
call set "Y_FolderName=%%FolderName:\=%W_%\%_%%%"
call set "G_FolderName=%%FolderName:\=%W_%\%_%%%"
call set "R_FolderName=%%FolderName:\=%W_%\%R_%%%"
call set "YY_FolderName=%%FolderName:\=%W_%\%YY_%%%"
set Y_FolderDisplay=echo %TAB%%Y_%%Y_s%📁%ESC%%_%%Y_foldername%%ESC%
set G_FolderDisplay=echo %TAB%%G_%%G_s%📁%ESC%%_%%G_foldername%%ESC%
set R_FolderDisplay=echo %TAB%%W_%%R_s%┌%YY_%📁%ESC%%YY_%%R_foldername%%ESC% 
set YY_FolderDisplay=echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%YY_foldername%%ESC%
EXIT /B

:FI-Generate                      
set "referer="
set "yy_result=0"
set "y_result=0"
set "g_result=0"
set "r_result=0"
set "h_result=0"
set  "Y_d=1"
set  "G_d=1"
set  "R_d=1"
set "YY_d=1"
set "Y_s="
set "G_s="
set "R_s="
set "YY_s="
set "success_result=0"
set "fail_result=0"

echo %TAB%%TAB%%I_%%CC_%  Generating folder icon..  %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
echo %TAB%Keyword   :%ESC%%KeywordsPrint%%ESC%
if exist "%Template%" (
	for %%T in ("%Template%") do (
		echo %TAB%Template  :%ESC%%CC_%%%~nT%ESC%
	)
) else (
	echo %TAB%Template  :%ESC%  %CC_%^?%ESC%
	set "TemplateAlwaysAsk=yes"
)
echo %TAB%Directory :%ESC%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
if /i "%TemplateAlwaysAsk%"=="Yes" call :FI-Template-AlwaysAsk
call :timer-start
call :FI-GetDir
echo %TAB%%W_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
set /a "action_result=%r_result%+%success_result%+%fail_result%"
if /i "%cdonly%"=="true" if %success_result% EQU 1 goto options
if /i "%cdonly%"=="true" if %result% EQU 1 if %y_result% EQU 1 (
	echo.&echo.&echo.
	echo %TAB%%ESC%%Y_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%W_%Folder already has an icon. 
	echo %TAB%Remove it first.%_% 
	echo.&echo.&echo.
)
if /i "%cdonly%"=="true" if %result% EQU 1 if %g_result% EQU 1 (
	echo.&echo.&echo.
	echo %TAB%%ESC%%G_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%W_%Couldn't find any files matching the keywords.
	echo.&echo.&echo.
)
echo.
echo.
title %name% %version% ^| (%YY_result%) Folders processed. ^| "%SelectedThing%"
set "num=%result%"   &call :Spaces
set "s=%__%"         &set "num=%R_result%"         &call :Spaces
set "R_s=%__%"       &set "num=%Y_result%"         &call :Spaces
set "Y_s=%__%"       &set "num=%G_result%"         &call :Spaces
set "G_s=%__%"       &set "num=%YY_result%"        &call :Spaces
set "YY_s=%__%"      &set "num=%H_result%"         &call :Spaces
set "H_s=%__%"       &set "num=%fail_result%"      &call :Spaces
set "fail_s=%__%"    &set "num=%success_result%"   &call :Spaces
set "success_s=%__%"

IF /i %fail_result%		LSS 10 (set "fail_s=   "	) else (IF /i %fail_result%	GTR 9 set "fail_s=  "	&IF /i %fail_result%	GTR 99 set "fail_s= "	&IF /i %fail_result%	GTR 999 set "fail_s="	)
IF /i %success_result%	LSS 10 (set "success_s=   ") else (IF /i %success_result% GTR 9 set "success_s=  " &IF /i %success_result% GTR 99 set "success_s= " &IF /i %success_result% LSS 999 set "success_s="	)

echo %TAB%%s%%U_%%result% Folders found.%_%
IF NOT "%YY_result%"=="%success_result%" IF %YY_result% GTR 0 IF %r_result% GTR 0 echo %TAB%%YY_%%YY_s%%YY_result%%_% Folders processed.
IF /i %R_result%		GTR 0 echo %TAB%%R_%%R_s%%R_result%%_% Folder icons changed.
IF /i %Y_result%		GTR 0 echo %TAB%%Y_%%Y_s%%Y_result%%_% Folders already have an icon.
IF /i %G_result%		GTR 0 echo %TAB%%G_%%G_s%%G_result%%_% Folders have no files matching the keywords.
IF /i %YY_result%		LSS 1 IF /i %success_result%	LSS 1 echo.&echo %TAB% ^(No folders to be processed.^)
IF NOT "%YY_result%"=="%success_result%" IF %action_result% EQU 0 echo %TAB% ^(No files to be processed.^)
IF /i %fail_result%	GTR 0 echo %TAB%%fail_s%%R_%%fail_result%%_% Folder icons failed to generate.
IF /i %success_result%	GTR 1 echo %TAB%%success_s%%CC_%%success_result%%_% Folder icons generated. 
echo %TAB%------------------------------------------------------------------------------
goto options

:FI-Generate-Folder_Icon          
set /a GeneratingCount+=1
title (%GeneratingCount%) "%FolderName%" ^| Generating folder icon ...
if not defined Selected call :FI-Generate-Icon_Name
if not defined Selected (
	if not defined Context (
		set "InputFile=%filepath%%filename%" 
		set "OutputFile=%cd%\%FolderIconName.ico%"
		ATTRIB -s -h -r "%cd%\%FolderIconName.ico%" >nul
		ATTRIB |EXIT /B
	) else (
		set "InputFile=%filepath%%filename%"
		set "OutputFile=%filepath%%FolderIconName.ico%"
		ATTRIB -s -h -r "%filepath%%FolderIconName.ico%" >nul
		ATTRIB |EXIT /B
	)
)

if not defined Selected (
	
	rem Removing READ ONLY attribute, hopfully it will refresh folder icon 
	rem when it re added later "(?)"
	
	attrib -r "%cd%"
	attrib |EXIT /B
	
	rem Display "template" and "selected image"
	set "Selected=%Filename%" 
	echo   %ESC%%W_%└%C_%🏞 %C_%%Filename%%ESC%
	if /i "%cdonly%"=="true" echo %TAB%%ESC%Template    : %CC_%%TemplateName%%ESC%%R_%
	rem Executing "specified template" to convert and edit the selected image
	if /i "%fileExt%"==".ICO" if exist "%TemplateForICO%" (
		for %%T in ("%TemplateForICO%") do echo %TAB%%ESC%%G_%Image extension is %C_%.ico%G_%, TemplateForICO: %CC_%%%~nT%G_%.%ESC%%R_%
		call "%TemplateForICO%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForICO" Fail to generate icon.
		)
	if /i "%fileExt%"==".PNG" if exist "%TemplateForPNG%" (
		for %%T in ("%TemplateForPNG%") do echo %TAB%%ESC%%G_%Image extension is %C_%.png%G_%, TemplateForPNG: %CC_%%%~nT%G_%.%ESC%%R_%
		call "%TemplateForPNG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForPNG" Fail to generate icon.
		)
	if /i "%fileExt%"==".JPG" if exist "%TemplateForJPG%" (
		for %%T in ("%TemplateForJPG%") do echo %TAB%%ESC%%G_%Image extension is %C_%.jpg%G_%, TemplateForJPG: %CC_%%%~nT%G_%.%ESC%%R_%
		call "%TemplateForJPG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForJPG" Fail to generate icon.
		)
	if /i "%fileExt%"==".JPEG" if exist "%TemplateForJPG%" (
		for %%T in ("%TemplateForJPG%") do echo %TAB%%ESC%%G_%Image extension is %C_%.jpg%G_%, TemplateForJPG: %CC_%%%~nT%G_%.%ESC%%R_%
		call "%TemplateForJPG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForJPG" Fail to generate icon.
		)
	
	rem Executing "general template" to convert and edit the selected image
	if not exist "%OutputFile%" call "%Template%"
	
	rem Check icon size, if icon size is less then 200 byte then it's fail.
	if exist "%FolderIconName.ico%" for %%S in ("%FolderIconName.ico%") do (
		if %%~zS GTR 200 echo %TAB%%ESC%%G_%Convert success - %FolderIconName.ico% (%%~zS Bytes)%ESC%%R_%
		if %%~zS LSS 200 (
			echo %R_%"%Filename%"
			echo %R_%Convert error. Icon is less than 200 Bytes. -^> "%FolderIconName.ico%"%ESC%%G_%(%PP_%%%~zS Bytes%G_%)%ESC% 
			echo %R_%Deleting "%FolderIconName.ico%" ..
			del "%FolderIconName.ico%" >nul
			ren "%ReplaceAfter%" "%ReplaceBefore%" >nul
			)
		)
	
	rem Create desktop.ini
	if exist "%FolderIconName.ico%" (
		echo  %G_%%TAB%%G_%Applying resources and attributes..%R_%
		if exist "desktop.ini" attrib -s -h "desktop.ini" &attrib |EXIT /B
		>Desktop.ini	echo ^[.ShellClassInfo^]
		>>Desktop.ini	echo IconResource="%FolderIconName.ico%"
		>>Desktop.ini	echo ^;Folder Icon generated using %name% %version%.
	) else (echo %R_%%I_%Convert failed. %_%&set /a "fail_result+=1")
	
	rem Hiding "desktop.ini", "foldericon.ico" and adding READ ONLY attribute to folder
	if exist "desktop.ini" if exist "%FolderIconName.ico%" (
		ren "Desktop.ini" "desktop.ini.temp"
		ren "desktop.ini.temp" "desktop.ini"
		Attrib %Attrib% "desktop.ini"
		Attrib %Attrib% "%FolderIconName.ico%"
		attrib +r "%cd%"
		attrib |EXIT /B 
		set /a "success_result+=1"
		if exist "%ReplaceThis%" for %%R in ("%ReplaceThis%") do (
			if /i "%%~xR"==".ico" if /i not "%OutputFile%"=="%%~fR" del "%ReplaceThis%" >nul
			set "ReplaceThis="
		)
		if /i "%DeleteOriginalFile%"=="yes" del "%InputFile%"&&echo %TAB%%g_% "%FileName%" deleted.
		echo %TAB% %i_%%g_%  Success!  %-%
	)
)
title %name% %version% ^| (%YY_result%) Folders processed. ^| "%SelectedThing%"
EXIT /B

:FI-Generate-Get_Template         
call :Config-Load
if not exist "%Template%" (
	echo.
	echo %TAB% %W_%Couldn't load template.
	echo %TAB%%ESC%%R_%%Template%%ESC%
	echo %TAB% %I_%%R_%File not found.%-%
	goto options
)
EXIT /B

:FI-Generate-Icon_Name
set "IconNameCount="

if defined ReplaceThis for %%R in ("%ReplaceThis%") do (
	ATTRIB -s -h -r "%%~fR" >nul
	ATTRIB |EXIT /B
	set "ReplaceBefore=%%~nxR"
	set "ReplaceAfter=%%~nR(replace).ico"
	if /i "%%~xR"==".ico" (ren "%%~nxR" "%%~nR(replace).ico" >nul) else set "ReplaceThis="
	if exist "%%~dpnR(replace).ico" set "ReplaceThis=%%~dpnR(replace).ico"
)

if /i "%IconFileName%"=="%IconFileName:#ID=%" (
	set "FolderIconName.ico=%IconFileName%.ico"
	if exist "%FilePath%%IconFileName%.ico" call :FI-Generate-Icon_Name-Conflict
	EXIT /B
)

set "digit=6"
set "string=C2DF5GHJ7KL8QRST9VXZ"
set "string_lenght=20"
set "digit_count="
set "get_ID="

set /a "x1=%random% %% %string_lenght%"
call set "x1=%%string:~%x1%,1%%"

set /a "x2=%random% %% %string_lenght%"
call set "x2=%%string:~%x2%,1%%"

set /a "x3=%random% %% %string_lenght%"
call set "x3=%%string:~%x3%,1%%"

set /a "x4=%random% %% %string_lenght%"
call set "x4=%%string:~%x4%,1%%"

set /a "x5=%random% %% %string_lenght%"
call set "x5=%%string:~%x5%,1%%"

set /a "x6=%random% %% %string_lenght%"
call set "x6=%%string:~%x6%,1%%"

set "FI-ID=%x1%%x2%%x3%%x4%%x5%%x6%"
call set "FolderIconName.ico=%%IconFileName:#ID=%FI-ID%%%.ico"
if exist "%FilePath%%IconFileName%.ico" call :FI-Generate-Icon_Name-Conflict
EXIT /B

:FI-Generate-Icon_Name-Conflict
set /a IconNameCount+=1
if exist "%FilePath%%FolderIconName.ico:~0,-4% -%IconNameCount%.ico" goto FI-Generate-Icon_Name-Conflict
set "FolderIconName.ico=%FolderIconName.ico:~0,-4% -%IconNameCount%.ico"
EXIT /B


:FI-Template-AlwaysAsk             
if /i "%Already%"=="Asked" EXIT /B
if /i not "%Context%"=="Edit.Template" echo.&echo.&echo %TAB%  %W_%Choose Template to Generate Folder Icons:%_%
set "TSelector=GetList"&set "TCount=0"
PUSHD "%RCFI%\templates"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TFullPath=%%~fT"
		call :FI-Template-Get_List
	)
POPD
for %%I in ("%TemplateSampleImage%") do (
		set "TSampleName=%%~nxI"
		set "TSamplePath=%%~dpI"
		set "TSampleFullPath=%%~fI"
		set "TSampleExt=%%~xI"
		set "size_B=%%~zI"
		call :FileSize
	)
if /i "%context%"=="Edit.Template" (
	echo.
	echo %TAB%%TAB%%GN_% A%_%  %W_%Global Template Configuration%_%
)
echo.
echo %G_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
call :FI-Template-Input
set "Already=Asked"
EXIT /B

:FI-Template                      
title %name% %version% ^| Template
if /i not	"%referer%"=="FI-Generate" if defined Context cls &echo.&echo.&echo.&echo.
if /i		"%referer%"=="FI-Generate" echo.&echo %TAB%  %W_%Choose Template to Generate Folder Icons:%_%&echo %TAB% %G_%^(This will not be saved to the configurations^)%_%
if /i not	"%referer%"=="FI-Generate" (
echo %TAB%%TAB%%I_%%CC_%     Template     %-%
echo.
)
rem Show current template and descriptions
if /i not "%referer%"=="FI-Generate" (
	for %%I in ("%Template%") do (
		set "TName=%%~nI"
		echo %TAB%%W_%%U_%Current Template%_%:%ESC%%CC_%%%~nI%ESC%
		for /f "usebackq tokens=1,2 delims=`" %%I in ("%Template%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
		echo %TAB%%_%
		echo.
	)
)
rem Get template list options
if /i not	"%referer%"=="FI-Generate" ( 
	echo.
	echo %TAB%%TAB%%W_%%U_%     Options     %-%
	echo. 
)
set "TSelector=GetList"&set "TCount=0"
PUSHD "%RCFI%\templates"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TFullPath=%%~fT"
		call :FI-Template-Get_List
	)
POPD

rem Get sample image to test the template
if /i "%Context%"=="IMG.Choose.Template" (
	for %%I in ("%img%") do (
		set "TemplateSampleImage=%%~fI"
		set "TSampleName=%%~nxI"
		set "TSamplePath=%%~dpI"
		set "TSampleFullPath=%%~fI"
		set "TSampleExt=%%~xI"
		set "size_B=%%~zI"
		call :FileSize
	)
) else (
	for %%I in ("%TemplateSampleImage%") do (
		set "TSampleName=%%~nxI"
		set "TSamplePath=%%~dpI"
		set "TSampleFullPath=%%~fI"
		set "TSampleExt=%%~xI"
		set "size_B=%%~zI"
		call :FileSize
	)
)

if /i "%Context%"=="IMG.Choose.Template" (
	echo.
	echo %TAB%%TAB%%GN_% S%_% ^> %W_%See all sample icons, using:%ESC%%C_%%TSampleName%%G_% (%PP_%%size%%G_%)%ESC%
) else (
	echo.
	echo %TAB%%TAB%%GN_% S%_% ^> %W_%See all sample icons%_%
)
echo.
echo %G_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
call :FI-Template-Input
goto options


:FI-Template-Input                
rem Input template options
set "TemplateChoice=NotSelected"
set /p "TemplateChoice=%_%%W_%%TAB%%TAB%Select option:%_%%GN_%"

if /i "%TemplateChoice%"=="NotSelected" echo %_%%TAB%   %I_%  CANCELED  %-%&%p2%&goto options
if /i "%TemplateChoice%"=="r" cls&echo.&echo.&echo.&goto FI-Template
if /i "%TemplateChoice%"=="a" set "template=%RCFI.templates.ini%"&EXIT /B
if /i "%TemplateChoice%"=="s" if /i "%refer%"=="Choose.Template" (
		set "act=FI-Template-Sample-All"
		set "FITSA=%TemplateSampleImage%"
		start "" "%~f0"
		cls
		echo.&echo.&echo.
		goto FI-Template
	)
rem 	else (
rem 			echo %TAB%    %_%Generating samples ...
rem 			echo.
rem 			set "Context=IMG.Template.Samples"
rem 			start "" "%~f0"
rem 		)
rem 	if /i "%TemplateChoice%"=="s" goto FI-Template-Input
rem Process valid selected options
set "TSelector=Select"&set "TCount=0"
PUSHD "%RCFI%\templates"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TNameX=%%~nxT"
		set "TFullPath=%%~fT"
		set "TPath=%%~dpT"
		call :FI-Template-Get_List
	)
POPD

if /i not "%TemplateChoice%"=="Selected" (
	if not exist "%Template%" echo    %R_%"%Template%" %I_%Not found.%-%
	echo %_%%TAB%   %I_%%G_%  Invalid selection.  %-% 
	echo %TAB%%G_%   The Options are beetween %GG_%1%G_% to %GG_%%TCount%%G_% only.
	echo.
	goto FI-Template-Input
)
call :Config-UpdateVar
EXIT /B

:FI-Template-Get_List             
if /i "%Tselector%"=="GetList" if "%TemplateName%"=="%TName%" (set TNameList=%ESC%%CC_%%TName%%_%%ESC%) else set TNameList=%ESC%%_%%TName%%_%%ESC%
if /i "%Tselector%"=="GetList" (
	if %TCount% LSS 10 echo %TAB%     %GN_%%TCount%%W_%%TNameList%
	if %TCount%   GTR 9 echo %TAB%    %GN_%%TCount%%W_%%TNameList%
	EXIT /B
	)
set "_info="
if /i "%TSelector%"=="Select" (
		if /i not "%TCount%"=="%TemplateChoice%" EXIT /B
		set "Template=%TFullPath%"
		if "%refer%"=="Choose.Template" (cls &echo.&echo.&echo.&echo.)	
		if /i "%TemplateAlwaysAsk%"=="yes" (
			if /i "%refer%"=="Choose.Template" (
				echo.
				echo   %_%%ESC%%CC_%  %TName%%_% selected.%ESC%
				%p1%
				for /f "usebackq tokens=1,2 delims=`" %%I in ("%TFullPath%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
				%p2%
				set "TemplateChoice=Selected"
				if /i not "%Context%"=="IMG-Choose.and.Set.As" call :Config-Save
			) else (
				echo.
				echo.
				set "TemplateChoice=Selected"
				EXIT /B
			)
		) else (
			rem Display Template info.
			if /i not "%Context%"=="IMG-Choose.and.Set.As" (
			echo.
			echo   %_%%ESC%%CC_%  %TName%%_% selected.%ESC%
			%p1%
			for /f "usebackq tokens=1,2 delims=`" %%I in ("%TFullPath%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
			%p2%
			)
			set "TemplateChoice=Selected"
			if /i not "%Context%"=="IMG-Choose.and.Set.As" call :Config-Save
		)
	)
	if /i "%TemplateTestMode%"=="yes" (
	call :FI-Template-TestMode-TnameX_forfiles_resolver
	set "Ttest="
	set "referer=FI-Template"
	set "InputFile=%TemplateSampleImage%"
	set "OutputFile=%RCFI%\templates\samples\%TName%.ico"
	cls
	goto FI-Template-TestMode
	)
EXIT /B


:FI-Template-Sample               
if /i "%referer%"=="FI-Generate" EXIT /B
call :Config-UpdateVar
if not exist "%RCFI%\templates\samples" md "%RCFI%\templates\samples"
set "InputFile=%TemplateSampleImage%"
set "OutputFile=%RCFI%\templates\samples\%TName%.ico"
if /i "%Context%"=="IMG.Choose.Template" set "InputFile=%img%"
REM if /i "%testmode%"=="yes" set "AlwaysGenerateSample=No"

if exist "%OutputFile%" del "%OutputFile%"

echo.&echo.
echo %I_%%G_%  Generating sample preview.. %-%
echo %G_%Selected Template:%ESC%%CC_%%TName%%ESC%%R_%
for %%I in ("%InputFile%") do set "TSampleName=%%~nxI"&set "TSamplePath=%%~dpI"
echo %G_%Sample image     :%ESC%%C_%%TSampleName%%ESC%%R_%
PUSHD "%TSamplePath%"
Call "%Template%"
POPD
if %ERRORLEVEL% NEQ 0 echo   %R_%%I_%   error ^(%ERRORLEVEL%^)   %-%
if exist "%OutputFile%" for %%C in ("%OutputFile%") do (
	if %%~zC GTR 200 (
		echo %G_%Done! 
		if /i not "%AlwaysGenerateSample%"=="No" explorer.exe "%OutputFile%"
	)
	if %%~zC LSS 200 (
		echo %TAB%    %R_%Convert error:%ESC%%C_%%%~nxS%_% (%PP_%%%~zS Bytes%_%)
		echo %TAB%    %G_%Icon should not less than 200 bytes.
		del "%OutputFile%" >nul
		pause>nul
		goto options
	)
)
EXIT /B

:FI-Template-Sample-All           
call :Timer-start
if not exist "%img%" set "img=%TemplateSampleImage%"
if /i "%Context%"=="IMG.Template.Samples" (
	for %%I in ("%img%") do (
		set "FITSA=%%~fI"
		set "TSampleName=%%~nxI"
		set "TSamplePath=%%~dpI"
		set "TSampleFullPath=%%~fI"
		set "TSampleExt=%%~xI"
		set "size_B=%%~zI"
		call :FileSize
	)
)

echo.&echo %TAB%Sample image selected:
echo   %ESC%- %C_%%TSampleName%%_% (%PP_%%size%%_%)
echo.
echo %TAB%%YY_%Generating all sample images..%_%
echo %TAB%"%RCFI%\templates\samples\"
echo.
if not exist "%RCFI%\templates\samples" md "%RCFI%\templates\samples"
pushd "%RCFI%\templates\samples"
	for %%I in (*.ico) do del "%%~fI"
popd
set /a TCount=0
PUSHD "%RCFI%\templates"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TSampling=%%~fT"
		call :FI-Template-Sample-All-Generate
	)
POPD
echo %TAB%%I_%%YY_%   Done!   %_%
if /i "%Context%"=="IMG.Template.Samples" (
	md "%RCFI%\templates\samples\montage" 2>nul
	for /f "tokens=*" %%I in ('dir /b "%RCFI%\templates\samples\*.ico"') do (
		"%converter%" "%RCFI%\templates\samples\%%~nxI" -define icon:auto-resize="256" "%RCFI%\templates\samples\montage\%%~nI.ico"
	)
	"%montage%" -pointsize 3 -label "%%f" -density 300 -tile 4x0 -geometry +3+2 -border 1 -bordercolor rgba^(210,210,210,0.3^) -background rgba^(255,255,255,0.4^) "%RCFI%\templates\samples\montage\*.ico" "%~dpn1-Folder_Samples.png"
	explorer.exe "%~dpn1-Folder_Samples.png"
	rd /s /q "%RCFI%\templates\samples\montage" 
) else explorer.exe "%RCFI%\templates\samples\"
goto options

:FI-Template-Sample-All-Generate  
set "InputFile=%FITSA%"
set "OutputFile=%RCFI%\templates\samples\%TName%.ico"
if %TCount% LSS 10 echo %TAB%%GN_% %TCount%%_%%ESC%> %CC_%%TName%%ESC%
if %TCount% GTR 9  echo %TAB%%GN_%%TCount%%_%%ESC%> %CC_%%TName%%ESC%%R_%
PUSHD "%TSamplePath%"
 call "%TSampling%"
POPD
if exist "%OutputFile%" (
	for %%S in ("%OutputFile%") do (
		if %%~zS GTR 200 (
		rem	echo %TAB%    %ESC%%_%Convert success 
			echo %TAB%    %ESC%%C_%%%~nxS%G_% (%PP_%%%~zS Bytes%G_%)%_%
		)
		if %%~zS LSS 200 (
		echo %TAB%    %R_%Convert error:%ESC%%C_%%%~nxS%_% (%PP_%%%~zS Bytes%_%)
		echo %TAB%    %G_%Icon should not less than 200 bytes.
		del "%OutputFile%" >nul
		)
	)
) else (echo %TAB%    %R_%%I_% Convert failed. %_%)
echo.
EXIT /B

:FI-Template-TestMode-TnameX_forfiles_resolver
set "TnameXfor=%TnameX:(=^(%"
set "TnameXfor=%TnameXfor:)=^)%"
set "TnameXfor=%TnameXfor:&=^&%"
EXIT /B

:FI-Template-TestMode
set "OutputFile=%RCFI%\templates\samples\%TName%.png"
if /i "%referer%"=="FI-Generate" EXIT /B
echo.&echo.&echo.
if /i not "%TemplateTestMode-AutoExecute%"=="yes" set /a "TestCount+=1"
echo %GN_%%I_% %_%%W_% This is Test Mode%_%
echo   %G_%executed(%_%%TestCount%%G_%)%R_%
echo.
if /i not "%TemplateTestMode-AutoExecute%"=="yes" (
	PUSHD "%TSamplePath%"
		call "%TFullPath%"
		if exist "%OutputFile%" for %%I in ("%OutputFile%") do (if %%~zI LSS 100 del "%OutputFile%")
		if exist "%OutputFile%" (explorer.exe "%OutputFile%") else echo %R_%%I_%Error: Fail to convert.%_%
	POPD
	)
echo.

PUSHD "%TPath%"
	for /f "delims=" %%i in ('"forfiles /m "%TnameXfor%" /c "cmd /c echo @ftime""') do set "Tdate=%%i"
POPD

echo  %_%Template      :%ESC%%CC_%%TnameX% %G_%(Modified: %GG_%%Tdate%%G_%)%ESC%
echo %ESC%%G_%%TFullPath%%ESC%

for %%I in ("%InputFile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%C_%%TSampleName%%G_% (%PP_%%size%%G_%)%ESC%
echo %ESC%%G_%%InputFile%%ESC%

if exist "%OutputFile%" for %%I in ("%OutputFile%") do (
	if %%~zI GTR 100 (
		set "fname=%%~nxI"
		set "size_b=%%~zI"
		call :FileSize
	) else (
		call :FileSize
		del "%OutputFile%" 
		set "fname=%R_%Fail to generate."
	)
) else set "size="
echo  %_%Generated icon:%ESC%%C_%%fname%%G_% (%PP_%%size%%G_%)%ESC%
echo %ESC%%G_%%OutputFile%%ESC%
echo %W_%----------------------------------------------------------------------------------------
if /i "%TemplateTestMode-AutoExecute%"=="yes" cls&set "TestModeAuto=Execute"&set "TdateX=%Tdate%"&goto FI-Template-TestMode-Auto
echo %G_%Press Any Key to re-execute the template. %_%&pause>nul
if exist "%OutputFile%" del "%OutputFile%" >nul
echo.&echo.&echo.
goto FI-Template-TestMode

:FI-Template-TestMode-Auto
echo.&echo.&echo.
if /i "%TestModeAuto%"=="Execute" set /a "TestCount+=1"
echo %GN_%%I_% %_%%W_% This is Test Mode%_%
echo   %G_%executed(%_%%TestCount%%G_%)%R_%
echo.
if /i "%TestModeAuto%"=="Execute" ( 
	PUSHD "%TSamplePath%"
		call "%TFullPath%"
		set "TestModeAuto="
		if exist "%OutputFile%" for %%I in ("%OutputFile%") do (if %%~zI LSS 100 del "%OutputFile%")
		if exist "%OutputFile%" (explorer.exe "%OutputFile%") else echo %R_%%I_%Error: Fail to convert.%_%&set "error=detected"
	POPD
	)
echo.
echo  %_%Template      :%ESC%%CC_%%TnameX% %G_%(Modified: %GG_%%Tdate%%G_%)%ESC%
echo %ESC%%G_%%TFullPath%%ESC%

for %%I in ("%InputFile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%C_%%TSampleName%%G_% (%PP_%%size%%G_%)%ESC%
echo %ESC%%G_%%InputFile%%ESC%

if exist "%OutputFile%" for %%I in ("%OutputFile%") do (
	set "fname=%%~nxI"
	set "size_b=%%~zI"
	call :FileSize
	) else (set size=%R_%Error: file not found!%_%)
echo  %_%Generated icon:%ESC%%C_%%fname%%G_% (%PP_%%size%%G_%)%ESC%
echo %ESC%%G_%%OutputFile%%ESC%
echo %W_%----------------------------------------------------------------------------------------
PUSHD "%TPath%"
	for /f "delims=" %%i in ('"forfiles /m "%TnameXfor%" /c "cmd /c echo @ftime""') do set "Tdate=%%i"
POPD
if /i not "%TemplateTestMode-AutoExecute%"=="yes" goto FI-Template-TestMode
if /i "%error%"=="detected" echo %I_%Error Detected! Auto execution is PAUSED. Press any key to continue.%_%&pause>nul&set "Error="
if "%TdateX%"=="%Tdate%" echo The template will be automatically executed when a file modification is detected.&%p2%&cls&goto FI-Template-TestMode-Auto
set "TdateX=%Tdate%"
set "TestModeAuto=Execute"
if exist "%OutputFile%" del "%OutputFile%" >nul
cls
goto FI-Template-TestMode-Auto

:FI-Template-Edit
echo            %I_%%W_%  Template Configuration  %_%
echo.
echo %TAB%    %W_%Choose Template:%_%
set "TemplateAlwaysAsk=yes"
call :FI-Template-AlwaysAsk
start "" "%TextEditor%" "%Template%"
exit

:FI-Search                        
set "PreAppliedKeywordFolder=folder icon site:deviantart.com OR site:freeiconspng.com OR site:iconarchive.com OR site:icon-icons.com OR site:pngwing.com OR site:iconfinder.com OR site:icons8.com OR site:pinterest.com OR site:pngegg.com&tbm=isch&tbs=ic:trans"
set "PreAppliedKeywordPoster=poster site:themoviedb.org OR site:imdb.com OR site:impawards.com OR site:fanart.tv OR site:myanimelist.net OR site:anidb.net&tbm=isch&tbs=isz:l"
set "PreAppliedKeywordLogo=Logo&tbm=isch&tbs=ic:trans"
set "PreAppliedKeywordIcon=Icon&tbm=isch&tbs=ic:trans"
set "PreAppliedKeyword=%PreAppliedKeywordFolder%"
if /i "%Context%"=="FI.Search.Folder.Icon" (set "SrcInput=%~nx1"&goto FI-Search-Input)
if /i "%Context%"=="FI.Search.Poster" (set "SrcInput=%~nx1"&set "PreAppliedKeyword=%PreAppliedKeywordPoster%"&goto FI-Search-Input)
if /i "%Context%"=="FI.Search.Logo" (set "SrcInput=%~nx1"&set "PreAppliedKeyword=%PreAppliedKeywordLogo%"&goto FI-Search-Input)
if /i "%Context%"=="FI.Search.Icon" (set "SrcInput=%~nx1"&set "PreAppliedKeyword=%PreAppliedKeywordIcon%"&goto FI-Search-Input)
echo.&echo.
echo                     %G_%    Search folder icon  on Google image search, Just type
echo                     %G_% in the keyword then hit [Enter],  you will be redirected 
echo                     %G_% to Google search image results with filters on  so it is 
echo                     %G_% easier to find.
echo.&echo.&echo.&echo.
echo                                       %I_%%W_% SEARCH FOLDER ICON %_%
echo.
set "SrcInput=0"
set /p "SrcInput=%_%%W_%                                      %_%%W_%"
:FI-Search-Input                  
if /i "%SrcInput%"=="0" cls &echo.&echo.&echo.&goto FI-Search
set SrcInput=%SrcInput:"=%
set "SrcInput=%SrcInput:#=%"
if not "%SrcInput%"=="%SrcInput:poster=%" set "SrcInput=%SrcInput:poster=%"&set "PreAppliedKeyword=%PreAppliedKeywordPoster%"
Start "" "https://google.com/search?q=%SrcInput% %PreAppliedKeyword%"
cls
if /i not "%Context%"=="" exit
goto FI-Search

:FI-Keyword                       
echo                  %W_%%I_%     K E Y W O R D S     %_%
echo.
echo.
if /i "%Context%"=="Defkey" call :FI-Keyword-Folder_Selected
call :Config-UpdateVar
rem echo.
rem echo %TAB%%Keywords%
rem echo %TAB%%KeywordsFind%
echo %TAB%%_%• %G_%Spaces and dots, will  be interpreted as  a wildcard.
echo %TAB%%_%• %G_%Use comma to separate multiple keywords, for example:
echo %TAB%%_%%C_%  folder icon.ico,  folder art.png, favorite image.jpg
echo %TAB%%_%• %G_%Certain  characters can  causing an  error,  such as: 
echo %TAB%%_%%G_%  %G_%%C_%%%%G_% %C_%"%G_% %C_%(%G_% %C_%)%G_% %C_%<%G_% %C_%>%G_% %C_%[%G_% %C_%&%G_%%_%
echo.
echo.
echo %TAB%%W_%Current keywords:%_% %KeywordsPrint%
echo.
if defined Keywords1 echo %TAB%  %G_%Keywords list%_%
if defined Keywords1 echo %TAB%  %GN_%1 %G_%^>%ESC%%G_%%Keywords1%%ESC%
if defined Keywords2 echo %TAB%  %GN_%2 %G_%^>%ESC%%G_%%Keywords2%%ESC%
if defined Keywords3 echo %TAB%  %GN_%3 %G_%^>%ESC%%G_%%Keywords3%%ESC%
if defined Keywords4 echo %TAB%  %GN_%4 %G_%^>%ESC%%G_%%Keywords4%%ESC%
if defined Keywords5 echo %TAB%  %GN_%5 %G_%^>%ESC%%G_%%Keywords5%%ESC%
if defined Keywords6 echo %TAB%  %GN_%6 %G_%^>%ESC%%G_%%Keywords6%%ESC%
if defined Keywords7 echo %TAB%  %GN_%7 %G_%^>%ESC%%G_%%Keywords7%%ESC%
if defined Keywords8 echo %TAB%  %GN_%8 %G_%^>%ESC%%G_%%Keywords8%%ESC%
if defined Keywords9 echo %TAB%  %GN_%9 %G_%^>%ESC%%G_%%Keywords9%%ESC%
echo.
if defined Keywords1 echo %TAB%%G_%Type a keywords or choose from the list.&echo.
set "keyHis="
set "newKeywords=."
set /p "newKeywords=%-%%-%%-%%G_%%I_%keywords:%_% %C_%"
set "newKeywords=%newKeywords:"=%"
if /i "%newKeywords%"=="." set "newKeywords=%Keywords%" &set "KeyHis=yes"
if /i "%newKeywords%"=="1" set "newKeywords=%Keywords1%"&set "KeyHis=yes"
if /i "%newKeywords%"=="2" set "newKeywords=%Keywords2%"&set "KeyHis=yes"
if /i "%newKeywords%"=="3" set "newKeywords=%Keywords3%"&set "KeyHis=yes"
if /i "%newKeywords%"=="4" set "newKeywords=%Keywords4%"&set "KeyHis=yes"
if /i "%newKeywords%"=="5" set "newKeywords=%Keywords5%"&set "KeyHis=yes"
if /i "%newKeywords%"=="6" set "newKeywords=%Keywords6%"&set "KeyHis=yes"
if /i "%newKeywords%"=="7" set "newKeywords=%Keywords7%"&set "KeyHis=yes"
if /i "%newKeywords%"=="8" set "newKeywords=%Keywords8%"&set "KeyHis=yes"
if /i "%newKeywords%"=="9" set "newKeywords=%Keywords9%"&set "KeyHis=yes"
set "Keywords=%newKeywords%"
if not defined KeyHis call :FI-Keyword-History
goto FI-Keyword-Selected
echo %TAB%%R_%%I_%  Somthing whent worng :/ ^?.  %-%
echo.
goto options

:FI-Keyword-ImageSupport          
call set "KeywordsFind=%%KeywordsFind:%ImgExtS%=*%ImgExtS%%%"
EXIT /B

:FI-Keyword-Selected              
call :Config-Save
call :Config-UpdateVar
%p1%
echo.&echo.
echo %W_%%TAB%%G_%%I_% Keywords updated! %_%
%p2%
echo.&echo.
echo %TAB%%_%-------%W_%%I_% Current Status %_%----------------------------------------
echo %TAB%Directory	:%ESC%%U_%%cd%%-%%ESC%
echo %TAB%Keywords	: %KeywordsPrint%
if exist "%Template%" ^
echo %TAB%Template	:%ESC%%CC_%%templatename%%_%%ESC%
if not exist "%Template%" ^
echo %TAB%Template	: %R_%%I_% Not Found! %ESC%%R_%%U_%%Template%%ESC%
echo %TAB%%_%---------------------------------------------------------------
echo.&echo.&echo.
echo %TAB%%W_%%I_% %_%%W_% Continue to generate folder icons%R_%?%_%
echo %TAB%%W_%%I_% %_%%G_% Press %GG_%Y%G_% to Confirm / %GG_%N%G_% to Cancel / %GG_%S%G_% to Scan%G_% / %GG_%X%G_% to Close%BK_%
CHOICE /N /C YNSX
IF "%ERRORLEVEL%"=="1" (
	if /i "%Context%"=="Defkey.Here" (
		set "Context=GenKey.Here"
		cls&goto Input-Context
	)
	if /i "%Context%"=="Defkey" (
		set "Context=GenKey"
		cls&goto Input-Context
	)
	set "Command=generate"
	cls&goto Input-Command
)

IF "%ERRORLEVEL%"=="2" (
	if defined Context cls&goto Input-Context
	echo.&echo.&echo.
	goto FI-Keyword
)

IF "%ERRORLEVEL%"=="3" (
	if /i "%Context%"=="Defkey.Here" (
		set "Context=Scan.Here"
		cls&goto Input-Context
	)
	if /i "%Context%"=="Defkey" (
		set "Context=Scan"
		cls&goto Input-Context
	)
	set "Command=scan"
	cls&goto Input-Command
)
if defined Context exit
goto Options

:FI-Keyword-History
if /i "%Keywords1%"=="%newKeywords%" exit /b
if /i "%Keywords2%"=="%newKeywords%" exit /b
if /i "%Keywords3%"=="%newKeywords%" exit /b
if /i "%Keywords4%"=="%newKeywords%" exit /b
if /i "%Keywords5%"=="%newKeywords%" exit /b
if /i "%Keywords6%"=="%newKeywords%" exit /b
if /i "%Keywords7%"=="%newKeywords%" exit /b
if /i "%Keywords8%"=="%newKeywords%" exit /b
if /i "%Keywords9%"=="%newKeywords%" exit /b
if not defined Keywords1 set "Keywords1=%newKeywords%" &exit /b
if not defined Keywords2 set "Keywords2=%newKeywords%" &exit /b
if not defined Keywords3 set "Keywords3=%newKeywords%" &exit /b
if not defined Keywords4 set "Keywords4=%newKeywords%" &exit /b
if not defined Keywords5 set "Keywords5=%newKeywords%" &exit /b
if not defined Keywords6 set "Keywords6=%newKeywords%" &exit /b
if not defined Keywords7 set "Keywords7=%newKeywords%" &exit /b
if not defined Keywords8 set "Keywords8=%newKeywords%" &exit /b
if not defined Keywords9 set "Keywords9=%newKeywords%" &exit /b
set "Keywords1=%Keywords2%"
set "Keywords2=%Keywords3%"
set "Keywords3=%Keywords4%"
set "Keywords4=%Keywords5%"
set "Keywords5=%Keywords6%"
set "Keywords6=%Keywords7%"
set "Keywords7=%Keywords8%"
set "Keywords8=%Keywords9%"
set "Keywords9=%newKeywords%"
exit /b

:FI-Keyword-Folder_Selected
set SelectedFolderCount=0
for %%F in (%xSelected%) do (
	set "SelectedCurrentPath=%%~dpF"
	set /a SelectedFolderCount+=1
)
PUSHD    "%SelectedCurrentPath%"
exit /b

:FI-Activate-Ask
echo.&echo.&echo.&echo.
echo             %_%Press %GN_%A%_%%_% to Activate folder icons  %G_%^|%_%  Press %GN_%D%_% to Deactivate folder icons%G_%
echo.
echo %TAB%You can always activate or deactivate folder icons; it will not delete or remove anything, 
echo %TAB%only turn the folder icons on or off.
CHOICE /C:AD /N
echo.&echo.&echo.&echo.
if /i "%errorlevel%"=="1" cls&echo.&echo.&echo.&goto FI-Activate
if /i "%errorlevel%"=="2" cls&echo.&echo.&echo.&goto FI-Deactivate

:FI-Activate                      
echo %TAB%%CC_%  Activating folder Icons.. %_%
echo %TAB%%CC_%----------------------------------------%_%
call :Timer-start
if "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		attrib +r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%W_%📁%ESC%%%~nxD%ESC%
	)
) else (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		attrib +r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%W_%📁%ESC%%%D%ESC%
	)
)
echo %TAB%%CC_%----------------------------------------%_%
echo.
echo %TAB%%CC_% %I_%   Done!   %-%
goto options
:FI-Deactivate                    
echo %TAB%%CC_%    Deactivating folder Icons.. %_%
echo %TAB%%CC_%----------------------------------------%_%
call :Timer-start
if "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		attrib -r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%G_%📁%ESC%%G_%%%~nxD%ESC%
	)
) else (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		attrib -r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%G_%📁%ESC%%G_%%%D%ESC%
	)
)
echo %TAB%%CC_%----------------------------------------%_%
echo.
echo %TAB%%CC_% %I_%   Done!   %-%
goto options

:FI-Rename
set "result=0"
set "renresult=0"
set "renDeny=0"
IF /I "%RENAME%"=="CONFIRM" goto FI-Rename-Confirm
set "renID="
echo %TAB%%GG_%   %I_%  Rename Icon Files  %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
echo %TAB%%W_%Directory:%ESC%%W_%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :FI-Rename-GetDir
Echo.
echo %TAB%%W_%==============================================================================%_%
IF %result% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%R_%%result%%_%%_%^) Couldn't find folder icon. &goto options
echo.  
IF %renDeny% GTR 0 (
	echo %_%%TAB%  ^(%Y_%%result%%_%%_%^) Folder icon found.%_%  ^(%R_%%renDeny%%_%%_%^) icons can't be rename.%_%
) else (
echo %_%%TAB%  ^(%Y_%%result%%_%%_%^) Folder icon found.%_%
)

if defined Rename1 echo.&echo.&echo.&echo %TAB%%G_%%I_%  Icon name list  %_%
if defined Rename1 echo %TAB%%GN_%1 %G_%^>%ESC%%G_%%Rename1%%ESC%
if defined Rename2 echo %TAB%%GN_%2 %G_%^>%ESC%%G_%%Rename2%%ESC%
if defined Rename3 echo %TAB%%GN_%3 %G_%^>%ESC%%G_%%Rename3%%ESC%
if defined Rename4 echo %TAB%%GN_%4 %G_%^>%ESC%%G_%%Rename4%%ESC%
if defined Rename5 echo %TAB%%GN_%5 %G_%^>%ESC%%G_%%Rename5%%ESC%
if defined Rename6 echo %TAB%%GN_%6 %G_%^>%ESC%%G_%%Rename6%%ESC%
if defined Rename7 echo %TAB%%GN_%7 %G_%^>%ESC%%G_%%Rename7%%ESC%
if defined Rename8 echo %TAB%%GN_%8 %G_%^>%ESC%%G_%%Rename8%%ESC%
if defined Rename9 echo %TAB%%GN_%9 %G_%^>%ESC%%G_%%Rename9%%ESC%
echo.&echo.
if defined Rename1 echo %TAB%%_%• %C_%T%G_%ype a new icon name or insert the %GN_%n%G_%umber to select it from the list.
if not defined Rename1 echo %TAB%%_%• %G_%Type a new icon name.
echo %TAB%%_%• %G_%use "%YY_%#ID%G_%" to  generate 6-digit random string. This may  help to prevent  explorer displaying
echo %TAB%%_%  %G_%the previous icon from the icon cache, unless you do 'Refresh icon cache (restart explorer)'.
echo %TAB%%_%• %G_%Leave it empty to cancel.
echo %TAB%%_%• %G_%Press Enter to continue.
echo.
set "RenHis="
set "NewIconName=(none)"
set /p "NewIconName=%_%%TAB%%_%%I_%New icon name:%_%%C_% "
set "NewIconName=%NewIconName:"=%"
if /i "%NewIconName%"=="(none)" echo.&echo.&echo %_%%TAB%   %G_%       %I_%     Canceled     %_% &goto options
if /i "%NewIconName%"=="1" set "NewIconName=%Rename1%"&set "RenHis=yes"
if /i "%NewIconName%"=="2" set "NewIconName=%Rename2%"&set "RenHis=yes"
if /i "%NewIconName%"=="3" set "NewIconName=%Rename3%"&set "RenHis=yes"
if /i "%NewIconName%"=="4" set "NewIconName=%Rename4%"&set "RenHis=yes"
if /i "%NewIconName%"=="5" set "NewIconName=%Rename5%"&set "RenHis=yes"
if /i "%NewIconName%"=="6" set "NewIconName=%Rename6%"&set "RenHis=yes"
if /i "%NewIconName%"=="7" set "NewIconName=%Rename7%"&set "RenHis=yes"
if /i "%NewIconName%"=="8" set "NewIconName=%Rename8%"&set "RenHis=yes"
if /i "%NewIconName%"=="9" set "NewIconName=%Rename9%"&set "RenHis=yes"
if not defined RenHis call :FI-Rename-History
echo.
echo.
if /i "%NewIconName:~-4%"==".ico" set "NewIconName=%NewIconName:~0,-4%"
if /i not "%NewIconName%"=="%NewIconName:#ID=%" (
	set "renID=yes"
	set "IconFileName.bkp=%IconFileName%"
	set "IconFileName=%NewIconName%"
	call set "NewIconNameDisplay=%%NewIconName:#ID=%YY_%#ID%C_%%%"
) else set "NewIconNameDisplay=%NewIconName%"
echo %TAB% %W_%You are about to rename all icon files to "%C_%%NewIconNameDisplay%.ico%W_%" ?
if defined renID echo %TAB% %YY_%#ID%G_% will be replaced with a 6-digit random string.&echo.
echo %TAB%%G_% Options:%_% %GN_%Y%_%/%GN_%N%_% %G_%^| Press %GG_%Y%G_% to confirm.%_%%bk_%
echo.
CHOICE /N /C YN
echo.
echo.
echo.
IF "%ERRORLEVEL%"=="1" set "RENAME=CONFIRM" &goto FI-Rename
set "IconFileName=%IconFileName.bkp%"
echo %_%%TAB%   %G_%       %I_%     Canceled     %_%
goto options

:FI-Rename-Confirm
call :Config-Save
set "RenSuccess=0"
set "RenFail=0"
if not defined command cls&echo.&echo.&echo.
echo %TAB%%GG_%   %I_%  Renaming Icon Files ...  %-%
echo.
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
echo %TAB%%W_%Directory:%ESC%%W.._%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :Timer-start
call :FI-Rename-GetDir
Echo.
echo %TAB%%W_%==============================================================================%_%
echo %TAB% ^(%GG_%%RenSuccess%%_%^) Icons have been renamed to%ESC%%C_%%NewIconNameDisplay%.ico%_%.%ESC%
set "recursive="
set "IconFileName=%IconFileName.bkp%"
goto options

:FI-Rename-History
if /i "%Rename1%"=="%NewIconName%" exit /b
if /i "%Rename2%"=="%NewIconName%" exit /b
if /i "%Rename3%"=="%NewIconName%" exit /b
if /i "%Rename4%"=="%NewIconName%" exit /b
if /i "%Rename5%"=="%NewIconName%" exit /b
if /i "%Rename6%"=="%NewIconName%" exit /b
if /i "%Rename7%"=="%NewIconName%" exit /b
if /i "%Rename8%"=="%NewIconName%" exit /b
if /i "%Rename9%"=="%NewIconName%" exit /b
if not defined Rename1 set "Rename1=%NewIconName%" &exit /b
if not defined Rename2 set "Rename2=%NewIconName%" &exit /b
if not defined Rename3 set "Rename3=%NewIconName%" &exit /b
if not defined Rename4 set "Rename4=%NewIconName%" &exit /b
if not defined Rename5 set "Rename5=%NewIconName%" &exit /b
if not defined Rename6 set "Rename6=%NewIconName%" &exit /b
if not defined Rename7 set "Rename7=%NewIconName%" &exit /b
if not defined Rename8 set "Rename8=%NewIconName%" &exit /b
if not defined Rename9 set "Rename9=%NewIconName%" &exit /b
set "Rename1=%Rename2%"
set "Rename2=%Rename3%"
set "Rename3=%Rename4%"
set "Rename4=%Rename5%"
set "Rename5=%Rename6%"
set "Rename6=%Rename7%"
set "Rename7=%Rename8%"
set "Rename8=%Rename9%"
set "Rename9=%newRename%"
exit /b

:FI-Rename-GetDir
if /i "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		if /i not "%%~fD"=="%CD%" (
			set "location=%%~fD"
			set "folderpath=%%~dpD"
			set "foldername=%%~nxD"
			title %name% %version%  "%%~nxD"
			PUSHD "%%~fD"
			if /i "%rename%"=="confirm" (call :FI-Rename-Act) else call :FI-Rename-Display
			POPD
		)
	)
	title %name% %version% "%CD%"
	EXIT /B
)


if /i "%Recursive%"=="yes" (
	FOR /r %%D in (.) do (
		if /i not "%%~fD"=="%CD%" (
			set "location=%%~fD"
			set "folderpath=%%~dpD"
			set "foldername=%%~nxD"
			call :FI-GetDir-SubDir
			PUSHD "%%~fD"
			if /i "%rename%"=="confirm" (call :FI-Rename-Act) else call :FI-Rename-Display
			POPD
		)
	)
	title %name% %version% "%CD%"
	EXIT /B
)

FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
	set "location=%%~fD"
	set "folderpath=%%~dpD"
	set "foldername=%%~nxD"
	title %name% %version%  "%%~nxD"
	PUSHD "%%~fD"
	if /i "%rename%"=="confirm" (call :FI-Rename-Act) else call :FI-Rename-Display
	POPD
)
title %name% %version% "%CD%"
EXIT /B

:FI-Rename-Display
set "IconResource="
if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
if not defined IconResource EXIT /B
if not exist "%IconResource:"=%" EXIT /B
echo.
set /a Result+=1
for %%I in ("%IconResource:"=%") do set "IconName=%%~nI"&set "IconPath=%%~dpI"&set "IconExt=%%~xI"
echo %TAB%%Y_%📁%ESC%%FolderName%%ESC%
if /i "%IconExt%"==".ico" echo %TAB%Icon:%ESC%%C_%%IconName%%IconExt%%ESC%&EXIT /B
echo %TAB%Icon:%ESC%%C_%%IconName%%R_%%IconExt%%ESC% %R_%
echo %TAB%%I_% %_%%G_% File extension other than .ico are not allowed to be rename.
set /a RenDeny+=1
EXIT /B

:FI-Rename-Act
set "IconResource="
set "RenDupCount="
set "RenDup="
if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
if not defined IconResource EXIT /B
if not exist "%IconResource:"=%" EXIT /B
echo.
set /a Result+=1
for %%I in ("%IconResource:"=%") do set "IconName=%%~nI"&set "IconPath=%%~dpI"&set "IconExt=%%~xI"
echo %TAB%%Y_%📁%ESC%%FolderName%%ESC%
if defined renID call :FI-Generate-Icon_Name
if defined renID call set "NewIconName=%%IconFileName:#ID=%FI-ID%%%"
if exist "%IconPath%%NewIconName%.ico" call :FI-Rename-Duplicate
echo %TAB%%G_%renaming.. %ESC%%G_%%IconName%%IconExt% %GG_%-->%G_% %NewIconName%%RenDup%.ico  %R_%
if /i "%IconExt%"==".ico" (
	Attrib -s -h -r "%IconPath%%IconName%%IconExt%"
	attrib |EXIT /B
	ren "%IconPath%%IconName%%IconExt%" "%NewIconName%%RenDup%.ico"
	if exist "%IconPath%%NewIconName%%RenDup%.ico" (
		set /a RenSuccess+=1
		attrib -s -h -r "desktop.ini"
		>Desktop.ini	echo ^[.ShellClassInfo^]
		>>Desktop.ini	echo IconResource="%IconPath%%NewIconName%%RenDup%.ico"
		>>Desktop.ini	echo ^;Folder Icon generated using %name% %version%.
		Attrib %Attrib% "%IconPath%%NewIconName%%RenDup%.ico"
		Attrib %Attrib% "Desktop.ini"
		attrib |EXIT /B
		EXIT /B
	) else (
		set /a RenFail+=1
		echo %TAB% %R_%%I_% Rename failed. %_%
		echo %TAB% %G_%Original   :%ESC%%IconPath%%IconName%%IconExt%%ESC%
		echo %TAB% %G_%Destination:%ESC%%IconPath%%NewIconName%%RenDup%.ico%ESC%
		EXIT /B
	)
)
echo %TAB%%_%^(%C_%%IconExt%%_%^) %R_%File extension other than .ico is not allowed to be renamed.%_%
EXIT /B

:FI-Rename-Duplicate
set /a RenDupCount+=1
set "RenDup=-%RenDupCount%"
if not exist "%IconPath%%NewIconName%%RenDup%.ico" (
	echo    %R_%%I_% %ESC%%G_%%NewIconName%.ico already exist, changing name to %NewIconName%%RenDup%.ico%ESC%
	EXIT /B
)
goto FI-Rename-Duplicate

:FI-Move
set "MovF=0"
set "MovFG=0"
set "MovFI=0"
set "MovReady=0"
set "MovDeny=0"
set "MovSuccess=0"
set "MovFail=0"
set "MovAlready=0"
set "MovMiss=0"
set "MovMissFound=0"
set "MovMissDeny=0"
set "MovMissAlready=0"
set "MovMissSuccess=0"
set "MovMissFail=0"

IF /I "%Move%"=="CONFIRM" goto FI-Move-Confirm
echo %TAB%%GG_%   %I_%%BB_%  Move Icon Files  %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
echo %TAB%%W_%Directory:%ESC%%W_%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :FI-Move-GetDir
Echo.
echo %TAB%%W_%==============================================================================%_%


echo.&echo.

set /a MovAllDeny=%MovDeny%+%MovMissDeny%
set /a MovFG=%MovF%-%MovFI%
set num=%MovF%&call :Spaces
set MovF__=%__%
set num=%MovFG%&call :Spaces
set MovFG__=%__%
set num=%MovReady%&call :Spaces
set MovReady__=%__%
set num=%MovDeny%&call :Spaces
set MovDeny__=%__%
set num=%MovMiss%&call :Spaces
set MovMiss__=%__%
set num=%MovMissDeny%&call :Spaces
set MovMissDeny__=%__%
set num=%MovAllDeny%&call :Spaces
set MovAllDeny__=%__%



echo %TAB%%MovF__%%W_%%U_%%MovF% Folders found. %_%
IF %MovFI% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%R_%%MovFI%%_%%_%^) Couldn't find folder icons. &goto options
IF %MovFG% GTR 0 echo %TAB%%MovFG__%%G_%%MovFG%%_% Folders have no icon resource.
IF %MovReady% GTR 0 echo %TAB%%MovReady__%%Y_%%MovReady%%_% Icons can be moved.
IF %MovMiss% GTR 0 echo %TAB%%MovMiss__%%YY_%%MovMiss%%_% Icons are missing from its path, the path will still be changed to the destination.
IF %MovDeny% GTR 0 echo %TAB%%MovAllDeny__%%R_%%MovAllDeny%%_% Icons can't be moved because the icon file extension is not .ico.

echo.&echo.
:FI-Move-InputDir
if defined MoveDst1 echo.&echo.&echo.&echo %TAB%%G_%%I_%  Destination list  %_%
if defined MoveDst1 echo %TAB%%GN_%1 %G_%^>%ESC%%G_%%MoveDst1%%ESC%
if defined MoveDst2 echo %TAB%%GN_%2 %G_%^>%ESC%%G_%%MoveDst2%%ESC%
if defined MoveDst3 echo %TAB%%GN_%3 %G_%^>%ESC%%G_%%MoveDst3%%ESC%
if defined MoveDst4 echo %TAB%%GN_%4 %G_%^>%ESC%%G_%%MoveDst4%%ESC%
if defined MoveDst5 echo %TAB%%GN_%5 %G_%^>%ESC%%G_%%MoveDst5%%ESC%
if defined MoveDst6 echo %TAB%%GN_%6 %G_%^>%ESC%%G_%%MoveDst6%%ESC%
if defined MoveDst7 echo %TAB%%GN_%7 %G_%^>%ESC%%G_%%MoveDst7%%ESC%
if defined MoveDst8 echo %TAB%%GN_%8 %G_%^>%ESC%%G_%%MoveDst8%%ESC%
if defined MoveDst9 echo %TAB%%GN_%9 %G_%^>%ESC%%G_%%MoveDst9%%ESC%
echo.&echo.
echo %TAB%%_%• %G_%%YY_%I%G_%nsert the directory path below where you want to move the icon files to.
if defined MoveDst1 echo %TAB%%_%• %G_%Insert the %GN_%n%G_%umber to select it from the list.
echo %TAB%%_%• %G_%You can also %P_%drag and drop%G_% the folder to this window to insert the directory path.
echo %TAB%%_%• %G_%Insert %YY_%0%G_% to move the icon files to %Y_%each own folder%G_%.
echo %TAB%%_%• %G_%Leave it empty to cancel. 
echo %TAB%%_%• %G_%Press Enter to continue.
echo.
set "MovtoCD="
set "MovHis="
set "MovDestination=(none)"
set /p "MovDestination=%_%%TAB% %_%%I_%Destination:%_%%YY_% "
set "MovDestination=%MovDestination:"=%"
echo.
if /i "%MovDestination%"=="(none)" echo.&echo.&echo %_%%TAB%   %G_%       %I_%     Canceled     %_% &goto options
if /i "%MovDestination%"=="1" set "MovDestination=%MoveDst1%"&set "MovHis=yes"
if /i "%MovDestination%"=="2" set "MovDestination=%MoveDst2%"&set "MovHis=yes"
if /i "%MovDestination%"=="3" set "MovDestination=%MoveDst3%"&set "MovHis=yes"
if /i "%MovDestination%"=="4" set "MovDestination=%MoveDst4%"&set "MovHis=yes"
if /i "%MovDestination%"=="5" set "MovDestination=%MoveDst5%"&set "MovHis=yes"
if /i "%MovDestination%"=="6" set "MovDestination=%MoveDst6%"&set "MovHis=yes"
if /i "%MovDestination%"=="7" set "MovDestination=%MoveDst7%"&set "MovHis=yes"
if /i "%MovDestination%"=="8" set "MovDestination=%MoveDst8%"&set "MovHis=yes"
if /i "%MovDestination%"=="9" set "MovDestination=%MoveDst9%"&set "MovHis=yes"
if /i "%MovDestination%"=="(none)" echo.&echo.&echo %_%%TAB%   %G_%       %I_%     Canceled     %_% &goto options
if /i "%MovDestination%"=="0" (set "MovtoCD=yes"&goto FI-Move-Ask)
if /i "%MovDestination%"=="." (set "MovtoCD=yes"&goto FI-Move-Ask)
if /i "%MovDestination%"=="\" (set "MovtoCD=yes"&goto FI-Move-Ask)
if not exist "%MovDestination%" echo %TAB%        %U_%%R_%Invalid directory path.%_%&echo.&goto FI-Move-InputDir
PUSHD "%MovDestination%" 2>nul||(
	echo %TAB%        %U_%%R_%Invalid directory path.%_%
	echo.
	goto FI-Move-InputDir
)
POPD

:FI-Move-Ask
if not defined MovHis call :FI-Move-History
echo.
echo.
if /i "%MovtoCD%"=="Yes" (
	echo %TAB% %W_%You are about to move all icons to %U_%each own folder%_%.
) else (
	echo %TAB% %W_%You are about to move all icons to:
	for %%M in ("%MovDestination%") do set "MovDestination=%%~fM"&echo %TAB%%ESC%%YY_%%%~fM%ESC%
	echo.
)
echo %TAB%%G_% Options:%_% %GN_%Y%_%/%GN_%N%_% %G_%^| Press %GG_%Y%G_% to confirm.%_%%bk_%
echo.
echo.
echo.
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="1" set "Move=CONFIRM" &goto FI-Move
IF "%ERRORLEVEL%"=="2" echo %_%%TAB%   %G_%       %I_%     Canceled     %_% &goto options
goto options

:FI-Move-History
if /i "%MovDestination%"=="0" exit /b
if /i "%MoveDst1%"=="%MovDestination%" exit /b
if /i "%MoveDst2%"=="%MovDestination%" exit /b
if /i "%MoveDst3%"=="%MovDestination%" exit /b
if /i "%MoveDst4%"=="%MovDestination%" exit /b
if /i "%MoveDst5%"=="%MovDestination%" exit /b
if /i "%MoveDst6%"=="%MovDestination%" exit /b
if /i "%MoveDst7%"=="%MovDestination%" exit /b
if /i "%MoveDst8%"=="%MovDestination%" exit /b
if /i "%MoveDst9%"=="%MovDestination%" exit /b
if not defined MoveDst1 set "MoveDst1=%MovDestination%" &exit /b
if not defined MoveDst2 set "MoveDst2=%MovDestination%" &exit /b
if not defined MoveDst3 set "MoveDst3=%MovDestination%" &exit /b
if not defined MoveDst4 set "MoveDst4=%MovDestination%" &exit /b
if not defined MoveDst5 set "MoveDst5=%MovDestination%" &exit /b
if not defined MoveDst6 set "MoveDst6=%MovDestination%" &exit /b
if not defined MoveDst7 set "MoveDst7=%MovDestination%" &exit /b
if not defined MoveDst8 set "MoveDst8=%MovDestination%" &exit /b
if not defined MoveDst9 set "MoveDst9=%MovDestination%" &exit /b
set "MoveDst1=%MoveDst2%"
set "MoveDst2=%MoveDst3%"
set "MoveDst3=%MoveDst4%"
set "MoveDst4=%MoveDst5%"
set "MoveDst5=%MoveDst6%"
set "MoveDst6=%MoveDst7%"
set "MoveDst7=%MoveDst8%"
set "MoveDst8=%MoveDst9%"
set "MoveDst9=%MovDestination%"
exit /b

:FI-Move-Confirm
call :Config-Save
if not defined command cls&echo.&echo.&echo.
echo %TAB%%BB_%   %I_%%BB_%  Moving Icon Files..  %-%
echo.
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
if /i "%MovDestination%"=="0" (set DstDisplay=Each own folder.) else set "DstDisplay=%MovDestination%"
echo %TAB%%W_%Directory	:%ESC%%W_%%cd%%ESC%
echo %TAB%%W_%Destination	:%ESC%%YY_%%DstDisplay%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :Timer-start
call :FI-Move-GetDir
Echo.
echo %TAB%%W_%==============================================================================%_%
echo %TAB%%W_%Destination	:%ESC%%YY_%%DstDisplay%%ESC%
echo.&echo.

set /a MovAllDeny=%MovDeny%+%MovMissDeny%
set /a MovFG=%MovF%-%MovFI%

set num=%MovF%&call :Spaces
set MovF__=%__%
set num=%MovFG%&call :Spaces
set MovFG__=%__%
set num=%MovAlready%&call :Spaces
set MovAlready__=%__%
set num=%MovMissFound%&call :Spaces
set MovMissFound__=%__%
set num=%MovSuccess%&call :Spaces
set MovSuccess__=%__%
set num=%MovFail%&call :Spaces
set MovFail__=%__%
set num=%MovDeny%&call :Spaces
set MovDeny__=%__%
set num=%MovMissSuccess%&call :Spaces
set MovMissSuccess__=%__%
set num=%MovMissFail%&call :Spaces
set MovMissFail__=%__%
set num=%MovMissDeny%&call :Spaces
set MovMissDeny__=%__%
set num=%MovAllDeny%&call :Spaces
set MovAllDeny__=%__%

echo %TAB%%MovF__%%W_%%U_%%MovF% Folders found. %_%
IF %MovFI% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%Y_%%MovFI%%_%%_%^) Couldn't find any folder icons. &goto options
IF %MovFG% GTR 0 echo %TAB%%MovFG__%%G_%%MovFG%%_% Folders have no icon resource.
IF %MovAlready% GTR 0 echo %TAB%%MovAlready__%%G_%%MovAlready%%_% Icons is already in the destination.
IF %MovSuccess% GTR 0 echo %TAB%%MovSuccess__%%Y_%%MovSuccess%%_% Icons has been moved.
IF %MovMissFound% GTR 0 echo %TAB%%MovMissFound__%%GG_%%MovMissFound%%_% Icons were missing and have been found in the destination.
IF %MovMissSuccess% GTR 0 echo %TAB%%MovMissSuccess__%%RR_%%MovMissSuccess%%_% Icons were missing, but the icon path has been moved to the destination.
IF %MovFail% GTR 0 echo %TAB%%MovFail__%%R_%%MovFail%%_% Icons failed to moved.
IF %MovDeny% GTR 0 echo %TAB%%MovAllDeny__%%R_%%MovAllDeny%%_% Icons can't be moved because the icon file extension is not .ico.

set "recursive="
set "MovDestination="
goto options

:FI-Move-GetDir
if /i "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		if /i not "%%~fD"=="%CD%" (
			set /a MovF+=1
			set "location=%%~fD"
			set "folderpath=%%~dpD"
			set "foldername=%%~nxD"
			set "foldernameORI=%%~nxD"
			title %name% %version%  "%%~nxD"
			PUSHD "%%~fD"
			if /i "%Move%"=="confirm" (call :FI-Move-Act) else call :FI-Move-Display
			POPD
		)
	)
	title %name% %version% "%CD%"
	EXIT /B
)

if /i "%Recursive%"=="yes" (
	FOR /r %%D in (.) do (
		if /i not "%%~fD"=="%CD%" (
			set /a MovF+=1
			set "location=%%~fD"
			set "folderpath=%%~dpD"
			set "foldername=%%~nxD"
			set "foldernameORI=%%~nxD"
			call :FI-GetDir-SubDir
			PUSHD "%%~fD"
			if /i "%Move%"=="confirm" (call :FI-Move-Act) else call :FI-Move-Display
			POPD
		)
	)
	title %name% %version% "%CD%"
	EXIT /B
)

FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
	set /a MovF+=1
	set "location=%%~fD"
	set "folderpath=%%~dpD"
	set "foldername=%%~nxD"
	set "foldernameORI=%%~nxD"
	title %name% %version%  "%%~nxD"
	PUSHD "%%~fD"
	if /i "%Move%"=="confirm" (call :FI-Move-Act) else call :FI-Move-Display
	POPD
)
title %name% %version% "%CD%"
EXIT /B

:FI-Move-Display
set "IconResource="

if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
if not defined IconResource EXIT /B

set /a MovFI+=1
if not exist "%IconResource:"=%" (
	echo %TAB% %W_%┌%R_%📁%ESC%%FolderName%%ESC%
	echo temporary file >"%IconResource:"=%"
	for %%T in ("%IconResource:"=%") do (
	
		if /i "%%~xT"==".ico" (
			echo %TAB%%ESC%%W_%└%R_%%%~nxT%ESC%
			if /i not "%%~dpT"=="%Location%\" echo %TAB%%ESC%%G_% %%~dpT%ESC%
			echo %TAB%  %G_%Icon file is missing, but the icon's directory path will still be moved.
			set /a MovMiss+=1
		) else (
			echo %TAB%%ESC%%W_%└%_%%%~nT%R_%%%~xT%ESC%
			if /i not "%%~dpT"=="%Location%\" echo %TAB%%ESC%%G_% %%~dpT%ESC%
			echo %TAB%%I_%%R_% %_%%G_%  File extension other than .ico are not allowed to be moved.
			set /a MovMissDeny+=1
		)
	
	)
	del /q "%IconResource:"=%"
	EXIT /B
)
echo.

echo %TAB% %W_%┌%Y_%📁%ESC%%FolderName%%ESC%

for %%I in ("%IconResource:"=%") do set "IconName=%%~nI"&set "IconPath=%%~dpI"&set "IconExt=%%~xI"

if /i "%IconExt%"==".ico" (
	echo %TAB%%ESC%%W_%└%Y_%%IconName%%IconExt%%ESC%
	if /i not "%IconPath%"=="%Location%\" echo %TAB%%ESC%%G_% %IconPath%%ESC%
	set /a MovReady+=1
) else (
	echo %TAB%%ESC%%W_%└%Y_%%IconName%%R_%%IconExt%%ESC%
	echo %TAB%%I_%%R_% %_%%G_%  File extension other than .ico are not allowed to be moved.
	if /i not "%IconPath%"=="%Location%\" echo %TAB%%ESC%%G_% %IconPath%%ESC%
	set /a MovDeny+=1
)
EXIT /B

:FI-Move-Act
set "IconResource="
set "MovDupCount="
set "MovDup="
set "MovedFI="
if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
if not defined IconResource EXIT /B
set /a MovFI+=1
if /i "%MovtoCD%"=="Yes" call :FI-Generate-Icon_Name
if /i "%MovtoCD%"=="Yes" (
	set "MovDestination=%Location%"
	set "MovedFI=%FolderIconName.ico%"
	set "MovIconName=%FolderIconName.ico:~,-4%"
) else set "MovIconName=%FoldernameORI%"

if not exist "%IconResource:"=%" (
	if not defined MovedFI set "MovedFI=%MovDestination%\%MovIconName%.ico"
	echo %TAB% %W_%┌%Y_%📁%ESC%%FolderName%%ESC%
	echo temporary file >"%IconResource:"=%"
	for %%T in ("%IconResource:"=%") do (
		if "%%~dpT"=="%MovDestination%\" (
			set /a MovAlready+=1
			echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
			echo %TAB%%ESC%%W_% %G_%The icon file is missing, but the path is already in the destination.%ESC%
			del /q "%IconResource:"=%" >nul
			EXIT /B
		)
		if /i "%%~xT"==".ico" (
			if /i "%%~dpT"=="%Location%\" (
				if exist "%MovDestination%\%MovIconName%.ico" (
					echo %TAB%%ESC%%W_%│%G_%%%~nxT%ESC%
					echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
					call :FI-Move-Act-Desktop.ini
					set /a MovMissFound+=1
				) else (
					echo %TAB%%ESC%%W_%│%G_%%%~nxT%ESC%
					echo %TAB%%ESC%%W_%└%R_%%MovIconName%.ico%ESC%
					call :FI-Move-Act-Desktop.ini
					set /a MovMissSuccess+=1
				)
			) else (
				if exist "%MovDestination%\%MovIconName%.ico" (
					echo %TAB%%ESC%%W_%│%G_%%%~fT%ESC%
					echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
					call :FI-Move-Act-Desktop.ini
					set /a MovMissFound+=1
				) else (
					echo %TAB%%ESC%%W_%│%G_%%%~fT%ESC%
					echo %TAB%%ESC%%W_%└%R_%%MovIconName%.ico%ESC%
					call :FI-Move-Act-Desktop.ini
					set /a MovMissSuccess+=1
				)
			)
		) else (
			set /a MovMissDeny+=1
			if /i "%%~dpT"=="%Location%\" (
				echo %TAB%%ESC%%W_%└%G_%%%~nT%R_%%%~xT%ESC%
				echo %TAB%%I_%%R_% %_%%G_% File extension other than .ico are not allowed to be moved.
			) else (
				echo %TAB%%ESC%%W_%└%G_%%%~dpT%ESC%
				echo %TAB%%ESC%%G_% %%~nT%R_%%%~xT%ESC%
				echo %TAB%%I_%%R_%  %_%%G_% File extension other than .ico are not allowed to be moved.
			)
		)
	)
	del /q "%IconResource:"=%" >nul
	echo.
	EXIT /B
)

for %%I in ("%IconResource:"=%") do set "IconName=%%~nI"&set "IconPath=%%~dpI"&set "IconExt=%%~xI"

if /i "%IconPath%"=="%MovDestination%\" (
	echo.
	echo %TAB%%ESC%%W_%┌%Y_%📁 %_%%FolderName%%ESC%
	echo %TAB%%ESC%%W_%│ %GG_%%G_%The icon is already in the destination.%ESC%
	echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
	set /a MovAlready+=1
	EXIT /B
)

echo.
echo %TAB% %W_%┌%Y_%📁%ESC%%FolderName%%ESC%
if not defined MovedFI set "MovedFI=%MovDestination%\%MovIconName%.ico"
if exist "%MovedFI%" call :FI-Move-Duplicate
Attrib -s -h -r "%IconPath%%IconName%%IconExt%"
Attrib |EXIT /B
if /i "%IconExt%"==".ico" (
	if /i "%IconPath%"=="%Location%\" (
		echo %TAB%%ESC%%W_%│%G_%%IconName%%IconExt%%ESC%
		echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
		Move "%IconResource:"=%" "%MovedFI%" >nul
		if exist "%MovedFI%" (
			call :FI-Move-Act-Desktop.ini
			set /a MovSuccess+=1
		) else (
			echo   %R_%%I_% Fail! %_%
			set /a MovFail+=1
		)
	) else (
		echo %TAB%%ESC%%W_%│%G_%%IconPath%%IconName%%IconExt%%ESC%
		echo %TAB%%ESC%%W_%└%Y_%%MovIconName%.ico%ESC%%R_%
		Move "%IconResource:"=%" "%MovedFI%" >nul
		if exist "%MovedFI%" (
			call :FI-Move-Act-Desktop.ini
			set /a MovSuccess+=1
			
		) else (
			echo   %R_%%I_% Fail! %_%
			set /a MovFail+=1
		)
	)
) else echo %TAB%%_%^(%C_%%IconExt%%_%^) %R_%File extension other than .ico is not allowed to be renamed.%_%
EXIT /B

:FI-Move-Act-Desktop.ini
attrib -s -h -r "desktop.ini"
>Desktop.ini	echo ^[.ShellClassInfo^]
>>Desktop.ini	echo IconResource="%MovedFI%"
>>Desktop.ini	echo ^;Folder Icon generated using %name% %version%.
Attrib %Attrib% "Desktop.ini"
if defined MovtoCD Attrib %Attrib% "%MovedFI%"
attrib |EXIT /B
EXIT /B

:FI-Move-Duplicate
set /a MovDupCount+=1
set "MovDup=-%RenDupCount%"
set "MovedFI=%MovDestination%\%MovIconName%%MovDup%.ico"
if not exist "%MovedFI%" (
	echo   %ESC%%G_% │ %R_%%I_% %_%%G_%%MovIconName%.ico already exist, changing name to %MovIconName%%MovDup%.ico%ESC%
	EXIT /B
)
goto FI-Rename-Duplicate



:FI-Remove                        
@echo off
set "result=0"
set "delresult=0"
IF /I "%DELETE%"=="CONFIRM" goto FI-Remove-Confirm
echo %TAB%%R_%   %I_%  Remove Folder Icon  %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
echo %TAB%%W_%Directory:%ESC%%W_%%cd%%ESC%
echo %TAB%%W_%==============================================================================%_%
call :FI-Remove-Get
echo %TAB%%W_%==============================================================================%_%
IF /i %result% LSS 1 if defined Context cls
IF /i %result% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%R_%%result%%_%%_%^) Couldn't find folder icon. &goto options
echo. &echo %_%%TAB%  ^(%Y_%%result%%_%%_%^) Folder icon found.%_% &echo.&echo.
echo       %_%%R_%Continue to Remove (%Y_%%result%%_%%R_%^) folder icons^?%-% 
echo %TAB%%ast%%G_%The folder icon will be deactivated from the folder, "desktop.ini"
echo %TAB% and "foldericon.ico"   inside   the  folder   will   be  deleted.
echo %TAB%%G_% Options:%_% %GN_%Y%_%/%GN_%N%_% %G_%^| Press %GG_%Y%G_% to confirm.%_%%bk_%
echo.
echo.
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="1" set "DELETE=CONFIRM" &goto FI-Remove
IF "%ERRORLEVEL%"=="2" echo %_%%TAB%  %I_%     Canceled     %_% &goto options

:FI-Remove-Confirm                
if defined Context cls
echo.&echo.&echo.&echo.
echo %TAB%%R_%   %I_%  Removing Folder Icon..  %-%
echo.
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
if /i not "%cdonly%"=="true" echo %TAB%%W_%Directory:%ESC%%W_%%cd%%ESC%
if /i not "%cdonly%"=="true" echo %TAB%%W_%==============================================================================%_%
if /i not "%cdonly%"=="true" echo.

call :FI-Remove-Get

if /i not "%cdonly%"=="true" echo %TAB%%W_%==============================================================================%_%
IF /i %result% LSS 1 if defined Context cls
IF /i %result% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%R_%%result%%_%%_%^) Couldn't find any folder icon. &goto options
if %delresult% GTR 0 echo. &echo %TAB% ^(%R_%%delresult%%_%^) Folder icon deleted.
set "recursive="
goto options

:FI-Remove-Get                    
if /i "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
	set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
		PUSHD "%%~fD"
			if exist "desktop.ini" (
				FOR /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do (
					set "%%C=%%D"
					if /i "%%C"=="iconresource" call :FI-Remove-Act
				)
			)
		POPD
	)
	EXIT /B
)

IF /i "%recursive%"=="yes" (
	FOR /r %%D in (.) do (
		if /i not "%%~fD"=="%CD%" (
		set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
		call :FI-GetDir-SubDir
			PUSHD "%%~fD"
				if exist "desktop.ini" (
					FOR /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do (
						set "%%C=%%D"
						if /i "%%C"=="iconresource" call :FI-Remove-Act
					)
				)
			POPD
		)
	)
) ELSE (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
		PUSHD "%%~fD"
			title %name% %version%  "%%~nxD"
			if exist "desktop.ini" (
				FOR /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do (
					set "%%C=%%D"
					if /i "%%C"=="iconresource" call :FI-Remove-Act
				)
			)
		POPD
	)
)
title %name% %version%  "%CD%"
EXIT /B

:FI-Remove-Act                    
if /i not "%delete%"=="confirm" (
	if exist "%IconResource:"=%" (
		set /a result+=1
		for %%R in ("%IconResource:"=%") do (
			if /i "%%~xR"==".ico" (
				echo %TAB%%Y_%📁%ESC%%_%%foldername%%ESC% 
				EXIT /B
			) else (
				echo %TAB%%Y_%📁%ESC%%_%%foldername%%ESC%
				echo %TAB%%G_%icon:%ESC%%%~nR%R_%%%~xR%ESC%
				echo %TAB%%G_%icon file other than .ico will not be deleted.
			)
		)
	)
	EXIT /B
)
if exist "%IconResource:"=%" (
	set /a result+=1
	if not defined timestart call :timer-start
	for %%R in ("%IconResource:"=%") do (
		echo %TAB%%W_%📁%ESC%%_%%foldername%%ESC%
		if "%%~xR"==".ico" (
			echo %TAB%%G_%Icon:%ESC%%C_%%%~nxR%ESC%
			attrib -s -h "%IconResource:"=%" 
			attrib |EXIT /B
			echo %TAB%%G_%Deleting%ESC%%G_%%IconResource:"=%%ESC%%R_%
			del /f /q "%IconResource:"=%"			
		) else (
			echo %TAB%%G_%icon:%ESC%%C_%%%~nR%GG_%%%~xR%ESC%
			echo %TAB%%G_%icon file other than .ico will not be deleted.%ESC%
		)
	)
	echo %TAB%%G_%Deleting desktop.ini%R_%
	attrib -h -s "Desktop.ini"
	attrib |EXIT /B		
	del /f /q "Desktop.ini"
	if not exist "desktop.ini" echo %TAB%%G_%%I_%  Done!  %-% 
	set /a delresult+=1 
	echo.
)
EXIT /B

:FI-Hide
set "Folders=0"
set "HideCount=0"
set "NotFI=0"
set "HideAct="
set "HideAttrib="
echo.&echo.&echo.&echo.
echo %_%                       Hide or Unhide the "desktop.ini" and "*.ico" files.
echo %TAB%%G_%You can always hide or unhide the files; it will not move, remove or delete anything, 
echo %TAB%%G_%nothing scary will happen. just making the files related to the folder icon hidden or not.
echo.
echo             %_%Press %GN_%H%_%%_% to Hide  %G_%^|%_%  Press %GN_%U%_% to Unhide%G_%
echo.
CHOICE /C:HU /N
echo.&echo.&echo.
if /i "%errorlevel%"=="2" set "HideAct=Unhide"&set "HideAttrib=-h -s"&goto FI-Hide-GetDir

echo %TAB%%_%Would you you want to hide it as system file?
echo %TAB%%G_%adding "system file" attribute to the file will make it extra hidden.
echo %TAB%%G_%Options: %GN_%Y%G_%/%GN_%N%G_%   ^| Press %GN_%Y%G_% to make it extra hidden.
CHOICE /C:YN /N
echo.&echo.&echo.
if /i "%errorlevel%"=="1" set "HideAct=Hide"&set "HideAttrib=+h +s"&goto FI-Hide-GetDir
if /i "%errorlevel%"=="2" set "HideAct=Hide"&set "HideAttrib=+h -s"&goto FI-Hide-GetDir
goto options

:FI-Hide-GetDir
echo %TAB%%GG_%          %I_%%W_%    Hide Icon Files    %-%
echo.
if /i "%recursive%"=="yes" echo %TAB%%U_%%W_%RECURSIVE MODE%_%
set "HideActDisplay=%HideAttrib:-h -s=Unhide%
set "HideActDisplay=%HideAttrib:+h +s=Hide as sytem files%
set "HideActDisplay=%HideAttrib:+h -s=Hide%
echo %TAB%%W_%Action:%ESC%%CC_%%HideActDisplay%%ESC%
call :Timer-start
echo %TAB%%W_%==============================================================================%_%
if /i "%Recursive%"=="yes" (
	FOR /r %%D in (.) do (
		if /i not "%%~fD"=="%CD%" (
			set "IconResource="
			set "location=%%~fD"
			set "folderpath=%%~dpD"
			set "foldername=%%~nxD"
			call :FI-GetDir-SubDir
			PUSHD "%%~fD"
			set /a Folders+=1
			call :FI-Hide-Act
			POPD
		)
	)
) else (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		set "IconResource="
		set "location=%%~fD"
		set "folderpath=%%~dpD"
		set "foldername=%%~nxD"
		title %name% %version%  "%%~nxD"
		PUSHD "%%~fD"
		set /a Folders+=1
		if exist "desktop.ini" (
			for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"
			call :FI-Hide-Act
		) else (
			set /a NotFI+=1
			echo %TAB%%G_%📁%ESC%%%~nxD%ESC%
		)
		POPD
	)
)
echo %TAB%%W_%==============================================================================%_%
echo.

set "num=%Folders%"&call :Spaces
set "F__=%__%"

set "num=%HideCount%"&call :Spaces
set "H__=%__%"

set "num=%NotFI%"&call :Spaces
set "N__=%__%"


echo %TAB%%F__%%U_%%Folders% Folders found.%_%
echo %TAB%%H__%%_%%Y_%%HideCount%%_% Folders applied.
echo %TAB%%N__%%_%%G_%%NotFI%%_% Folders have no icon resources. 
Goto Options


:FI-Hide-Act
if /i "%Recursive%"=="yes" if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do if not "%%D"=="" set "%%C=%%D"

if not defined IconResource (
	echo %TAB%%G_%📁%ESC%%FolderName%%ESC%
	set /a NotFI+=1
	exit /b
)

if not exist "%IconResource:"=%" (
	echo %TAB%%G_%📁%ESC%%FolderName%%ESC%
	set /a NotFI+=1
	exit /b
)

echo %TAB%%Y_%📁%ESC%%FolderName%%ESC%%R_%
attrib %HideAttrib% "desktop.ini"
attrib %HideAttrib% "%IconResource:"=%"
ATTRIB |EXIT /B
set /a HideCount+=1
exit /b

:Spaces
if not defined num echo %R_%error: num is not defined.&exit /b
set "__="
set /a "TestNum=%num%+2" 2>nul||(echo %R_%Spaces counter fail!%_%&exit /b)
if /i %num% LEQ 9     set "__=   "
if /i %num% GTR 9     set "__=  "
if /i %num% GTR 99    set "__= "
if /i %num% GTR 999   set "__="
if /i %num% GTR 9999  set "__="
Exit /b

:FI-Refresh                       
call :timer-start
if exist "%RCFI%\resources\refresh.RCFI" (if defined Context exit else goto options) else (echo    refreshing >>"%RCFI%\resources\refresh.RCFI")
if /i not "%Context%"=="" echo.&echo.&echo.
echo %_%%G_%%TAB%Note: In case if the process gets stuck and explorer doesn't come back.
echo %TAB%Hold %I_% CTRL %_%%G_%+%I_% SHIFT %_%%G_%+%I_% ESC %_%%G_%%-% %G_%^> Click File ^> Run New Task ^> Type "explorer" ^> OK.
echo %TAB%%CC_%Restarting Explorer and updating icon cache ..%R_%
echo.&set "startexplorer="
rem ie4uinit.exe -ClearIconCache
rem ie4uinit.exe -show
set Context=&Set Setup=
taskkill /F /IM explorer.exe >nul ||echo 	echo %I_%%R_% Failed to Terminate "Explorer.exe" %_%
PUSHD "%userprofile%\AppData\Local\Microsoft\Windows\Explorer"
if exist "iconcache_*.db" attrib -h iconcache_*.db
if exist "%localappdata%\IconCache.db" DEL /A /Q "%localappdata%\IconCache.db"
if exist "%localappdata%\Microsoft\Windows\Explorer\iconcache*" DEL /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\iconcache*"
start explorer.exe ||set "startexplorer=fail"
POPD
if "%startexplorer%"=="fail" (
	echo.
	echo %I_%%R_%  Failed to start "Explorer.exe"  %_%
	%P4%
	)
if /i "%RefreshOpen%"=="Select" (explorer.exe /select, "%cd%") else explorer.exe "%cd%"
echo %TAB%%TAB%%CC_%%I_%    Done!   %-%
if /i "%cdonly%"=="true" set "cdonly="&PUSHD    ..
call :FI-Refresh-NoRestart
if /i "%act%"=="Refresh" EXIT /B
goto options

:FI-Refresh-NoRestart             
@echo off
set "WaitRefreshDelay=echo.&echo.&echo %G_%  if the folder icon hasn't changed yet, Please&echo   wait for 30-40 seconds then refresh again.%_%"
mode con:cols=50 lines=9
title  refresh folder icon..
set refreshCount=0
for %%F in (.) do (
	set "foldername=%%~nxF"
	if exist "desktop.ini" (
		title  "%%~nxF"
		%WaitRefreshDelay%
		echo.
		echo %TAB%%W_%Refreshing ..%_%
		echo %ESC%%CC_%%%~nxF%ESC%%R_%
		attrib -r "%cd%"
		attrib -s -h 		"desktop.ini"
		ren "desktop.ini" "DESKTOP INI"
		ren "DESKTOP INI" "desktop.ini"
		attrib +r "%cd%"
		Attrib %Attrib% 		"desktop.ini"
		attrib |EXIT /B
		set /a refreshCount+=1
	) else (
		title  "%%~nxF"
		echo %TAB%%W_%Refreshing ..%_%
		echo %ESC%%%~nxF%ESC%
	)
)
CLS
if /i not "%cdonly%"=="true" FOR /f "tokens=*" %%R in ('dir /b /a:d') do (
	PUSHD "%%R"
		if exist "desktop.ini" (
			title  refreshing.. "%%R"
			%WaitRefreshDelay%
			echo.
			echo %TAB%%W_%Refreshing ..%_%
			echo %ESC%%CC_%%%R%ESC%%R_%
			attrib -r "%%~fR"
			attrib -s -h 		"desktop.ini"
			ren "desktop.ini" "DESKTOP INI"
			ren "DESKTOP INI" "desktop.ini"
			attrib +r "%%~fR"
			Attrib %Attrib% 		"desktop.ini"
			attrib |EXIT /B
			set /a refreshCount+=1
		) else (
			title  "%%R"
			echo %TAB%%W_%Refreshing ..%_%
			echo %ESC%%_%%%R%ESC%
		)
		CLS
	POPD
)

rem ie4uinit.exe -ClearIconCache >nul
rem ie4uinit.exe -show >nul
title  "%foldername%"
%WaitRefreshDelay%
echo.
echo %TAB%               %I_%%W_%    Done!    %_%
echo. &echo.
ping localhost -n 2 >nul
del "%RCFI%\resources\refresh.RCFI" 2
ping localhost -n 1 >nul
exit

:IMG-Generate_icon
if /i "%TemplateAlwaysAsk%"=="Yes" (call :FI-Template-AlwaysAsk&cls&echo.&echo.&echo.)
call :timer-start
FOR %%T in ("%Template%") do set "TName=%%~nT"
echo %TAB%       %I_%%W_%    Generating Icon..    %_%
echo.
echo %TAB%Template:%ESC%%CC_%%Tname%%ESC%
echo %TAB%%_%----------------------------------------------------%_%
if "%Context%"=="IMG.Generate.PNG" (set "OutputExt=.png") else (set "OutputExt=.ico")
FOR %%I in (%xSelected%) do (
	set "IMGpath=%%~dpI"
	set "IMGfullpath=%%~fI"
	set "IMGname=%%~nI"
	set "IMGext=%%~xI"
	set "Size_B=%%~zI"
	set "-=%G_%-"
	call :FileSize
	echo.
	Call :IMG-Generate_icon-FileList
	call :IMG-Generate_icon-Act
	call :IMG-Generate_icon-Done
)
echo.
echo %TAB%%_%----------------------------------------------------%_%
echo.
echo %TAB%%G_%%I_%  Done!  %_%
goto options

:IMG-Generate_icon-FileList
if /i "%IMGext%"==".ico" set "IMGext=%Y_%%IMGext%"
if /i "%IMGext%"==".png" set "IMGext=%CC_%%IMGext%"
echo %_%%TAB%%ESC%%C_%%IMGname%%BB_%%IMGext% %G_%(%PP_%%size%%G_%)%ESC%%R_%
EXIT /B

:IMG-Generate_icon-Act
set /a filenum+=1
set "InputFile=%IMGfullpath%"
set "OutputFile=%IMGpath%%IMGname%%OutputExt%"

if exist "%OutputFile%" (
	if not exist "%IMGpath%%IMGname%-%filenum%%OutputExt%" (
		set "OutputFile=%IMGpath%%IMGname%-%filenum%%OutputExt%"
	) else (
		goto IMG-Generate_icon-Act
	)
)
PUSHD "%IMGpath%"
	call "%Template%"
POPD
EXIT /B

:IMG-Generate_icon-Done
if exist "%OutputFile%" (
		for %%G in ("%OutputFile%") do (
			set "Size_B=%%~zG"
			set "IMGname=%%~nG"
			set "IMGext=%%~xG"
			set "Size_B=%%~zG"
			set "-=%G_%-"
			call :FileSize
			call :IMG-Generate_icon-FileList
		)
	) else (echo %TAB%%R_%Failed to generate icon.)
EXIT /B

:IMG-Convert                      
call :timer-start
set separator=echo %TAB% %_%--------------------------------------------------------------------%_%
if not defined Action echo %TAB%       %I_%%W_%    IMAGE CONVERTER    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %I_%%CC_%    IMAGE CONVERTER    %_%
	%separator%
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
			call :IMG-Convert-FileList
			call :IMG-Convert-Action
		)
		%separator%
	)
) else (
	FOR %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do ( 
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
		)
		call :IMG-Convert-FileList
	)
	%separator%
	call :IMG-Convert-Options
)
echo  %TAB%%G_%%I_%  Done!  %_%
goto options

:IMG-Convert-FileList             
echo %TAB%%_%%ESC%- %C_%%ImgName%%ImgExt%%_% %G_%(%PP_%%size%%G_%)%ESC%%R_%
EXIT /B

:IMG-Convert-Options              
echo.
echo %TAB%%G_%To select, just press the %GG_%number%G_% associated below.
echo.
echo %TAB%  Select Image extension:
echo %TAB%  %GN_%1%_% ^>%CC_%.jpg%_%
echo %TAB%  %GN_%2%_% ^>%CC_%.png%_%
echo %TAB%  %GN_%3%_% ^>%CC_%.ico%_%
echo %TAB%  %GN_%4%_% ^>%CC_%.bmp%_%
echo %TAB%  %GN_%5%_% ^>%CC_%.svg%_%
echo %TAB%  %GN_%6%_% ^>%CC_%.webp%_%
echo %TAB%  %GN_%7%_% ^>%CC_%.heif%_%
echo.
echo %TAB%%G_%Press %GN_%i%G_% to input any extension you want. %_%^| %G_%Press %GN_%c%G_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgExtNew=.jpg" 
if /i "%ImgSizeInput%"=="2" set "ImgExtNew=.png"
if /i "%ImgSizeInput%"=="3" set "ImgExtNew=.ico"&set "ConvertCode=-resize 256x256"
if /i "%ImgSizeInput%"=="4" set "ImgExtNew=.bmp"
if /i "%ImgSizeInput%"=="5" set "ImgExtNew=.svg"
if /i "%ImgSizeInput%"=="6" set "ImgExtNew=.webp"
if /i "%ImgSizeInput%"=="7" set "ImgExtNew=.heif"
if /i "%ImgSizeInput%"=="8" (
	echo %TAB%%G_%Input file extension you want, example: %YY_%.gif%G_%
	set /p "ImgExtNew=%-%%-%%-%%W_%Input:%YY_%"
)
if /i "%ImgSizeInput%"=="9" echo %TAB%  %W_%%I_%  CANCELED  %_%&goto options
set "ImgResizeCode=%ImgResizeCode:"=%"
set "Action=Start" &cls&goto IMG-Convert

:IMG-Convert-Action               
set Size_B=1
set "ImgOutput=%ImgName%%nTag%%ImgExtNew%"
if exist "%ImgPath%%ImgOutput%" set /a numCount+=1
if exist "%ImgPath%%ImgOutput%" set "nTag= (%numCount%)"&goto IMG-Convert-Action

"%converter%" "%ImgPath%%ImgName%%ImgExt%" %convertcode% "%ImgPath%%ImgOutput%"

if "%ImgExt%"==".ico" (
	PUSHD "%ImgPath%"
	if exist "%ImgName%-*%ImgExtNew%" (
		echo.
		echo %TAB% %_%The icon file contains multiple resolution resources.
		for %%G in ("%ImgName%-*%ImgExtNew%") do (
			for %%I in ("%%~fG") do (
				set "Size_B=%%~zI"
				set "ImgName=%%~nI"
				set "ImgExt=%%~xI"
				call :FileSize
				call :IMG-Convert-FileList
			)
		)
	if not exist "%ImgPath%%ImgOutput%" EXIT /B
	)
	POPD
)
if exist "%ImgPath%%ImgOutput%" (
	for %%I in ("%ImgPath%%ImgOutput%") do (
		set "Size_B=%%~zI"
		set "ImgName=%%~nI"
		set "ImgExt=%%~xI"
		call :FileSize
		call :IMG-Convert-FileList
	)
) else (
	echo %TAB%-%ESC%%C_%%ImgName%%nTag%%ImgExt%%G_% (%R_%Convert Fail!%G_%)%_%
	EXIT /B
)
if %Size_B% LSS 100 (
	echo %TAB% %R_%Convert Fail!%_%
	del "%ImgPath%%ImgOutput%"
)
EXIT /B

:IMG-Resize                       
if not exist "%RCFI%\RCFI.img-resizer.ini" (
	(
	echo.
	echo     [  IMAGE RESIZER CONFIG  ]
	echo.
	echo IMGResize1Tag="_256p"
	echo IMGResize1Name="256p"
	echo IMGResize1Code="-resize 256x256"
	echo.
	echo IMGResize2Tag="_512p"
	echo IMGResize2Name="512p"
	echo IMGResize2Code="-resize 512x512"
	echo.
	echo IMGResize3Tag="_720p"
	echo IMGResize3Name="720p"
	echo IMGResize3Code="-resize 720x720"
	echo.
	echo IMGResize4Tag="_1080p"
	echo IMGResize4Name="1080p"
	echo IMGResize4Code="-resize 1080x1080"
	echo.
	echo IMGResize5Tag="_1440p"
	echo IMGResize5Name="1440p"
	echo IMGResize5Code="-resize 1440x1440"
	echo.
	echo IMGResize6Tag="_2160p"
	echo IMGResize6Name="2160p"
	echo IMGResize6Code="-resize 2160x2160"
	echo.
	echo IMGResize7Tag="_3240p"
	echo IMGResize7Name="3240p"
	echo IMGResize7Code="-resize 3240x3240"
	)>"%RCFI%\RCFI.img-resizer.ini"
)
set separator=echo %TAB% %_%--------------------------------------------------------------------%_%
if not defined Action echo %TAB%       %I_%%W_%    IMAGE RESIZER    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %I_%%CC_%    IMAGE CONVERTER    %_%
	%separator%
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"
			set "ImgName=%%~nI"
			set "ImgExt=%%~xI"
			set "Size_B=%%~zI"
			set "numTag=1"
			call :FileSize
			call :IMG-Resize-FileList
			call :IMG-Resize-Action
		)
	%separator%
	)
) else (
	FOR %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do ( 
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
		)
		call :IMG-Resize-FileList
	)
	%separator%
	call :IMG-Resize-Options
)
echo  %TAB%%G_%%I_%  Done!  %_%
goto options

:IMG-Resize-FileList              
echo %TAB%%ESC%- %C_%%ImgName%%ImgExt%%G_% (%PP_%%size%%G_%)%ESC%%R_%
EXIT /B

:IMG-Resize-Options               
for /f "usebackq tokens=1,2 delims==" %%C in ("%RCFI%\RCFI.img-resizer.ini") do (set "%%C=%%D")
set  "IMGResize1Tag=%IMGResize1Tag:"=%"
set "IMGResize1Name=%IMGResize1Name:"=%"
set "IMGResize1Code=%IMGResize1Code:"=%"

set  "IMGResize2Tag=%IMGResize2Tag:"=%"
set "IMGResize2Name=%IMGResize2Name:"=%"
set "IMGResize2Code=%IMGResize2Code:"=%"

set  "IMGResize3Tag=%IMGResize3Tag:"=%"
set "IMGResize3Name=%IMGResize3Name:"=%"
set "IMGResize3Code=%IMGResize3Code:"=%"

set  "IMGResize4Tag=%IMGResize4Tag:"=%"
set "IMGResize4Name=%IMGResize4Name:"=%"
set "IMGResize4Code=%IMGResize4Code:"=%"

set  "IMGResize5Tag=%IMGResize5Tag:"=%"
set "IMGResize5Name=%IMGResize5Name:"=%"
set "IMGResize5Code=%IMGResize5Code:"=%"

set  "IMGResize6Tag=%IMGResize6Tag:"=%"
set "IMGResize6Name=%IMGResize6Name:"=%"
set "IMGResize6Code=%IMGResize6Code:"=%"

set  "IMGResize7Tag=%IMGResize7Tag:"=%"
set "IMGResize7Name=%IMGResize7Name:"=%"
set "IMGResize7Code=%IMGResize7Code:"=%"

echo.
echo %TAB%%G_%To select, just press the %GG_%number%G_% associated below.
echo.
echo %TAB%  Select Image size:
echo %TAB%  %GN_%1%_% ^>%CC_%%IMGResize1Name%%_%
echo %TAB%  %GN_%2%_% ^>%CC_%%IMGResize2Name%%_%
echo %TAB%  %GN_%3%_% ^>%CC_%%IMGResize3Name%%_%
echo %TAB%  %GN_%4%_% ^>%CC_%%IMGResize4Name%%_%
echo %TAB%  %GN_%5%_% ^>%CC_%%IMGResize5Name%%_%
echo %TAB%  %GN_%6%_% ^>%CC_%%IMGResize6Name%%_%
echo %TAB%  %GN_%7%_% ^>%CC_%%IMGResize7Name%%_%
echo.
echo %TAB%%G_%Press %GN_%i%G_% to input your prefer output.%_% ^| %G_%Press %GN_%c%G_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgResizeCode=%IMGResize1Code%"&set "ImgTag=%IMGResize1Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="2" set "ImgResizeCode=%IMGResize2Code%"&set "ImgTag=%IMGResize2Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="3" set "ImgResizeCode=%IMGResize3Code%"&set "ImgTag=%IMGResize3Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="4" set "ImgResizeCode=%IMGResize4Code%"&set "ImgTag=%IMGResize4Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="5" set "ImgResizeCode=%IMGResize5Code%"&set "ImgTag=%IMGResize5Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="6" set "ImgResizeCode=%IMGResize6Code%"&set "ImgTag=%IMGResize6Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="7" set "ImgResizeCode=%IMGResize7Code%"&set "ImgTag=%IMGResize7Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="9" echo %TAB%  %W_%%I_%  CANCELED  %_%&goto options

echo %TAB%%G_%Input your own  command, example: 
echo %TAB%%YY_%-resize 1000x1000!%G_% = force resize tha image to 1000px1000p and ignore the aspect ratio.
echo %TAB%%YY_%-quality 85%G_%        = compress the image to 85%% quality.
echo %TAB%%YY_%-resize 1000x%G_%      = resize the image to a width of 1000p.
echo %TAB%%YY_%-resize x1000%G_%      = resize the image to a height of 1000p.
echo %TAB%%YY_%-resize 720x720 -quality 80%G_% = resize the image to 720p and compress the quality to 80%%.

echo.
set /p "ImgResizeCode=%-%%-%%-%%W_%Input:%YY_%"
set "ImgResizeCode=%ImgResizeCode:"=%"
set "ImgTag=_custom"
if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize

:IMG-Resize-Action                
set size_B=1
set "ImgOutput=%ImgName%%ImgTag%%nTag%%ImgExt%"
if exist "%ImgPath%%ImgOutput%" set /a numCount+=1
if exist "%ImgPath%%ImgOutput%" set "nTag= (%numCount%)"&goto IMG-Resize-Action

"%converter%" "%ImgPath%%ImgName%%ImgExt%" %ImgResizeCode% "%ImgPath%%ImgOutput%"
if exist "%ImgPath%%ImgOutput%" (
	for %%I in ("%ImgPath%%ImgOutput%") do (
		set "Size_B=%%~zI"
		call :FileSize
	)
) else (
	echo %TAB%%ESC%- %C_%%ImgName%%ImgExt%%G_% (%R_%Convert Fail!%G_%)%_%
	EXIT /B
)

if not %size_B% LSS 10 (
	echo %TAB%%ESC%- %C_%%ImgName%%CC_%%ImgTag%%nTag%%C_%%ImgExt%%G_% (%PP_%%size%%G_%)%ESC%%R_%
) else (
	echo %TAB%%ESC%- %C_%%ImgName%%ImgExt%%G_% (%R_%Convert Fail!%G_%)%_%
	del "%ImgPath%%ImgOutput%"
	EXIT /B
)
EXIT /B


:IMG-Compress                       
if not exist "%RCFI%\RCFI.img-compressor.ini" (
	(
	echo.
	echo     [  IMAGE COMPRESSOR CONFIG  ]
	echo.
	echo IMGCompress1Tag="_(95%%)"
	echo IMGCompress1Name=" 95%%"
	echo IMGCompress1Code="-quality 95"
	echo.
	echo IMGCompress2Tag="_(90%%)"
	echo IMGCompress2Name=" 90%%"
	echo IMGCompress2Code="-quality 90"
	echo.
	echo IMGCompress3Tag="_(85%%)"
	echo IMGCompress3Name=" 85%%"
	echo IMGCompress3Code="-quality 85"
	echo.
	echo IMGCompress4Tag="_(80%%)"
	echo IMGCompress4Name=" 80%%"
	echo IMGCompress4Code="-quality 80"
	echo.
	echo IMGCompress5Tag="_(75%%)"
	echo IMGCompress5Name=" 75%%"
	echo IMGCompress5Code="-quality 75"
	echo.
	echo IMGCompress6Tag="_(70%%)"
	echo IMGCompress6Name=" 70%%"
	echo IMGCompress6Code="-quality 70"
	echo.
	echo IMGCompress7Tag="_(60%%)"
	echo IMGCompress7Name=" 60%%"
	echo IMGCompress7Code="-quality 60"
	)>"%RCFI%\RCFI.img-compressor.ini"
)
set separator=echo %TAB% %_%--------------------------------------------------------------------%_%
if not defined Action echo %TAB%       %I_%%W_%    IMAGE COMPRESSOR    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %I_%%CC_%    IMAGE CONVERTER    %_%
	%separator%
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"
			set "ImgName=%%~nI"
			set "ImgExt=%%~xI"
			set "Size_B=%%~zI"
			set "numTag=1"
			call :FileSize
			call :IMG-Compress-FileList
			call :IMG-Compress-Action
		)
	%separator%
	)
) else (
	FOR %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do ( 
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
		)
		call :IMG-Compress-FileList
	)
	%separator%
	call :IMG-Compress-Options
)
echo  %TAB%%G_%%I_%  Done!  %_%
goto options

:IMG-Compress-FileList              
echo %TAB%%ESC%- %C_%%ImgName%%ImgExt%%G_% (%PP_%%size%%G_%)%ESC%%R_%
EXIT /B

:IMG-Compress-Options               
for /f "usebackq tokens=1,2 delims==" %%C in ("%RCFI%\RCFI.img-compressor.ini") do (set "%%C=%%D")
set  "IMGCompress1Tag=%IMGCompress1Tag:"=%"
set "IMGCompress1Name=%IMGCompress1Name:"=%"
set "IMGCompress1Code=%IMGCompress1Code:"=%"

set  "IMGCompress2Tag=%IMGCompress2Tag:"=%"
set "IMGCompress2Name=%IMGCompress2Name:"=%"
set "IMGCompress2Code=%IMGCompress2Code:"=%"

set  "IMGCompress3Tag=%IMGCompress3Tag:"=%"
set "IMGCompress3Name=%IMGCompress3Name:"=%"
set "IMGCompress3Code=%IMGCompress3Code:"=%"

set  "IMGCompress4Tag=%IMGCompress4Tag:"=%"
set "IMGCompress4Name=%IMGCompress4Name:"=%"
set "IMGCompress4Code=%IMGCompress4Code:"=%"

set  "IMGCompress5Tag=%IMGCompress5Tag:"=%"
set "IMGCompress5Name=%IMGCompress5Name:"=%"
set "IMGCompress5Code=%IMGCompress5Code:"=%"

set  "IMGCompress6Tag=%IMGCompress6Tag:"=%"
set "IMGCompress6Name=%IMGCompress6Name:"=%"
set "IMGCompress6Code=%IMGCompress6Code:"=%"

set  "IMGCompress7Tag=%IMGCompress7Tag:"=%"
set "IMGCompress7Name=%IMGCompress7Name:"=%"
set "IMGCompress7Code=%IMGCompress7Code:"=%"

echo.
echo %TAB%%G_%To select, just press the %GG_%number%G_% associated below.
echo.
echo %TAB%  Select Image compression level quality:
echo %TAB%  %GN_%1%_% ^>%CC_%%IMGCompress1Name%%_%
echo %TAB%  %GN_%2%_% ^>%CC_%%IMGCompress2Name%%_%
echo %TAB%  %GN_%3%_% ^>%CC_%%IMGCompress3Name%%_%
echo %TAB%  %GN_%4%_% ^>%CC_%%IMGCompress4Name%%_%
echo %TAB%  %GN_%5%_% ^>%CC_%%IMGCompress5Name%%_%
echo %TAB%  %GN_%6%_% ^>%CC_%%IMGCompress6Name%%_%
echo %TAB%  %GN_%7%_% ^>%CC_%%IMGCompress7Name%%_%
echo.
echo %TAB%%G_%Press %GN_%i%G_% to input your prefer output.%_% ^| %G_%Press %GN_%c%G_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgCompressCode=%IMGCompress1Code%"&set "ImgTag=%IMGCompress1Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="2" set "ImgCompressCode=%IMGCompress2Code%"&set "ImgTag=%IMGCompress2Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="3" set "ImgCompressCode=%IMGCompress3Code%"&set "ImgTag=%IMGCompress3Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="4" set "ImgCompressCode=%IMGCompress4Code%"&set "ImgTag=%IMGCompress4Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="5" set "ImgCompressCode=%IMGCompress5Code%"&set "ImgTag=%IMGCompress5Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="6" set "ImgCompressCode=%IMGCompress6Code%"&set "ImgTag=%IMGCompress6Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="7" set "ImgCompressCode=%IMGCompress7Code%"&set "ImgTag=%IMGCompress7Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="9" echo %TAB%  %W_%%I_%  CANCELED  %_%&goto options

echo %TAB%%G_%Input your own  command, example: 
echo %TAB%%YY_%-resize 1000x1000!%G_% = force resize tha image to 1000px1000p and ignore the aspect ratio.
echo %TAB%%YY_%-quality 85%G_%        = compress the image to 85%% quality.
echo %TAB%%YY_%-resize 1000x%G_%      = resize the image to a width of 1000p.
echo %TAB%%YY_%-resize x1000%G_%      = resize the image to a height of 1000p.
echo %TAB%%YY_%-resize 720x720 -quality 80%G_% = resize the image to 720p and compress the quality to 80%%.
echo.
set /p "ImgCompressCode=%-%%-%%-%%W_%Input:%YY_%"
set "ImgCompressCode=%ImgCompressCode:"=%"
set "ImgTag=_custom"
if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress

:IMG-Compress-Action                
set size_B=1
set "ImgOutput=%ImgName%%ImgTag%%nTag%%ImgExt%"
if exist "%ImgPath%%ImgOutput%" set /a numCount+=1
if exist "%ImgPath%%ImgOutput%" set "nTag= (%numCount%)"&goto IMG-Compress-Action

"%converter%" "%ImgPath%%ImgName%%ImgExt%" %ImgCompressCode% "%ImgPath%%ImgOutput%"
if exist "%ImgPath%%ImgOutput%" (
	for %%I in ("%ImgPath%%ImgOutput%") do (
		set "Size_B=%%~zI"
		call :FileSize
	)
) else (
	echo %TAB%-%ESC%%C_%%ImgName%%ImgExt%%G_% (%R_%Convert Fail!%G_%)%_%
	EXIT /B
)

if not %size_B% LSS 1000 (
	echo %TAB%%ESC%- %C_%%ImgName%%CC_%%ImgTag%%nTag%%C_%%ImgExt%%G_% (%PP_%%size%%G_%)%ESC%%R_%
) else (
	echo %TAB%-%ESC%%C_%%ImgName%%ImgExt%%G_% (%R_%Convert Fail!%G_%)%_%
	del "%ImgPath%%ImgOutput%"
	EXIT /B
)
EXIT /B


:FileSize                         
if "%size_B%"=="" set size=0 KB&echo %R_%Error: Fail to get file size!%_% &EXIT /B
set /a size_KB=%size_B%/1024
set /a size_MB=%size_KB%00/1024
set /a size_GB=%size_MB%/1024
set size_MB=%size_MB:~0,-2%.%size_MB:~-2%
set size_GB=%size_GB:~0,-2%.%size_GB:~-2%
if %size_B% NEQ 1024 set size=%size_B% Bytes
if %size_B% GEQ 1024 set size=%size_KB% KB
if %size_B% GEQ 1024000 set size=%size_MB% MB
if %size_B% GEQ 1024000000 set size=%size_GB% GB
EXIT /B

:Timer-start
set timestart=%time%
EXIT /B

:Timer-end
set timeend=%time%
set options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%timestart%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
for /f %options% %%a in ("%timeend%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100
 
set /a hours=%end_h%-%start_h%
set /a mins=%end_m%-%start_m%
set /a secs=%end_s%-%start_s%
set /a ms=%end_ms%-%start_ms%
if %ms% lss 0 set /a secs = %secs% - 1 & set /a ms = 100%ms%
if %secs% lss 0 set /a mins = %mins% - 1 & set /a secs = 60%secs%
if %mins% lss 0 set /a hours = %hours% - 1 & set /a mins = 60%mins%
if %hours% lss 0 set /a hours = 24%hours%
if 1%ms% lss 100 set ms=0%ms%
 
:: Mission accomplished
set /a totalsecs = %hours%*3600 + %mins%*60 + %secs%
if %mins% lss 1 set "show_mins="
if %mins% gtr 0 set "show_mins=%mins%m "
if %hours% lss 1 set "show_hours="
if %hours% gtr 0 set "show_hours=%hours%h " 
set ExecutionTime=%show_hours%%show_mins%%secs%.%ms%s
set "processingtime=The process took %ExecutionTime% ^|"
EXIT /B



:Config                      
call :Config-Load
echo %TAB%       %I_%%PP_% RCFI Tools Configuration %_%
echo %TAB%%_%to change the configurations, you  have to edit the "RCFI.config.ini" file
echo %TAB%which is located at:%ESC%%W_%%RCFI%\%C_%RCFI.config.ini%ESC%
echo.
echo %TAB%%W_% Current Config %_%
echo %TAB%%_%----------------------------------------------------------------------
echo %TAB%%YY_%Converter%_%
echo %TAB%"%Converter%"
if exist "%Converter%" for %%I in ("%Converter%") do (
	echo %TAB%%G_%"%%~nxI" will be used to convert the image into icon.
) else (
	echo %TAB%%R_%^! %G_%Config value is not valid because
	echo %TAB%"%converter%" %R_%doesn't exist.%_%
)
echo.
echo %TAB%%YY_%DrivePath%_%
echo %TAB%"%DrivePath%"
if exist "%DrivePath%" for %%I in ("%DrivePath%") do (
	echo %TAB%%G_%"%%~nxI" is the current active working directory.
) else (
	echo %TAB%%R_%^! %G_%Config value is not valid because 
	echo %TAB%"%converter%" %R_%doesn't exist.%_%
)
echo.
echo %TAB%%YY_%Keywords%_%
echo %TAB%"%Keywords%%Keyword-extension%"
echo %TAB%%G_%Keyword will  be used to  search for the  target  image  to  use  as a 
echo %TAB%%G_%folder  icon.
echo.
echo %TAB%%YY_%Template%_%
echo %TAB%"%Template%"
if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%G_%Template:%ESC%%CC_%%%~nxI%G_%%ESC%
	echo %TAB%%G_%The template will be used to generate a folder icon.
) else (
	echo %TAB%%R_%^! %G_%Config value is not valid because 
	echo %TAB%"%converter%" %R_%doesn't exist.%_%
)
echo.
REM echo %TAB%%YY_%AlwaysGenerateSample%_%
REM echo %TAB%"%AlwaysGenerateSample%"
REM echo %TAB%%G_%If the  value is not "NO", RCFI Tools will  generate a sample image every
REM echo %TAB%%G_%time  you  select  a  template via "choose template" menu.
REM echo.
if exist "%TemplateForICO%" for %%I in ("%TemplateForICO%") do (
	echo %TAB%%YY_%TemplateForICO%_%
	echo %TAB%"%TemplateForICO%"%_%
	echo %TAB%%G_%Template:%ESC%%CC_%%%~nxI%ESC%%G_%
	echo %TAB%%G_%will be used to generate a folder icon if the selected  image is %C_%.ico%G_%.
) else (
	echo %TAB%%YY_%TemplateForICO%G_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%G_%"%CC_%%%~nxI%G_%" will be used to generate a folder icon.
	)
)
echo.
if exist "%TemplateForPNG%" for %%I in ("%TemplateForPNG%") do (
	echo %TAB%%YY_%TemplateForPNG%_%
	echo %TAB%"%TemplateForPNG%"%_%
	echo %TAB%%G_%Template:%ESC%%CC_%%%~nxI%ESC%%G_%
	echo %TAB%%G_%will be used to generate a folder icon if the selected  image is %C_%.png%G_%.
) else (
	echo %TAB%%YY_%TemplateForPNG%G_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%G_%"%CC_%%%~nxI%G_%" will be used to generate a folder icon.
	)
)
echo.
if exist "%TemplateForJPG%" for %%I in ("%TemplateForJPG%") do (
	echo %TAB%%YY_%TemplateForJPG%_%
	echo %TAB%"%TemplateForJPG%"%_%
	echo %TAB%%G_%Template:%ESC%%CC_%%%~nxI%ESC%%G_%
	echo %TAB%%G_%will be used to generate a folder icon if the selected  image is %C_%.jpg%G_%.
) else (
	echo %TAB%%YY_%TemplateForJPG%G_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%G_%"%CC_%%%~nxI%G_%" will be used to generate a folder icon.
	)
)
echo.
echo %TAB%%YY_%TemplateAlwaysAsk%_%
echo %TAB%"%TemplateAlwaysAsk%"%_%
echo %TAB%%G_%If the  value is "YES", RCFI Tools will  ask for choosing the template
echo %TAB%%G_%every  time  you  generate  a  folder icon. 
echo.
echo %TAB%%YY_%RunAsAdmin%_%
echo %TAB%"%RunAsAdmin%"%_%
echo %TAB%%G_%If  the  value  is  "YES",  RCFI  Tools  will  be  elevated to  run as
echo %TAB%%G_%administrator  every  time  it  runs.
echo.
echo %TAB%%YY_%ExitWait%_%
echo %TAB%"%ExitWait%"%_%
echo %TAB%%G_%The window will  automatically  close  after %ExitWait% seconds. If the  value 
echo %TAB%%G_%is  more  than  99  automatic  close  will  be  disable.
echo %TAB%%_%----------------------------------------------------------------------
echo %TAB%%CC_%^>%_% Press %GG_%O%_% to open folder containing "RCFI.config.ini".
echo %TAB%%CC_%^>%_% Press %GG_%C%_% to exit.%bk_%
choice /C:oc /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" (
	echo %TAB%%W_% Opening..
	echo %TAB%%ESC%%I_%%RCFI%%ESC%
	explorer.exe /select, "%RCFI%\RCFI.config.ini"
	goto options
)
if /i "%ImgSizeInput%"=="2" echo %TAB%%_%Exiting configuration.. &goto options
goto options

:Config-Save                      
if /i "%referer%"=="MultiSelectFolder" exit /b
REM Save current config to RCFI.config.ini
if exist "%Template%"        (for %%T in ("%Template%")        do set "Template=%%~nT")       else (set "Template=%RCFI%\templates\(none).bat")
if exist "%TemplateForICO%"	(for %%T in ("%TemplateForICO%") do set "TemplateForICO=%%~nT") else (set "TemplateForICO=(none)")
if exist "%TemplateForPNG%"	(for %%T in ("%TemplateForPNG%") do set "TemplateForPNG=%%~nT") else (set "TemplateForPNG=insert a template name to use for .png files")
if exist "%TemplateForJPG%"	(for %%T in ("%TemplateForJPG%") do set "TemplateForJPG=%%~nT") else (set "TemplateForJPG=insert a template name to use for .jpg files")
if not defined TemplateIconSize set "TemplateIconSize=Auto"
(
	echo     𝐑𝐂𝐅𝐈 𝐓𝐎𝐎𝐋𝐒 𝐂𝐎𝐍𝐅𝐈𝐆𝐔𝐑𝐀𝐓𝐈𝐎𝐍
	echo.
	echo ---------  KEYWORD  --------------
	echo Keywords="%Keywords%"
	echo ----------------------------------
	echo.
	echo.
	echo ---------  TEMPLATE --------------
	echo Template="%Template%"
	echo TemplateForICO="%TemplateForICO%"
	echo TemplateForPNG="%TemplateForPNG%"
	echo TemplateForJPG="%TemplateForJPG%"
	echo.
	echo TemplateAlwaysAsk="%TemplateAlwaysAsk%"
	echo.
	echo TemplateTestMode="%TemplateTestMode%"
	echo TemplateTestMode-AutoExecute="%TemplateTestMode-AutoExecute%"
	echo.
	echo TemplateIconSize="%TemplateIconSize%"
	echo ----------------------------------
	echo.
	echo.
	echo ---------  ADDITIONAL ------------
	echo ExitWait="%ExitWait%"
	echo IconFileName="%IconFileName%"
	echo HideAsSystemFiles="%HideAsSystemFiles%"
	echo DeleteOriginalFile="%DeleteOriginalFile%"
	echo TextEditor="%TextEditor%"
	echo ----------------------------------
	echo.
	echo.
	echo.
	echo ===========  HISTORY  ============
	echo DrivePath="%cd%"	
)>"%RCFI.config.ini%"
if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="
set "Template=%RCFI%\templates\%Template:"=%.bat"
set "TemplateForICO=%RCFI%\templates\%TemplateForICO:"=%.bat"
set "TemplateForPNG=%RCFI%\templates\%TemplateForPNG:"=%.bat"
set "TemplateForJPG=%RCFI%\templates\%TemplateForJPG:"=%.bat"


if defined keywords1 (
	(
		echo.
		echo ---------  Keywords --------------
		echo keywords1="%keywords1%"
	) >>"%RCFI.config.ini%"
)
if defined keywords2 echo keywords2="%keywords2%">>"%RCFI.config.ini%"
if defined keywords3 echo keywords3="%keywords3%">>"%RCFI.config.ini%"
if defined keywords4 echo keywords4="%keywords4%">>"%RCFI.config.ini%"
if defined keywords5 echo keywords5="%keywords5%">>"%RCFI.config.ini%"
if defined keywords6 echo keywords6="%keywords6%">>"%RCFI.config.ini%"
if defined keywords7 echo keywords7="%keywords7%">>"%RCFI.config.ini%"
if defined keywords8 echo keywords8="%keywords8%">>"%RCFI.config.ini%"
if defined keywords9 echo keywords9="%keywords9%">>"%RCFI.config.ini%"

if defined MoveDst1 (
	(
		echo.
		echo.
		echo ---------  Move  -----------------
		echo MoveDst1="%MoveDst1%"
	) >>"%RCFI.config.ini%"
)
if defined MoveDst2 echo MoveDst2="%MoveDst2%">>"%RCFI.config.ini%"
if defined MoveDst3 echo MoveDst3="%MoveDst3%">>"%RCFI.config.ini%"
if defined MoveDst4 echo MoveDst4="%MoveDst4%">>"%RCFI.config.ini%"
if defined MoveDst5 echo MoveDst5="%MoveDst5%">>"%RCFI.config.ini%"
if defined MoveDst6 echo MoveDst6="%MoveDst6%">>"%RCFI.config.ini%"
if defined MoveDst7 echo MoveDst7="%MoveDst7%">>"%RCFI.config.ini%"
if defined MoveDst8 echo MoveDst8="%MoveDst8%">>"%RCFI.config.ini%"
if defined MoveDst9 echo MoveDst9="%MoveDst9%">>"%RCFI.config.ini%"

if defined Rename1 (
	(
		echo.
		echo.
		echo ---------  Rename  ---------------
		echo Rename1="%Rename1%"
	) >>"%RCFI.config.ini%"
)
if defined Rename2 echo Rename2="%Rename2%">>"%RCFI.config.ini%"
if defined Rename3 echo Rename3="%Rename3%">>"%RCFI.config.ini%"
if defined Rename4 echo Rename4="%Rename4%">>"%RCFI.config.ini%"
if defined Rename5 echo Rename5="%Rename5%">>"%RCFI.config.ini%"
if defined Rename6 echo Rename6="%Rename6%">>"%RCFI.config.ini%"
if defined Rename7 echo Rename7="%Rename7%">>"%RCFI.config.ini%"
if defined Rename8 echo Rename8="%Rename8%">>"%RCFI.config.ini%"
if defined Rename9 echo Rename9="%Rename9%">>"%RCFI.config.ini%"

EXIT /B

:Config-Load                      
REM Load Config from RCFI.config.ini
if not exist "%RCFI.config.ini%" call :Config-GetDefault
if not exist "%~dp0RCFI.templates.ini" call :Config-GetTemplatesConfig

if exist "%RCFI.config.ini%" (
	for /f "usebackq tokens=1,2 delims==" %%C in ("%RCFI.config.ini%") do (set "%%C=%%D")
) else (
	echo.&echo.&echo.&echo.
	echo       %W_%Couldn't load RCFI.config.ini.   %R_%Access is denied.
	echo       %W_%Try Run As Admin.%_%
	%P5%&%p5%&exit
)

if exist %Template% (for %%T in (%Template%) do set Template="%%~nT")       
if exist %TemplateForICO%	(for %%T in (%TemplateForICO%) do set TemplateForICO="%%~nT")
if exist %TemplateForPNG%	(for %%T in (%TemplateForPNG%) do set TemplateForPNG="%%~nT")
if exist %TemplateForJPG%	(for %%T in (%TemplateForJPG%) do set TemplateForJPG="%%~nT")
set "DrivePath=%DrivePath:"=%"
set "Keywords=%Keywords:"=%"
set "Template=%RCFI%\templates\%Template:"=%.bat"
set "TemplateForICO=%RCFI%\templates\%TemplateForICO:"=%.bat"
set "TemplateForPNG=%RCFI%\templates\%TemplateForPNG:"=%.bat"
set "TemplateForJPG=%RCFI%\templates\%TemplateForJPG:"=%.bat"
set "TemplateAlwaysAsk=%TemplateAlwaysAsk:"=%"
set "TemplateTestMode=%TemplateTestMode:"=%"
set "TemplateTestMode-AutoExecute=%TemplateTestMode-AutoExecute:"=%"
set "TemplateIconSize=%TemplateIconSize:"=%"
set "IconFileName=%IconFileName:"=%"
set "HideAsSystemFiles=%HideAsSystemFiles:"=%"
set "DeleteOriginalFile=%DeleteOriginalFile:"=%"
set "TextEditor=%TextEditor:"=%"


if defined Keywords1 set "Keywords1=%Keywords1:"=%"
if defined Keywords2 set "Keywords2=%Keywords2:"=%"
if defined Keywords3 set "Keywords3=%Keywords3:"=%"
if defined Keywords4 set "Keywords4=%Keywords4:"=%"
if defined Keywords5 set "Keywords5=%Keywords5:"=%"
if defined Keywords6 set "Keywords6=%Keywords6:"=%"
if defined Keywords7 set "Keywords7=%Keywords7:"=%"
if defined Keywords8 set "Keywords8=%Keywords8:"=%"
if defined Keywords9 set "Keywords9=%Keywords9:"=%"


if defined Rename1 set "Rename1=%Rename1:"=%"
if defined Rename2 set "Rename2=%Rename2:"=%"
if defined Rename3 set "Rename3=%Rename3:"=%"
if defined Rename4 set "Rename4=%Rename4:"=%"
if defined Rename5 set "Rename5=%Rename5:"=%"
if defined Rename6 set "Rename6=%Rename6:"=%"
if defined Rename7 set "Rename7=%Rename7:"=%"
if defined Rename8 set "Rename8=%Rename8:"=%"
if defined Rename9 set "Rename9=%Rename9:"=%"


if defined MoveDst1 set "MoveDst1=%MoveDst1:"=%"
if defined MoveDst2 set "MoveDst2=%MoveDst2:"=%"
if defined MoveDst3 set "MoveDst3=%MoveDst3:"=%"
if defined MoveDst4 set "MoveDst4=%MoveDst4:"=%"
if defined MoveDst5 set "MoveDst5=%MoveDst5:"=%"
if defined MoveDst6 set "MoveDst6=%MoveDst6:"=%"
if defined MoveDst7 set "MoveDst7=%MoveDst7:"=%"
if defined MoveDst8 set "MoveDst8=%MoveDst8:"=%"
if defined MoveDst9 set "MoveDst9=%MoveDst9:"=%"



if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="
if /i "%IconFileName%"=="" set "IconFileName=foldericon(#ID)"
if /i "%HideAsSystemFiles%"=="yes" (set "Attrib=+s +h") else (set Attrib=+h)

REM "AlwaysGenerateSample=%AlwaysGenerateSample:"=%"
rem set "RunAsAdmin=%RunAsAdmin:"=%"
set "ExitWait=%ExitWait:"=%"

EXIT /B

:Config-GetDefault                
PUSHD    "%~dp0"
(
	echo Keywords="*"
	echo Template="(none)"
	echo TemplateForICO="(none)"
	echo TemplateForPNG="insert the template name to use for .png files"
	echo TemplateForJPG="insert the template name to use for .jpg files"
	echo TemplateAlwaysAsk="No"
	echo TemplateTestMode="No"
	echo TemplateTestMode-AutoExecute="No"
	echo TemplateIconSize="256"
	echo ExitWait="100"
	echo IconFileName="foldericon(#ID)"
	echo HideAsSystemFiles="No"
	echo DeleteOriginalFile="No"
	echo TextEditor="%windir%\notepad.exe"
	echo DrivePath="%cd%"
)>"%RCFI.config.ini%"
EXIT /B

:Config-GetTemplatesConfig                
PUSHD    "%~dp0"
(
	echo     𝐆𝐋𝐎𝐁𝐀𝐋 𝐓𝐄𝐌𝐏𝐋𝐀𝐓𝐄 𝐂𝐎𝐍𝐅𝐈𝐆𝐔𝐑𝐀𝐓𝐈𝐎𝐍
	echo This config will override template configurations for all templates.
	echo - You can add any config inside any template here.
	echo - Config with no value ^(empty/blank^) will be ignored.
	echo.
	echo.
	echo set "display-FolderName="
	echo set "use-Logo-instead-FolderName="
	echo set "display-clearArt="
	echo.
	echo set "display-movieinfo="
	echo set "show-Rating="
	echo set "show-Genre="
)>"%RCFI.templates.ini%"
EXIT /B

:Config-UpdateVar                 
title %name% %version%   "%cd%"
set "result=0"
set "keywordsFind=*%keywords%*"
set "keywordsFind=%keywordsFind: =*%"
set "keywordsFind=%keywordsFind:.=*%
set "keywordsFind=%keywordsFind:(=%"
set "keywordsFind=%keywordsFind:)=%"
set "keywordsFind=%keywordsFind:!=%"
set "keywordsFind=%keywordsFind:[=%"
set "keywordsFind=%keywordsFind:]=%"
set "keywordsFind=%keywordsFind:<=%"
set "keywordsFind=%keywordsFind:>=%"
set "keywordsFind=%keywordsFind:,=*,*%"
for %%X in (%ImageSupport%) do (
	set ImgExtS=%%X
	call :FI-Keyword-ImageSupport
)
call set "KeywordsPrint=%%Keywords:,=%C_%,%_%%%"
for %%T in ("%Template%") do set "TemplateName=%%~nT"
EXIT /B

:Config-Varset                    
rem Define color palette and some variables
set "g_=[90m"
set "gg_=[32m"
set "gn_=[92m"
set "u_=[4m"
set "w_=[97m"
set "r_=[31m"
set "rr_=[91m"
set "b_=[34m"
set "bb_=[94m"
set "bk_=[30m"
set "y_=[33m"
set "yy_=[93m"
set "c_=[36m"
set "cc_=[96m"
set "_=[0m"
set "-=[0m[30m-[0m"
set "i_=[7m"
set "p_=[35m"
set "pp_=[95m"
set "ntc_=%_%%I_%%W_% %_%%-%"
set "TAB=   "
set ESC=[30m"[0m
set "AST=%R_%*%_%"

rem Initiating variables for FI-Scan-Desktop.ini
set "yy_result=0"
set "y_result=0"
set "g_result=0"
set "r_result=0"
set "h_result=0"
set  "Y_d=1"
set  "G_d=1"
set  "R_d=1"
set "YY_d=1"
set "success_result=0"
set "fail_result=0"

rem Storing required file path                  
set p1=ping localhost -n 1 ^>nul
set p2=ping localhost -n 2 ^>nul
set p3=ping localhost -n 3 ^>nul
set p4=ping localhost -n 4 ^>nul
set p5=ping localhost -n 5 ^>nul
set "RCFI=%~dp0"
set "RCFI=%RCFI:~0,-1%"
set "RCFID=%RCFI%\uninstall.cmd"
set "Converter=%RCFI%\resources\Convert.exe"
set "montage=%RCFI%\resources\montage.exe"
set "ImageSupport=.jpg,.png,.ico,.webp,.wbmp,.bmp,.svg,.jpeg,.tiff,.heic,.heif,.tga"
set "TemplateSampleImage=%RCFI%\images\- test.jpg"
set "RCFI.config.ini=%RCFI%\RCFI.config.ini"
set "RCFI.templates.ini=%RCFI%\RCFI.templates.ini"
set "timestart="

rem Load some variables from RCFI.config.ini
call :Config-Load
if /i "%Setup%"=="Deactivate" (echo.&echo.&echo.&>"%RCFI%\resources\deactivating.RCFI" echo Deactivating)

rem initiate 'Run As Admin'
if /i "%RunAsAdmin%"=="yes" call :Config-RunAsAdmin
if exist "%temp%\RCFI.getAdmin" (for /f "usebackq tokens=*" %%A in ("%temp%\RCFI.getAdmin") do %%A&del "%temp%\RCFI.getAdmin")

rem Updating / reset some variables
if exist "%DrivePath%" (PUSHD    "%DrivePath%") else (PUSHD    "%~dp0")
call :Config-UpdateVar
EXIT /B

:Config-RunAsAdmin
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
	>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
set params=%*:"=""
if '%errorlevel%' NEQ '0' (
	(
	echo set "SelectedThing=%SelectedThing%"
	echo set "SelectedThingPath=%SelectedThingPath%"
	echo set xSelected=%xSelected%
	)> "%temp%\RCFI.getAdmin"
	echo Requesting administrative privileges...
	echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	echo UAC.ShellExecute "cmd.exe", "/c set ""context=%context%""&set ""errorlevel=0""&""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
	"%temp%\getadmin.vbs"
	del "%temp%\getadmin.vbs"
	exit
)
EXIT /B


:Config-Startup                   
if /i "%act%"=="Refresh"		goto FI-Refresh
if /i "%act%"=="RefreshNR"	goto FI-Refresh-NoRestart
if /i "%act%"=="FI-Template-Sample-All" goto FI-Template-Sample-All
if /i "%Context%"=="Refresh.Here"	PUSHD    "%SelectedThing%" &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh
if /i "%Context%"=="RefreshNR.Here"	PUSHD    "%SelectedThing%" &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh-NoRestart
if /i "%Context%"=="Refresh"			PUSHD    "%SelectedThing%" &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh
if /i "%Context%"=="RefreshNR"		PUSHD    "%SelectedThing%" &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh-NoRestart
EXIT /B


:Help                             
echo   %W_%       %U_%   O P T I O N S   %_%         %_%
echo.
echo   %GG_% Keyword%_%,%GG_% ky%_%    : Define a keyword that will be used to select an image to be used as a folder icon.
echo   %GG_% Scan%_%,%GG_% Sc%_%       : Scan and check which image will be selected as the folder icon for a specific folder.
echo   %GG_% Scans%_%,%GG_% Scs%_%     : Scan icluding all subfolders.
echo   %GG_% Template%_%,%GG_% Tp%_%   : Choose a template for folder icon.
echo   %GG_% Generate%_%,%GG_% Gn%_%   : Generate folder icon using the selected image defined by keyword.
echo   %GG_% Generates%_%,%GG_% Gns%_% : Generate including all subfolders.
echo   %GG_% Refresh%_%,%GG_% Rf%_%    : Refresh icon cache.
echo   %GG_% RefreshFc%_%,%GG_% Rfc%_% : Refresh icon cache using force methode, it will restart Explorer.
echo   %GG_% Search%_%,%GG_% Sr%_%     : Search a folder icon.
echo   %GG_% Remove%_%,%GG_% Rm %_%    : Remove all folder icon in current directory.
echo   %GG_% ON%_%             : Turn on all folder icon properties in current directory.
echo   %GG_% OFF%_%            : Turn off all folder icon properties in current directory.
echo   %GG_% O%_%              : Open current directory.
echo   %GG_% S%_%              : View current status.
echo   %GG_% R%_%              : Restart RCFI Tools.
echo   %GG_% CLS%_%            : Clear current command screen.
echo   %GG_% RCFI%_%           : Open the RCFI Tools directory.
echo   %GG_% Config%_%,%GG_% cfg %_%   : Open configurations menu.
echo   %GG_% Setup%_%          : Open the setup menu.
echo   %GG_% Activate, Act%_%  : Activate the Right Click Folder Icon Tools.
echo   %GG_% Deactivate, Dct%_%: Deactivate the Right Click Folder Icon Tools.
echo.
goto Options-Input

:Setup                            
if /i "%setup%" EQU "Deactivate" set "setup_select=2" &goto Setup-Choice
if exist "%RCFI%\resources\deactivating.RCFI" set "Setup=Deactivate" &set "setup_select=2" &goto Setup-Choice
if exist "%RCFID%" (
	for /f "useback tokens=1,2 delims=:" %%S in ("%RCFID%") do set /a "InstalledRelease=%%T" 2>nul
	call :Setup-Update
	EXIT /B
) else echo.&echo.&echo.&set "setup_select=1" &goto Setup-Choice
echo.&echo.&echo.
Goto Setup-Options

:Setup-Update
set /a "CurrentRelease=%version:v0.=%"
if %CurrentRelease% GTR %InstalledRelease% echo Need to update!
EXIT /B

:Setup-Options                    
echo.&echo.
echo               %I_%     %name% %version%     %_%
echo.
echo            %G_%Activate or Deactivate Folder Icon Tools on Explorer Right Click menus
echo            %G_%Press %GN_%1%G_% to %W_%Activate%G_%, Press %GN_%2%G_% to %W_%Deactivate%G_%, Press %GN_%3%G_% to %W_%Exit%G_%.%bk_%
echo.&echo.
choice /C:123 /N
set "setup_select=%errorlevel%"

:Setup-Choice                     
if "%setup_select%"=="1" (
	echo %G_%Activating RCFI Tools%_%
	set "Setup_action=install"
	set "HKEY=HKEY"
	goto Setup_process
)
if "%setup_select%"=="2" (
	echo %G_%Deactivating RCFI Tools%_%
	set "Setup_action=uninstall"
	set "HKEY=-HKEY"
	goto Setup_process
)
if "%setup_select%"=="3" goto options
goto Setup-Options

:Setup_process                   
set "Setup_Write=%~dp0Setup_%Setup_action%.reg"
call :Setup_Writing
if not exist "%~dp0Setup_%Setup_action%.reg" goto Setup_error
echo %G_%Updating shell extension menu ..%_%
regedit.exe /s "%~dp0Setup_%Setup_action%.reg" ||goto Setup_error
del "%~dp0Setup_%Setup_action%.reg"

REM installing -> create "uninstall.bat"
if /i "%setup_select%"=="1" (
	echo PUSHD    "%%~dp0">"%RCFID%"
	echo set "Setup=Deactivate" ^&call "%name%" ^|^|pause^>nul :%version:v0.=%>>"%RCFID%"
	del /q "%RCFI%\#𝐏𝐀𝐒𝐒𝐖𝐎𝐑𝐃 𝟏𝟐𝟑𝟒" 2>nul
	echo %W_%%name% %version%  %CC_%Activated%_%
	echo %G_%Folder Icon Tools has been added to the right-click menus. %_%
	if not defined input (goto intro)
)

REM uninstalling -> delete "uninstall.bat"
if /i "%setup_select%"=="2" (
	del "%RCFI%\resources\deactivating.RCFI" 2>nul
	if exist "%RCFID%" del "%RCFID%"
	echo %W_%%name% %version%  %R_%Deactivated%_%
	echo %G_%Folder Icon Tools have been removed from the right-click menus.%_%
if /i "%Setup%"=="Deactivate" set "Setup=Deactivated"
)
if /i "%Setup%"=="Deactivated" %p5%&%p3%&exit
goto options

:Setup_error                      
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo            %R_%Setup fail.
echo            %W_%Permission denied.
set "setup="
set "context="
del "%RCFI%\Setup_%Setup_action%.reg" 2>nul
del "%RCFI%\resources\deactivating.RCFI" 2>nul
pause>nul&exit

:Setup_RegFix-Install
echo %G_%Changing REG key to be able to select more than 15 items.
echo %G_%MultipleInvokePromptMinimum: 1000%R_%

(
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
echo "MultipleInvokePromptMinimum"=dword:000003e8
)>>"%Setup_Write%"

echo %G_%Changing REG key to be able to retrieve shorcut icons from remote paths. 
echo %G_%ShellShortcutIconRemotePath: 1%R_%

(
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
echo "EnableShellShortcutIconRemotePath"=dword:00000001
)>>"%Setup_Write%"
exit /b

:Setup_RegFix-Uninstall
echo %G_%Reverting MultipleInvokePromptMinimum to default.%R_%
(
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
echo "MultipleInvokePromptMinimum"=dword:0000000f
)>>"%Setup_Write%"

echo %G_%Reverting ShellShortcutIconRemotePath to default.%R_%
(
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
echo "EnableShellShortcutIconRemotePath"=dword:00000000
)>>"%Setup_Write%"
exit /b

:Setup_Writing                    
echo %G_%Preparing registry entry ..%_%

rem Escaping the slash using slash
	set "curdir=%~dp0_."
	set "curdir=%curdir:\_.=%"
	set "curdir=%curdir:\=\\%"

rem Multi Select, Separate instance
	set cmd=cmd.exe /c
	set "RCFITools=%~f0"
	set "RCFITools=%RCFITools:\=\\%"
	set RCFIexe=^&call \"%RCFITools%\"
	set SCMD=\"%curdir%\\resources\\SingleInstanceAccumulator.exe\" \"-c:cmd /c
	set SRCFIexe=^^^&set xSelected=$files^^^&call \"\"%RCFITools%\"\"\"


rem Define registry root
	set RegExBG=%HKEY%_CLASSES_ROOT\Directory\Background\shell
	set RegExDir=%HKEY%_CLASSES_ROOT\Directory\shell
	set RegExImage=%HKEY%_CLASSES_ROOT\SystemFileAssociations\image\shell
	set RegExShell=%HKEY%_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell
	set RegExICNS=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.icns\shell
	set RegExSVG=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.svg\shell
	set RegExWEBP=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.webp\shell
	set RegExMKV=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.mkv\shell
	set RegExMP4=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.mp4\shell
	set RegExAVI=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.avi\shell
	set RegExSRT=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.srt\shell
	set RegExASS=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.ass\shell
	set RegExXML=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.xml\shell
	set RegExTS=%HKEY%_CLASSES_ROOT\SystemFileAssociations\.ts\shell


rem Generating setup_*.reg
(
	echo Windows Registry Editor Version 5.00

	:REG-FI-IMAGE-Set.As.Folder.Icon
	echo [%RegExShell%\RCFI.IMG-Set.As.Folder.Icon]
	echo "MUIVerb"="Set as folder icon"
	echo "Icon"="shell32.dll,-16805"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Set.As.Folder.Icon\command]
	echo @="%cmd% set \"Context=IMG-Set.As.Folder.Icon\"%RCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Choose.and.Set.As
	echo [%RegExShell%\RCFI.IMG-Choose.and.Set.As]
	echo "MUIVerb"="Choose and set as folder icon"
	echo "Icon"="shell32.dll,-270"
	echo [%RegExShell%\RCFI.IMG-Choose.and.Set.As\command]
	echo @="%cmd% set \"Context=IMG-Choose.and.Set.As\"%RCFIexe% \"%%1\""

	:REG-FI-IMAGE-Choose.Template
	echo [%RegExShell%\RCFI.IMG.Choose.Template]
	echo "MUIVerb"="Choose template"
	echo "Icon"="shell32.dll,-270"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG.Choose.Template\command]
	echo @="%cmd% set \"Context=IMG.Choose.Template\"%RCFIexe% \"%%1\""

	:REG-FI-IMAGE-Edit.Template
	echo [%RegExShell%\RCFI.IMG.Edit.Template]
	echo "MUIVerb"="Edit current template"
	echo "Icon"="imageres.dll,-102"
	echo [%RegExShell%\RCFI.IMG.Edit.Template\command]
	echo @="%SCMD% set \"Context=IMG.Edit.Template\"%SRCFIexe% \"%%1\""

	:REG-FI-IMAGE-Generate.Icon
	echo [%RegExShell%\RCFI.IMG.Generate.Icon]
	echo "MUIVerb"="Generate Icon"
	echo "Icon"="imageres.dll,-1003"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG.Generate.Icon\command]
	echo @="%SCMD% set \"Context=IMG.Generate.Icon\"%SRCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Generate.PNG
	echo [%RegExShell%\RCFI.IMG.Generate.PNG]
	echo "MUIVerb"="Generate PNG"
	echo "icon"="imageres.dll,-1003"
	echo [%RegExShell%\RCFI.IMG.Generate.PNG\command]
	echo @="%SCMD% set \"Context=IMG.Generate.PNG\"%SRCFIexe% \"%%1\""


	:REG-FI-IMAGE-Template.Samples
	echo [%RegExShell%\RCFI.IMG.Template.Samples]
	echo "MUIVerb"="Generate template samples"
	echo "Icon"="imageres.dll,-1003"
	echo [%RegExShell%\RCFI.IMG.Template.Samples\command]
	echo @="%cmd% set \"Context=IMG.Template.Samples\"%RCFIexe% \"%%1\""
		
	:REG-FI-IMAGE-Convert
	echo [%RegExShell%\RCFI.IMG-Convert]
	echo "MUIVerb"="Convert images"
	echo "Icon"="shell32.dll,-16826"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Convert\command]
	echo @="%SCMD% set \"Context=IMG-Convert\"%SRCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Resize
	echo [%RegExShell%\RCFI.IMG-Resize]
	echo "MUIVerb"="Resize images"
	echo "Icon"="shell32.dll,-16826"
	echo [%RegExShell%\RCFI.IMG-Resize\command]
	echo @="%SCMD% set \"Context=IMG-Resize\"%SRCFIexe% \"%%1\""

	:REG-FI-IMAGE-Compress
	echo [%RegExShell%\RCFI.IMG-Compress]
	echo "MUIVerb"="Compress images"
	echo "Icon"="shell32.dll,-16826"
	echo [%RegExShell%\RCFI.IMG-Compress\command]
	echo @="%SCMD% set \"Context=IMG-Compress\"%SRCFIexe% \"%%1\""

	REM Selected_Dir
	:REG-FI-Change.Folder.Icon
	echo [%RegExShell%\RCFI.Change.Folder.Icon]
	echo "MUIVerb"="Change folder icon"
	echo "Icon"="imageres.dll,-5303"
	echo [%RegExShell%\RCFI.Change.Folder.Icon\command]
	echo @="%cmd% set \"Context=Change.Folder.Icon\"%RCFIexe% \"%%V\""
	
	:REG-FI-Select.And.Change.Folder.Icon
	echo [%RegExShell%\RCFI.Select.And.Change.Folder.Icon]
	echo "MUIVerb"="Change folder icon"
	echo "Icon"="imageres.dll,-148"
	echo [%RegExShell%\RCFI.Select.And.Change.Folder.Icon\command]
	echo @="%Scmd% set \"Context=Select.And.Change.Folder.Icon\"%SRCFIexe% \"%%V\""
	
	:REG-FI.Search.Folder.Icon
	echo [%RegExShell%\RCFI.Search.Folder.Icon]
	echo "MUIVerb"="Search folder icon"
	echo "Icon"="shell32.dll,-251"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Search.Folder.Icon\command]
	echo @="%cmd% set \"Context=FI.Search.Folder.Icon\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Poster
	echo [%RegExShell%\RCFI.Search.Poster]
	echo "MUIVerb"="Search poster"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Poster\command]
	echo @="%cmd% set \"Context=FI.Search.Poster\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Logo
	echo [%RegExShell%\RCFI.Search.Logo]
	echo "MUIVerb"="Search logo"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Logo\command]
	echo @="%cmd% set \"Context=FI.Search.Logo\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Icon
	echo [%RegExShell%\RCFI.Search.Icon]
	echo "MUIVerb"="Search icon"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Icon\command]
	echo @="%cmd% set \"Context=FI.Search.Icon\"%RCFIexe% \"%%V\""

	:REG-FI.Search.Folder.Icon.Here
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here]
	echo "MUIVerb"="Search folder icon"
	echo "Icon"="shell32.dll,-251"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here\command]
	echo @="%cmd% set \"Context=FI.Search.Folder.Icon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh
	echo [%RegExShell%\RCFI.Refresh]
	echo "MUIVerb"="Refresh icon cache (restart explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh\command]
	echo @="%cmd% set \"Context=Refresh\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh-No.Restart
	echo [%RegExShell%\RCFI.RefreshNR]
	echo "MUIVerb"="Refresh icon cache (without restart)"
	echo "Icon"="shell32.dll,-16739"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RefreshNR\command]
	echo @="%cmd% set \"Context=RefreshNR\"%RCFIexe% \"%%V\""
	
	:REG-FI-Choose.Template
	echo [%RegExShell%\RCFI.DIR.Choose.Template]
	echo "MUIVerb"="Choose template"
	echo "Icon"="shell32.dll,-270"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.DIR.Choose.Template\command]
	echo @="%Scmd% set \"Context=DIR.Choose.Template\"%SRCFIexe% \"%RCFITools%\""
		
	:REG-FI-Scan
	echo [%RegExShell%\RCFI.Scan]
	echo "MUIVerb"="Scan"
	echo "Icon"="shell32.dll,-23"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Scan\command]
	echo @="%Scmd% set \"Context=Scan\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Define.Keyword
	echo [%RegExShell%\RCFI.DefKey]
	echo "MUIVerb"="Define keywords"
	echo "Icon"="shell32.dll,-242"
	echo [%RegExShell%\RCFI.DefKey\command]
	echo @="%Scmd% set \"Context=DefKey\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Keyword
	echo [%RegExShell%\RCFI.GenKey]
	echo "MUIVerb"="Generate from keywords"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey\command]
	echo @="%Scmd% set \"Context=GenKey\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG
	echo [%RegExShell%\RCFI.GenJPG]
	echo "MUIVerb"="Generate from *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenJPG\command]
	echo @="%Scmd% set \"Context=GenJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG
	echo [%RegExShell%\RCFI.GenPNG]
	echo "MUIVerb"="Generate from *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG\command]
	echo @="%Scmd% set \"Context=GenPNG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG
	echo [%RegExShell%\RCFI.GenPosterJPG]
	echo "MUIVerb"="Generate from *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG\command]
	echo @="%Scmd% set \"Context=GenPosterJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG
	echo [%RegExShell%\RCFI.GenLandscapeJPG]
	echo "MUIVerb"="Generate from *Landscape.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenLandscapeJPG\command]
	echo @="%Scmd% set \"Context=GenLandscapeJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Move
	echo [%RegExShell%\RCFI.Move]
	echo "MUIVerb"="Move icon"
	echo "Icon"="shell32.dll,-16784"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Move\command]
	echo @="%Scmd% set \"Context=Move\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Rename
	echo [%RegExShell%\RCFI.Rename]
	echo "MUIVerb"="Rename icon"
	echo "Icon"="shell32.dll,-16784"
	echo [%RegExShell%\RCFI.Rename\command]
	echo @="%Scmd% set \"Context=Rename\"%SRCFIexe% \"%%V\""	
	
	:REG-FI-Activate_Folder_Icon
	echo [%RegExShell%\RCFI.ActivateFolderIcon]
	echo "MUIVerb"="Activate/Deactivate folder icon"
	echo "Icon"="imageres.dll,-3"
	echo [%RegExShell%\RCFI.ActivateFolderIcon\command]
	echo @="%Scmd% set \"Context=ActivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Deactivate_Folder_Icon
	echo [%RegExShell%\RCFI.DeactivateFolderIcon]
	echo "MUIVerb"="Deactivate folder icons"
	echo "Icon"="imageres.dll,-4"
	echo [%RegExShell%\RCFI.DeactivateFolderIcon\command]
	echo @="%Scmd% set \"Context=DeactivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Remove_Folder_Icon
	echo [%RegExShell%\RCFI.RemFolderIcon]
	echo "MUIVerb"="Remove folder icon"
	echo "Icon"="shell32.dll,-145"
	echo [%RegExShell%\RCFI.RemFolderIcon\command]
	echo @="%Scmd% set \"Context=RemFolderIcon\"%SRCFIexe% \"%%V\""
	
	REM Background Dir
	:REG-FI-Refresh_here
	echo [%RegExShell%\RCFI.Refresh.Here]
	echo "MUIVerb"="Refresh icon cache (restart explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh.Here\command]
	echo @="%cmd% set \"Context=Refresh.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh_No_Restart_here
	echo [%RegExShell%\RCFI.RefreshNR.Here]
	echo "MUIVerb"="Refresh icon cache (without restart)"
	echo "Icon"="shell32.dll,-16739"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RefreshNR.Here\command]
	echo @="%cmd% set \"Context=RefreshNR.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Scan_here
	echo [%RegExShell%\RCFI.Scan.Here]
	echo "MUIVerb"="Scan"
	echo "Icon"="shell32.dll,-23"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Scan.Here\command]
	echo @="%cmd% set \"Context=Scan.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Define.Keyword.Here
	echo [%RegExShell%\RCFI.DefKey.Here]
	echo "MUIVerb"="Define keywords"
	echo "Icon"="shell32.dll,-242"
	echo [%RegExShell%\RCFI.DefKey.Here\command]
	echo @="%cmd% set \"Context=DefKey.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Keyword_here
	echo [%RegExShell%\RCFI.GenKey.Here]
	echo "MUIVerb"="Generate from keywords"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey.Here\command]
	echo @="%cmd% set \"Context=GenKey.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG_here
	echo [%RegExShell%\RCFI.GenJPG.Here]
	echo "MUIVerb"="Generate from *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenJPG.Here\command]
	echo @="%cmd% set \"Context=GenJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG_here
	echo [%RegExShell%\RCFI.GenPNG.Here]
	echo "MUIVerb"="Generate from *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG.Here\command]
	echo @="%cmd% set \"Context=GenPNG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG_here
	echo [%RegExShell%\RCFI.GenPosterJPG.Here]
	echo "MUIVerb"="Generate from *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG.Here\command]
	echo @="%cmd% set \"Context=GenPosterJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG_here
	echo [%RegExShell%\RCFI.GenLandscapeJPG.Here]
	echo "MUIVerb"="Generate from *Landscape.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenLandscapeJPG.Here\command]
	echo @="%cmd% set \"Context=GenLandscapeJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Move_here
	echo [%RegExShell%\RCFI.Move.Here]
	echo "MUIVerb"="Move icons"
	echo "Icon"="shell32.dll,-16784"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Move.Here\command]
	echo @="%cmd% set \"Context=Move.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Rename_here
	echo [%RegExShell%\RCFI.Rename.Here]
	echo "MUIVerb"="Rename icons"
	echo "Icon"="shell32.dll,-16784"
	echo [%RegExShell%\RCFI.Rename.Here\command]
	echo @="%cmd% set \"Context=Rename.Here\"%RCFIexe% \"%%V\""
			
	:REG-FI-Remove_Folder_Icon_here
	echo [%RegExShell%\RCFI.RemFolderIcon.Here]
	echo "MUIVerb"="Remove folder icons"
	echo "Icon"="shell32.dll,-145"
	echo [%RegExShell%\RCFI.RemFolderIcon.Here\command]
	echo @="%cmd% set \"Context=RemFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Activate_Folder_Icon_here
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here]
	echo "MUIVerb"="Activate/Deactivate folder icons"
	echo "Icon"="imageres.dll,-3"
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here\command]
	echo @="%cmd% set \"Context=ActivateFolderIcon.Here\"%RCFIexe% \"%%V\""

	:REG-FI-Deactivate
	echo [%RegExShell%\RCFI.Deactivate]
	echo "MUIVerb"="             Deactivate %name%"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Deactivate\command]
	echo @="%cmd% set \"Context=FI.Deactivate\"%RCFIexe%"		
	
	:REG-FI-Edit.Template
	echo [%RegExShell%\RCFI.Edit.Template]
	echo "MUIVerb"="Template configurations"
	echo "Icon"="imageres.dll,-69"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Edit.Template\command]
	echo @="%cmd% set \"Context=Edit.Template\"%RCFIexe%"
	
	:REG-FI-Edit.Config
	echo [%RegExShell%\RCFI.Edit.Config]
	echo "MUIVerb"="RCFI Tools configurations"
	echo "Icon"="imageres.dll,-69"
	echo [%RegExShell%\RCFI.Edit.Config\command]
	echo @="%cmd% set \"Context=Edit.Config\"%RCFIexe%"
	
	:REG-FI-More.Context
	echo [%RegExShell%\RCFI.More.Context]
	echo "MUIVerb"="More ...      %name% %version%"
	echo "Icon"="imageres.dll,-5323"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.More.Context\command]
	echo @="%cmd% set \"Context=More.Context\"%RCFIexe% \"%%V\""
	
	:REG-Context_Menu-FI-Folder
	echo [%RegExDir%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.Select.And.Change.Folder.Icon;RCFI.RefreshNR;RCFI.DIR.Choose.Template;RCFI.Scan;RCFI.DefKey;RCFI.GenKey;RCFI.GenJPG;RCFI.GenPNG;RCFI.Search.Folder.Icon;RCFI.Search.Poster;RCFI.Search.Icon;RCFI.Move;RCFI.Rename;RCFI.RemFolderIcon;RCFI.ActivateFolderIcon"
	
	:REG-Context_Menu-FI-Background
	echo [%RegExBG%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.RefreshNR.Here;RCFI.Refresh.Here;RCFI.DIR.Choose.Template;RCFI.Search.Folder.Icon.Here;RCFI.Scan.Here;RCFI.DefKey.Here;RCFI.GenKey.Here;RCFI.GenJPG.Here;RCFI.GenPNG.Here;RCFI.Move.Here;RCFI.Rename.Here;RCFI.RemFolderIcon.Here;RCFI.ActivateFolderIcon.Here;RCFI.Edit.Template;RCFI.Edit.Config;RCFI.More.Context;"
	
	:REG-Context_Menu-Images
	echo [%RegExImage%\RCFI.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG-Choose.and.Set.As;RCFI.IMG.Generate.Icon;RCFI.IMG.Generate.PNG;RCFI.IMG.Template.Samples;RCFI.IMG.Choose.Template;RCFI.IMG.Edit.Template;RCFI.IMG-Convert;RCFI.IMG-Compress;RCFI.IMG-Resize;"
	
	:REG-Context_Menu-Images-SVG
	echo [%RegExSVG%\RCFI.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG-Choose.and.Set.As;RCFI.IMG.Generate.Icon;RCFI.IMG.Generate.PNG;RCFI.IMG.Template.Samples;RCFI.IMG.Choose.Template;RCFI.IMG.Edit.Template;RCFI.IMG-Convert;RCFI.IMG-Compress;RCFI.IMG-Resize;"
	
	:REG-Context_Menu-Images-WEBP
	echo [%RegExWEBP%\RCFI.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG-Choose.and.Set.As;RCFI.IMG.Generate.Icon;RCFI.IMG.Generate.PNG;RCFI.IMG.Template.Samples;RCFI.IMG.Choose.Template;RCFI.IMG.Edit.Template;RCFI.IMG-Convert;RCFI.IMG-Compress;RCFI.IMG-Resize;"
	
)>"%Setup_Write%"
if "%setup_select%"=="1" call :Setup_RegFix-Install
if "%setup_select%"=="2" call :Setup_RegFix-Uninstall
EXIT /B
