@echo off
:: Update v0.3
:: 2024-06-22 Fix: The star image was rendered in the generated folder icon even when the “.nfo” file didn’t exist.
:: 2024-06-23 Add "Global Template Config" to override all templates configuration.
:: 2024-06-24 Adding some adjustment to "Windows 11 A" template.

setlocal
set name=RCFI Tools
set version=v0.2
chcp 65001 >nul
cd /d "%~dp0"
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
if not defined OpenFrom (
	echo                             %i_% %name% %version% %_%%-%
	echo.
	echo                %gn_%Activate%g_%/%gn_%Act%g_%   to activate Folder Icon Tools.
	echo                %gn_%Deactivate%g_%/%gn_%Dct%g_% to deactivate Folder Icon Tools. 
	echo.
) else (
echo %TAB%                  %pp_%Drag and  drop%_%%g_%  an %c_%image%g_%  to  this  window
echo %TAB%                  then press Enter to change the folder icon.%_%
echo.
)
goto Options-Input

:Status                           
%p1%
echo   %_%------- Status ----------------------------------------
echo   Directory           :%ESC%%u_%%cd%%-%%ESC%
echo   Target Folder Icon  : %KeywordsPrint%
if exist "%Template%" ^
echo   Folder Icon Template:%ESC%%cc_%%templatename%%_%%ESC%
if not exist "%Template%" ^
echo   Folder Icon Template: %r_%%i_% Not Found! %ESC%%r_%%u_%%Template%%ESC%
echo   %_%-------------------------------------------------------
goto Options-Input

:Options                          
echo.&echo.&echo.&echo.
set "Already="
set "referer="
if defined timestart call :timer-end
set "timestart="
if /i "%Context%"=="refresh.NR" exit
if defined Context (
	if %exitwait% GTR 99 (
		echo.&echo.
		echo %TAB%%g_%%processingtime% Press Any Key to Close this window.
		endlocal
		pause>nul&exit
	)
	echo. &echo.
	if /i "%input%"=="Scan" (
		echo %TAB%%TAB%%g_%%processingtime% Press any key to close this window.
		endlocal
		pause >nul &exit
	)
	if /i "%cdonly%"=="true" (
		echo %TAB%%g_%%processingtime% This window will close in %ExitWait% sec.
		endlocal
		ping localhost -n %ExitWait% >nul&exit
	)
	if /i "%input%"=="Generate" (
		echo %TAB%%TAB%%g_%%processingtime% Press any key to close this window.
		endlocal
		pause >nul &exit
	)
	echo %TAB%%g_%%processingtime% This window will close in %ExitWait% sec.
	endlocal
	ping localhost -n %ExitWait% >nul&exit
)

:Options-Input                    
rem if not defined OpenFrom echo %_%%GG_%Keywords%G_%^|%GG_%Scan%G_%^|%GG_%Template%G_%^|%GG_%Generate%G_%^|%GG_%Refresh%G_%^|%GG_%RefreshFc%G_%^|%GG_%Search%G_%^|%GG_%ON%G_%^|^
rem %GG_%OFF%G_%^|%GG_%Remove%G_%^|%GG_%Config%G_%^|%GG_%Setup%G_%^|%GG_%RCFI%G_%^|%GG_%O%G_%^|%GG_%S%G_%^|%GG_%Help%G_%^|..
if defined OpenFrom if /i not "%TemplateAlwaysAsk%"=="yes" echo %g_%Template:%ESC%%cc_%%TemplateName%%ESC%
echo %g_%--------------------------------------------------------------------------------------------------
title %name% %version%   "%cd%"
call :Config-Save
call :Config-UpdateVar
call :Config-Load

:Input-Command                    
for %%F in ("%cd%") do set "FolderName=%%~nxF"
if not defined OpenFrom set "FolderName=%cd%"
set "Command=(none)"
set /p "Command=%_%%w_%%FolderName%%_%%gn_%>"
set "Command=%Command:"=%"
echo %-% &echo %-% &echo %-%
if /i "%Command%"=="keyword"		goto FI-Keyword
if /i "%Command%"=="keyword:"	goto Status
if /i "%Command%"=="ky"			goto FI-Keyword
if /i "%Command%"=="key"			goto FI-Keyword
if /i "%Command%"=="scan"		set "recursive=no"		&goto FI-Scan
if /i "%Command%"=="sc"			set "recursive=no"		&goto FI-Scan
if /i "%Command%"=="scans"		set "recursive=yes"		&goto FI-Scan
if /i "%Command%"=="scs"			set "recursive=yes"		&goto FI-Scan
if /i "%Command%"=="generate"	set "recursive=no"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="gn"			set "recursive=no"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="generates"	set "recursive=yes"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="gns"			set "recursive=yes"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%Command%"=="Remove"		set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%Command%"=="Rm"			set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%Command%"=="on"			set "refreshopen=index"	&goto FI-Activate
if /i "%Command%"=="off"			set "refreshopen=index"	&goto FI-Deactivate
if /i "%Command%"=="copy"			goto CopyFolderIcon
if /i "%Command%"=="refresh"		echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%Command%"=="refreshforce"	echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=Refresh"	&start "" "%~f0" &goto options
if /i "%Command%"=="rf"			echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%Command%"=="rff"			echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=Refresh"		&start "" "%~f0" &goto options
if /i "%Command%"=="template"	set "refer=Choose.Template"&goto FI-Template
if /i "%Command%"=="template:"	goto Status 
if /i "%Command%"=="tp"			set "refer=Choose.Template"&goto FI-Template
if /i "%Command%"=="Tes"			goto FI-Template-Sample
if /i "%Command%"=="s"			goto Status
if /i "%Command%"=="help"		goto Help
if /i "%Command%"=="cd.."		cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"==".."			cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"=="o"			echo %TAB%%_% Opening..   &echo %TAB%%ESC%%i_%%cd%%ESC% &explorer.exe "%cd%" &goto options
if /i "%Command%"=="RCFI"		echo %TAB%%_% Opening..   &echo %TAB%%ESC%%i_%%~dp0%ESC% &echo. &explorer.exe "%~dp0" &goto options
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
set Dir=cd /d "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls
echo. &echo. &echo.
REM Selected Image
if /i "%Context%"=="IMG-Actions"				goto IMG-Actions
if /i "%Context%"=="IMG-Set.As.Folder.Icon"	cd /d "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput
if /i "%Context%"=="IMG-Choose.and.Set.As"		cd /d "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput
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
if /i "%Context%"=="GenKey"						set "input=Generate"&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenJPG"						set "input=Generate"&set "Keywords=.jpg"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenPNG"						set "input=Generate"&set "Keywords=.png"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenPosterJPG"				set "input=Generate"&set "Keywords=Poster.jpg"	&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="GenLandscapeJPG"			set "input=Generate"&set "Keywords=Landscape.jpg"&call :Config-UpdateVar&set "cdonly=true"&goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon"		set "RefreshOpen=Select"&goto FI-Activate
if /i "%Context%"=="DeactivateFolderIcon"		set "RefreshOpen=Select"&goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon"				set "delete=confirm"&set "cdonly=true"		&goto FI-Remove
REM Background Dir	                         	
if /i "%Context%"=="DIRBG.Choose.Template"		set "refer=Choose.Template"		&goto FI-Template
if /i "%Context%"=="Scan.Here"					%Dir% &set "input=Scan" 			&goto FI-Scan
if /i "%Context%"=="GenKey.Here"				%Dir% &set "input=Generate"		&set "cdonly=false" 		&goto FI-Generate
if /i "%Context%"=="GenJPG.Here"				%Dir% &set "input=Generate"		&set "Keywords=.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPNG.Here"				%Dir% &set "input=Generate"		&set "Keywords=.png"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPosterJPG.Here"			%Dir% &set "input=Generate"		&set "Keywords=Poster.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenLandscapeJPG.Here"		%Dir% &set "input=Generate"		&set "Keywords=Landscape.jpg"&call :Config-UpdateVar&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon.Here"	%Dir% &goto FI-Activate
if /i "%Context%"=="DeactivateFolderIcon.Here" %Dir% &goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon.Here"		%Dir% &set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%Context%"=="Edit.Config"				start "" notepad.exe "%RCFI%\RCFI.config.ini"&exit
if /i "%Context%"=="Edit.Template"				goto FI-Template-Edit
if /i "%Context%"=="Ver.Context.Click"			echo %TAB%%_%Opening..   		&echo %TAB%%i_%%~dp0%-% &echo. &explorer.exe "%~dp0" &exit
REM Other
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error


:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%
echo.
if defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Command%%_%
echo.
echo %TAB%%g_%The command, file path, or directory path is unavailable. 
rem echo %TAB%Use %gn_%Help%g_% to see available commands.
goto options

:DirectInput                      
set "cdonly=true"
PUSHD "%input%" 2>nul &&goto directInput-folder ||goto directInput-file
POPD&goto options
:DirectInput-Folder               
cd /d "%input%"
echo %TAB% Changing directory
echo %TAB%%ESC%%i_%%input%%-%
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
echo %TAB%%r_%File format not supported.%-%
echo %TAB%%g_%^(supported file: %ImageSupport%^)
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
if not exist "%iconresource%" (
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	goto DirectInput-Generate-Confirm
)
echo %TAB%%Y_%┌%Y_%📁%ESC%%w_%%foldername%%ESC%
echo %TAB%%Y_%└%Y_%🏞%ESC%%y_%%iconresource%%ESC%
attrib -s -h "%iconresource%"
attrib |exit /b
echo %TAB%%g_% This folder already has a folder icon.
echo %TAB%%g_% Do you want to replace it%r_%^? %gn_%Y%_%/%gn_%N%bk_%
echo %TAB%%g_% Press %gg_%Y%g_% to confirm.%_%%bk_%
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="1" (
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
)
IF "%ERRORLEVEL%"=="2" (
	echo %_%%TAB% %I_%     Canceled     %_%
	Attrib %Attrib% "%iconresource%"
	attrib -|exit /b
	goto options
)
IF "%ERRORLEVEL%"=="1" if defined Context cls &echo.&set "Direct=Confirm"&echo.&echo.&echo.&echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 

:DirectInput-Generate-Confirm     
set "ReplaceThis=%iconresource%"
attrib -s -h "%filepath%%filename%"
attrib |exit /b
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
rem echo %TAB%              %cc_%%i_%          Done!          %_%
echo.&echo.&echo.
goto FI-Selected_folder

:FI-Selected_folder-Get
echo %TAB%%i_%  Change folder icon for selected folders.  %_%
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
echo %TAB%%g_%Template:%ESC%%cc_%%TemplateName%%ESC%
echo.
echo %g_% %g_%Press %gn_%1%g_% then hit Enter to change them separatly in each different window.%_%
exit /b

:FI-Selected_folder-Input
set "referer="
if not exist "%input%" echo  %g_%To enter the image path you can drag and drop the image here, then press Enter. ^
 &echo %g_%------------------------------------------------------------------------------- ^
 &set /p "Input=%_%%w_%Enter the image path:%_%%c_%"
set "Input=%Input:"=%"
if "%input%"=="1" goto FI-Selected_folder-Separate
echo.
if not exist "%Input%" (
	echo.
	echo.
	echo %TAB% %_%Invalid path.
	echo %TAB%%ESC%%r_%%i_%%input%%ESC%
	echo %TAB% %g_%Make sure to enter a valid file path.%_%
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
		echo %g_%-------------------------------------------------------------------------------
		set "iconresource="
		exit /b
	)
)
echo.
echo %TAB% %r_%File format not supported.%-%
echo %TAB% %g_%^(supported file: %ImageSupport%^)
echo.
set "input="
call :FI-Selected_folder-input
exit /b

:FI-Selected_folder-Act
if not defined iconresource (
	if not defined timestart call :Timer-start
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
	exit /b
) else if not exist "%iconresource%" (
	echo %TAB%%W_%┌%Y_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
)
if /i "%replace%"=="all" (
	set "ReplaceThis=%iconresource%"
	if not defined timestart call :Timer-start
	echo %TAB%%W_%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
	call :FI-Generate-Folder_Icon
	exit /b
)
if not exist "%iconresource%" (
	if not defined timestart call :Timer-start
	call :FI-Generate-Folder_Icon
	exit /b
)
echo %TAB%%Y_%┌%Y_%📁%ESC%%w_%%foldername%%ESC%
echo %TAB%%Y_%└%Y_%🏞%ESC%%y_%%iconresource%%ESC%
attrib -s -h "%iconresource%"
attrib |exit /b
echo %TAB%%g_% This folder already has a folder icon.
echo %TAB%%g_% Do you want to replace it%r_%^? %gn_%A%_%/%gn_%Y%_%/%gn_%N%bk_%
echo %TAB%%g_% Press %gg_%Y%g_% to confirm.%_%%g_% Press %gg_%A%g_% to confirm all.%bk_%
CHOICE /N /C AYN
IF "%ERRORLEVEL%"=="1" set "replace=all"
IF "%ERRORLEVEL%"=="3" (
	echo %g_%%TAB% %I_%    Skip    %_%
	Attrib %Attrib% "%iconresource%"
	attrib -|exit /b
	set "iconresource="
	exit /b
)
set "ReplaceThis=%iconresource%"
if not defined timestart call :Timer-start
echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
call :FI-Generate-Folder_Icon
exit /b


:FI-Selected_folder-Separate
for %%S in (%xSelected%) do (
	PUSHD "%%~fS" 2>nul &&(
		start "" cmd.exe /c set "Context=Change.Folder.Icon"^&call "%~f0" "%%~fS"
	)
	POPD
)
exit


:FI-Scan                          
set  "y_result=0"
set  "g_result=0"
set  "r_result=0"
set  "h_result=0"
set "yy_result=0"
set "success_result=0"
set "fail_result=0"
set  "Y_d=1"
set  "G_d=1"
set  "R_d=1"
set "YY_d=1"
echo %TAB%%TAB%%cc_%%i_%  Scanning Folders.. %-%
Echo %TAB%Keywords  : %KeywordsPrint%
echo %TAB%Directory :%ESC%%cd%%ESC%
echo %TAB%%w_%==============================================================================%_%
call :timer-start
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
set /a "hy_result=%yy_result%-%h_result%"
echo.
echo.

IF /i %result%		LSS 10 (set "s=   "		) else (IF /i %result%		GTR 9 set "s=  "		&IF /i %result%		GTR 99	set "s= "		&IF /i %result%		GTR 999 set "s="	)
IF /i %R_result%		LSS 10 (set "R_s=   "		) else (IF /i %R_result%		GTR 9 set "R_s=  "	&IF /i %R_result%		GTR 99	set "R_s= "	&IF /i %R_result%		GTR 999 set "R_s="	)		
IF /i %Y_result%		LSS 10 (set "Y_s=   "		) else (IF /i %Y_result%		GTR 9 set "Y_s=  "	&IF /i %Y_result%		GTR 99 set "Y_s= "	&IF /i %Y_result%		GTR 999 set "Y_s="	)		
IF /i %G_result%		LSS 10 (set "G_s=   "		) else (IF /i %G_result%		GTR 9 set "G_s=  "	&IF /i %G_result%		GTR 99 set "G_s= "	&IF /i %G_result%		GTR 999 set "G_s="	)		
IF /i %YY_result%		LSS 10 (set "YY_s=   "	) else (IF /i %YY_result%		GTR 9 set "YY_s=  "	&IF /i %YY_result%	GTR 99 set "YY_s= "	&IF /i %YY_result%	GTR 999 set "YY_s="	)
IF /i %H_result%		LSS 10 (set "H_s=   "	)	else (IF /i %H_result%		GTR 9 set "H_s=  "	&IF /i %H_result%	GTR 99 set "H_s= "	&IF /i %H_result%	GTR 999 set "H_s="	)

echo %TAB%%s%%u_%%result% Folders found.%_%
IF /i %YY_result%		GTR 0 IF NOT %hy_result% EQU 0 echo %TAB%%yy_%%YY_s%%HY_result%%_% Folders can be processed.
IF /i %h_result%		GTR 0 echo %TAB%%rr_%%H_s%%H_result%%_% Folders can't be processed.
IF /i %R_result%		GTR 0 echo %TAB%%r_%%R_s%%R_result%%_% Folder's icons are missing and can be changed.
IF /i %Y_result%		GTR 0 echo %TAB%%y_%%Y_s%%Y_result%%_% Folders already have an icon.
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% Folders have no files matching the keywords.
IF /i %YY_result%		LSS 1 echo.&echo %TAB% Couldn't find any files matching the keywords. No folder icons to be generated.
echo.
set "result=0" &goto options


:FI-GetDir                        
set "locationCheck=Start"
REM Current dir only
if /i "%cdonly%"=="true" (
	FOR %%D in (%xSelected%) do (
		set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
			call :FI-Scan-Desktop.ini
	)
	EXIT /B
)
REM All inside current dir including subfolders
if /i "%Recursive%"=="yes" (
	FOR /r %%D in (.) do (
		set "location=%%D" &set "folderpath=%%~dpD" &set "foldername=%%~fD"
		call :FI-Scan-Desktop.ini
	)
	EXIT /B
)
REM All inside current dir only
FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
	set "location=%%~fD" &set "folderpath=%%~dpD" &set "foldername=%%~nxD"
		call :FI-Scan-Desktop.ini
)
EXIT /B

:FI-Scan-Display_Result           
if not defined Selected (
	set "Selected=%Filename%" 
	echo   %ESC%%W_%└%C_%🏞 %c_%%Filename%%ESC%
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
set    Y_FolderDisplay=echo %TAB%%Y_%%Y_s%📁%ESC%%_%%foldername%%ESC%
set    G_FolderDisplay=echo %TAB%%G_%%G_s%📁%ESC%%_%%foldername%%ESC%
set    R_FolderDisplay=echo %TAB%%W_%%R_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
set   YY_FolderDisplay=echo %TAB%%W_%%YY_s%┌%YY_%📁%ESC%%YY_%%foldername%%ESC% 
if /i "%referer%"=="MultiFolderRightClick" (
	set    R_FolderDisplay=echo %TAB%%W_%%R_s%%RR_%📁%ESC%%_%%foldername%%ESC%
	set   YY_FolderDisplay=echo %TAB%%W_%%YY_s%%YY_%📁%ESC%%_%%foldername%%ESC% 
)

PUSHD "%location%"
	
	set "IconResource="
	if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do set "%%C=%%D"
	if not defined IconResource (
		for %%F in (%KeywordsFind%) do (
			for %%X in (%ImageSupport%) do (
				if /i "%%X"=="%%~xF" (
					if exist "desktop.ini" (
					REM "Access denied" if i put it up there, idk why?
						attrib -s -h "desktop.ini"
						attrib |EXIT /B
						copy "desktop.ini" "desktop.backup.ini" >nul||echo %TAB%     %r_%%i_% copy fail! %-%
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
					POPD&EXIT /B
				)
			)
		)
		REM %G_n%
		%G_FolderDisplay%
		set /a G_result+=1
		set "newline=yes"
		POPD&EXIT /B
	)
	
	if exist "desktop.ini" if not exist "%iconresource%" (
		for %%F in (%KeywordsFind%) do (
			for %%X in (%ImageSupport%) do (
				if /i "%%X"=="%%~xF" (
					%R_n%
					%R_FolderDisplay%
					set /a R_result+=1
					if /i not "%referer%"=="MultiFolderRightClick" (
						echo %TAB%%w_%│%R_%🏞%ESC%%_%%iconresource% %g_%(file not found!)%ESC%
						echo %TAB%%w_%│%G_%This folder previously had a folder icon, but the icon file is missing.%_%
						echo %TAB%%w_%│%G_%The icon will be replaced with the selected image.%_%
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
					POPD&EXIT /B
				)
			)
		)
	REM %G_n%
	%G_FolderDisplay%
	set /a G_result+=1
	POPD&EXIT /B
	)
	
	if exist "desktop.ini" if exist "%iconresource%" (
		REM %Y_n%
		%Y_FolderDisplay%
		set /a Y_result+=1
	)
	
	set "iconresource="
	if /i "%Context%"=="Create" (
		for %%F in (%KeywordsFind%) do (echo.&echo.&echo %r_%%TAB%   Something when wrong^?. :/  &pause>nul)
	)
POPD&EXIT /B

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
set "success_result=0"
set "fail_result=0"

	echo %TAB%%TAB%%w_%%i_%  Generating folder icon..  %-%
	echo.
	echo %TAB%Keyword   :%ESC%%KeywordsPrint%%ESC%
	if exist "%Template%" for %%T in ("%Template%") do (
	echo %TAB%Template  :%ESC%%cc_%%%~nT%ESC% 
	)
	echo %TAB%Directory :%ESC%%cd%%ESC%
	echo %TAB%%w_%==============================================================================%_%
if /i "%TemplateAlwaysAsk%"=="Yes" call :FI-Template-AlwaysAsk
call :timer-start
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
set /a "action_result=%r_result%+%success_result%+%fail_result%"
if /i "%cdonly%"=="true" if %success_result% EQU 1 goto options
if /i "%cdonly%"=="true" if %result% EQU 1 if %y_result% EQU 1 (
	echo.&echo.&echo.
	echo %TAB%%ESC%%y_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%w_%Folder already has an icon. 
	echo %TAB%Remove it first.%_% 
	echo.&echo.&echo.
)
if /i "%cdonly%"=="true" if %result% EQU 1 if %g_result% EQU 1 (
	echo.&echo.&echo.
	echo %TAB%%ESC%%g_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%w_%Couldn't find any files matching the keywords.
	echo.&echo.&echo.
)
echo.
echo.
IF /i %result%			LSS 10 (set "s=   "		) else (IF /i %result%		GTR 9 set "s=  "		&IF /i %result%		GTR 99	set "s= "		&IF /i %result%		GTR 999 set "s="	)
IF /i %R_result%			LSS 10 (set "R_s=   "		) else (IF /i %R_result%		GTR 9 set "R_s=  "	&IF /i %R_result%		GTR 99	set "R_s= "	&IF /i %R_result%		GTR 999 set "R_s="	)		
IF /i %Y_result%			LSS 10 (set "Y_s=   "		) else (IF /i %Y_result%		GTR 9 set "Y_s=  "	&IF /i %Y_result%		GTR 99 set "Y_s= "	&IF /i %Y_result%		GTR 999 set "Y_s="	)		
IF /i %G_result%			LSS 10 (set "G_s=   "		) else (IF /i %G_result%		GTR 9 set "G_s=  "	&IF /i %G_result%		GTR 99 set "G_s= "	&IF /i %G_result%		GTR 999 set "G_s="	)		
IF /i %YY_result%			LSS 10 (set "YY_s=   "	) else (IF /i %YY_result%		GTR 9 set "YY_s=  "	&IF /i %YY_result%	GTR 99 set "YY_s= "	&IF /i %YY_result%	GTR 999 set "YY_s="	)		
IF /i %fail_result%		LSS 10 (set "fail_s=   "	) else (IF /i %fail_result%	GTR 9 set "fail_s=  "	&IF /i %fail_result%	GTR 99 set "fail_s= "	&IF /i %fail_result%	GTR 999 set "fail_s="	)
IF /i %success_result%	LSS 10 (set "success_s=   ") else (IF /i %success_result% GTR 9 set "success_s=  " &IF /i %success_result% GTR 99 set "success_s= " &IF /i %success_result% LSS 999 set "success_s="	)

echo %TAB%%s%%u_%%result% Folders found.%_%
IF NOT "%YY_result%"=="%success_result%" IF %YY_result% GTR 0 IF %r_result% GTR 0 echo %TAB%%yy_%%YY_s%%YY_result%%_% Folders processed.
IF /i %R_result%		GTR 0 echo %TAB%%r_%%R_s%%R_result%%_% Folders icon changed.
IF /i %Y_result%		GTR 0 echo %TAB%%y_%%Y_s%%Y_result%%_% Folders already have an icon.
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% Folders have no files matching the keywords.
IF /i %YY_result%		LSS 1 IF /i %success_result%	LSS 1 echo.&echo %TAB% ^(No folders to be processed.^)
IF NOT "%YY_result%"=="%success_result%" IF %action_result% EQU 0 echo %TAB% ^(No files to be processed.^)
IF /i %fail_result%	GTR 0 echo %TAB%%fail_s%%r_%%fail_result%%_% Folder icons failed to generate.
IF /i %success_result%	GTR 1 echo %TAB%%success_s%%cc_%%success_result%%_% Folder icons generated. 
echo %TAB%------------------------------------------------------------------------------
goto options

:FI-Generate-Folder_Icon          
if not defined Selected call :FI-ID
if not defined Selected (
	if not defined Context (
		set "InputFile=%filepath%%filename%" &set "OutputFile=%cd%\foldericon(%FI-ID%).ico"
		) else (
			set "InputFile=%filepath%%filename%" &set "OutputFile=%filepath%foldericon(%FI-ID%).ico"
			)
	)
if not defined Selected (
	
	rem Removing READ ONLY attribute, hopfully it will refresh folder icon 
	rem when it re added later "(?)"
	
	attrib -r "%cd%"
	attrib |exit /b
	
	rem Display "template" and "selected image"
	set "Selected=%Filename%" 
	echo   %ESC%%W_%└%C_%🏞 %c_%%Filename%%ESC%
	if /i "%cdonly%"=="true" echo %TAB%%ESC%Template    : %cc_%%TemplateName%%ESC%%r_%
	rem Executing "specified template" to convert and edit the selected image
	if /i "%fileExt%"==".ICO" if exist "%TemplateForICO%" (
		for %%T in ("%TemplateForICO%") do echo %TAB%%ESC%%g_%Image extension is %c_%.ico%g_%, TemplateForICO: %cc_%%%~nT%g_%.%ESC%%r_%
		call "%TemplateForICO%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForICO" Fail to generate icon.
		)
	if /i "%fileExt%"==".PNG" if exist "%TemplateForPNG%" (
		for %%T in ("%TemplateForPNG%") do echo %TAB%%ESC%%g_%Image extension is %c_%.png%g_%, TemplateForPNG: %cc_%%%~nT%g_%.%ESC%%r_%
		call "%TemplateForPNG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForPNG" Fail to generate icon.
		)
	if /i "%fileExt%"==".JPG" if exist "%TemplateForJPG%" (
		for %%T in ("%TemplateForJPG%") do echo %TAB%%ESC%%g_%Image extension is %c_%.jpg%g_%, TemplateForJPG: %cc_%%%~nT%g_%.%ESC%%r_%
		call "%TemplateForJPG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForJPG" Fail to generate icon.
		)
	if /i "%fileExt%"==".JPEG" if exist "%TemplateForJPG%" (
		for %%T in ("%TemplateForJPG%") do echo %TAB%%ESC%%g_%Image extension is %c_%.jpg%g_%, TemplateForJPG: %cc_%%%~nT%g_%.%ESC%%r_%
		call "%TemplateForJPG%"
		if not exist "%OutputFile%" echo %TAB%"TemplateForJPG" Fail to generate icon.
		)
	
	rem Executing "general template" to convert and edit the selected image
	if not exist "%OutputFile%" call "%Template%"
	
	rem Check icon size, if icon size is less then 10kB then it's fail.
	if exist "foldericon(%FI-ID%).ico" for %%S in ("foldericon(%FI-ID%).ico") do (
		if %%~zS GTR 200 echo %TAB%%ESC%%g_%Convert success - foldericon(%FI-ID%).ico (%%~zS Bytes)%ESC%%r_%
		if %%~zS LSS 200 (
			echo %r_%"%Filename%"
			echo %r_%Convert error. Icon is less than 200 Bytes. -^> "foldericon(%FI-ID%).ico"%ESC%%g_%(%pp_%%%~zS Bytes%g_%)%ESC% 
			echo %r_%Deleting "foldericon(%FI-ID%).ico" ..
			del "foldericon(%FI-ID%).ico" >nul
			)
		)
	
	rem Create desktop.ini
	if exist "foldericon(%FI-ID%).ico" (
		echo  %g_%%TAB%%g_%Applying resources and attributes..%r_%
		if exist "desktop.ini" attrib -s -h "desktop.ini" &attrib |exit /b
		>Desktop.ini	echo ^[.ShellClassInfo^]
		>>Desktop.ini	echo IconResource=foldericon^(%FI-ID%^).ico
		>>Desktop.ini	echo ^;Folder Icon generated using %name% %version%.
	) else (echo %r_%%i_%Convert failed. %_%&set /a "fail_result+=1")
	
	rem Hiding "desktop.ini", "foldericon.ico" and adding READ ONLY attribute to folder
	if exist "desktop.ini" if exist "foldericon(%FI-ID%).ico" (
		ren "Desktop.ini" "desktop.ini.temp"
		ren "desktop.ini.temp" "desktop.ini"
		Attrib %Attrib% "desktop.ini"
		Attrib %Attrib% "foldericon(%FI-ID%).ico"
		attrib +r "%cd%"
		attrib |exit /b 
		set /a "success_result+=1"
		if defined ReplaceThis if exist "%ReplaceThis%" for %%R in ("%ReplaceThis%") do (
			attrib "%ReplaceThis%" -s -h
			attrib |exit /b
			if /i "%%~dpR"=="%cd%\" if /i "%%~xR"==".ico" del "%ReplaceThis%">nul&set "ReplaceThis="
		)
		if /i "%DeleteOriginalFile%"=="yes" del "%InputFile%"&&echo %TAB%%g_% "%FileName%" deleted.
		echo %TAB% %i_%%g_%  Success!  %-%
	)
)
EXIT /B

:FI-Generate-Get_Template         
call :Config-Load
if not exist "%Template%" (
	echo.
	echo %TAB% %w_%Couldn't load template.
	echo %TAB%%ESC%%r_%%Template%%ESC%
	echo %TAB% %i_%%r_%File not found.%-%
	goto options
)
EXIT /B


:FI-Template-AlwaysAsk             
if /i "%Already%"=="Asked" exit /b
if /i not "%Context%"=="Edit.Template" echo.&echo.&echo %TAB%  %w_%Choose Template to Generate Folder Icons:%_%
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
	echo %TAB%%TAB%%gn_% A%_%  %w_%Global Template Configuration%_%
)
echo.
echo %g_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
call :FI-Template-Input
set "Already=Asked"
exit /b

:FI-Template                      
title %name% %version% ^| Template
if /i not	"%referer%"=="FI-Generate" if defined Context cls &echo.&echo.&echo.&echo.
if /i		"%referer%"=="FI-Generate" echo.&echo %TAB%  %w_%Choose Template to Generate Folder Icons:%_%&echo %TAB% %g_%^(This will not be saved to the configurations^)%_%
if /i not	"%referer%"=="FI-Generate" (
echo %TAB%%TAB%%i_%%cc_%     Template     %-%
echo.
)
rem Show current template and descriptions
if /i not "%referer%"=="FI-Generate" (
	for %%I in ("%Template%") do (
		set "TName=%%~nI"
		echo %TAB%%w_%%u_%Current Template%_%:%ESC%%cc_%%%~nI%ESC%
		for /f "usebackq tokens=1,2 delims=`" %%I in ("%Template%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
		echo %TAB%%_%
		echo.
	)
)
rem Get template list options
if /i not	"%referer%"=="FI-Generate" ( 
	echo.
	echo %TAB%%TAB%%w_%%u_%     Options     %-%
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
	echo %TAB%%TAB%%gn_% S%_% ^> %w_%See all sample icons, using:%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
) else (
	echo.
	echo %TAB%%TAB%%gn_% S%_% ^> %w_%See all sample icons%_%
)
echo.
echo %g_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
call :FI-Template-Input
goto options


:FI-Template-Input                
rem Input template options
set "TemplateChoice=NotSelected"
set /p "TemplateChoice=%_%%w_%%TAB%%TAB%Select option:%_%%gn_%"

if /i "%TemplateChoice%"=="NotSelected" echo %_%%TAB%   %i_%  CANCELED  %-%&%p2%&goto options
if /i "%TemplateChoice%"=="r" cls&echo.&echo.&echo.&goto FI-Template
if /i "%TemplateChoice%"=="a" set "template=%RCFI.templates.ini%"&exit /b
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
	if not exist "%Template%" echo    %r_%"%Template%" %i_%Not found.%-%
	echo %_%%TAB%   %i_%%g_%  Invalid selection.  %-% 
	echo %TAB%%g_%   The Options are beetween %gg_%1%g_% to %gg_%%TCount%%g_% only.
	echo.
	goto FI-Template-Input
)
call :Config-UpdateVar
exit /b

:FI-Template-Get_List             
if /i "%Tselector%"=="GetList" if "%TemplateName%"=="%TName%" (set TNameList=%ESC%%cc_%%TName%%_%%ESC%) else set TNameList=%ESC%%_%%TName%%_%%ESC%
if /i "%Tselector%"=="GetList" (
	if %TCount% LSS 10 echo %TAB%     %gn_%%TCount%%w_%%TNameList%
	if %TCount%   GTR 9 echo %TAB%    %gn_%%TCount%%w_%%TNameList%
	exit /b
	)
set "_info="
if /i "%TSelector%"=="Select" (
		if /i not "%TCount%"=="%TemplateChoice%" exit /b
		set "Template=%TFullPath%"
		if "%refer%"=="Choose.Template" (cls &echo.&echo.&echo.&echo.)	
		if /i "%TemplateAlwaysAsk%"=="yes" (
			if /i "%refer%"=="Choose.Template" (
				echo.
				echo   %_%%ESC%%cc_%  %TName%%_% selected.%ESC%
				%p1%
				for /f "usebackq tokens=1,2 delims=`" %%I in ("%TFullPath%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
				%p2%
				set "TemplateChoice=Selected"
				if /i not "%Context%"=="IMG-Choose.and.Set.As" call :Config-Save
			) else (
				echo.
				echo.
				set "TemplateChoice=Selected"
				exit /b
			)
		) else (
			rem Display Template info.
			if /i not "%Context%"=="IMG-Choose.and.Set.As" (
			echo.
			echo   %_%%ESC%%cc_%  %TName%%_% selected.%ESC%
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
exit /b


:FI-Template-Sample               
if /i "%referer%"=="FI-Generate" exit /b
call :Config-UpdateVar
if not exist "%RCFI%\templates\samples" md "%RCFI%\templates\samples"
set "InputFile=%TemplateSampleImage%"
set "OutputFile=%RCFI%\templates\samples\%TName%.ico"
if /i "%Context%"=="IMG.Choose.Template" set "InputFile=%img%"
REM if /i "%testmode%"=="yes" set "AlwaysGenerateSample=No"

if exist "%OutputFile%" del "%OutputFile%"

echo.&echo.
echo %i_%%g_%  Generating sample preview.. %-%
echo %g_%Selected Template:%ESC%%cc_%%TName%%ESC%%r_%
for %%I in ("%InputFile%") do set "TSampleName=%%~nxI"&set "TSamplePath=%%~dpI"
echo %g_%Sample image     :%ESC%%c_%%TSampleName%%ESC%%r_%
PUSHD "%TSamplePath%"
Call "%Template%"
POPD
if %ERRORLEVEL% NEQ 0 echo   %r_%%i_%   error ^(%ERRORLEVEL%^)   %-%
if exist "%OutputFile%" for %%C in ("%OutputFile%") do (
	if %%~zC GTR 200 (
		echo %g_%Done! 
		if /i not "%AlwaysGenerateSample%"=="No" explorer.exe "%OutputFile%"
	)
	if %%~zC LSS 200 (
		echo %TAB%    %r_%Convert error:%ESC%%c_%%%~nxS%_% (%pp_%%%~zS Bytes%_%)
		echo %TAB%    %g_%Icon should not less than 200 bytes.
		del "%OutputFile%" >nul
		pause>nul
		goto options
	)
)
exit /b

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
echo   %ESC%- %c_%%TSampleName%%_% (%pp_%%size%%_%)
echo.
echo %TAB%%yy_%Generating all sample images..%_%
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
echo %TAB%%i_%%yy_%   Done!   %_%
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
if %TCount% LSS 10 echo %TAB%%gn_% %TCount%%_%%ESC%> %cc_%%TName%%ESC%
if %TCount% GTR 9  echo %TAB%%gn_%%TCount%%_%%ESC%> %cc_%%TName%%ESC%%r_%
PUSHD "%TSamplePath%"
 call "%TSampling%"
POPD
if exist "%OutputFile%" (
	for %%S in ("%OutputFile%") do (
		if %%~zS GTR 200 (
		rem	echo %TAB%    %ESC%%_%Convert success 
			echo %TAB%    %ESC%%c_%%%~nxS%g_% (%pp_%%%~zS Bytes%g_%)%_%
		)
		if %%~zS LSS 200 (
		echo %TAB%    %r_%Convert error:%ESC%%c_%%%~nxS%_% (%pp_%%%~zS Bytes%_%)
		echo %TAB%    %g_%Icon should not less than 200 bytes.
		del "%OutputFile%" >nul
		)
	)
) else (echo %TAB%    %r_%%i_% Convert failed. %_%)
echo.
exit /b

:FI-Template-TestMode-TnameX_forfiles_resolver
set "TnameXfor=%TnameX:(=^(%"
set "TnameXfor=%TnameXfor:)=^)%"
set "TnameXfor=%TnameXfor:&=^&%"
exit /b

:FI-Template-TestMode
set "OutputFile=%RCFI%\templates\samples\%TName%.png"
if /i "%referer%"=="FI-Generate" exit /b
echo.&echo.&echo.
if /i not "%TemplateTestMode-AutoExecute%"=="yes" set /a "TestCount+=1"
echo %gn_%%i_% %_%%w_% This is Test Mode%_%
echo   %g_%executed(%_%%TestCount%%g_%)%r_%
echo.
if /i not "%TemplateTestMode-AutoExecute%"=="yes" (
	PUSHD "%TSamplePath%"
		call "%TFullPath%"
		if exist "%OutputFile%" for %%I in ("%OutputFile%") do (if %%~zI LSS 100 del "%OutputFile%")
		if exist "%OutputFile%" (explorer.exe "%OutputFile%") else echo %r_%%i_%Error: Fail to convert.%_%
	POPD
	)
echo.

PUSHD "%TPath%"
	for /f "delims=" %%i in ('"forfiles /m "%TnameXfor%" /c "cmd /c echo @ftime""') do set "Tdate=%%i"
POPD

echo  %_%Template      :%ESC%%cc_%%TnameX% %g_%(Modified: %gg_%%Tdate%%g_%)%ESC%
echo %ESC%%g_%%TFullPath%%ESC%

for %%I in ("%InputFile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%InputFile%%ESC%

if exist "%OutputFile%" for %%I in ("%OutputFile%") do (
	if %%~zI GTR 100 (
		set "fname=%%~nxI"
		set "size_b=%%~zI"
		call :FileSize
	) else (
		call :FileSize
		del "%OutputFile%" 
		set "fname=%r_%Fail to generate."
	)
) else set "size="
echo  %_%Generated icon:%ESC%%c_%%fname%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%OutputFile%%ESC%
echo %w_%----------------------------------------------------------------------------------------
if /i "%TemplateTestMode-AutoExecute%"=="yes" cls&set "TestModeAuto=Execute"&set "TdateX=%Tdate%"&goto FI-Template-TestMode-Auto
echo %g_%Press Any Key to re-execute the template. %_%&pause>nul
if exist "%OutputFile%" del "%OutputFile%" >nul
echo.&echo.&echo.
goto FI-Template-TestMode

:FI-Template-TestMode-Auto
echo.&echo.&echo.
if /i "%TestModeAuto%"=="Execute" set /a "TestCount+=1"
echo %gn_%%i_% %_%%w_% This is Test Mode%_%
echo   %g_%executed(%_%%TestCount%%g_%)%r_%
echo.
if /i "%TestModeAuto%"=="Execute" ( 
	PUSHD "%TSamplePath%"
		call "%TFullPath%"
		set "TestModeAuto="
		if exist "%OutputFile%" for %%I in ("%OutputFile%") do (if %%~zI LSS 100 del "%OutputFile%")
		if exist "%OutputFile%" (explorer.exe "%OutputFile%") else echo %r_%%i_%Error: Fail to convert.%_%&set "error=detected"
	POPD
	)
echo.
echo  %_%Template      :%ESC%%cc_%%TnameX% %g_%(Modified: %gg_%%Tdate%%g_%)%ESC%
echo %ESC%%g_%%TFullPath%%ESC%

for %%I in ("%InputFile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%InputFile%%ESC%

if exist "%OutputFile%" for %%I in ("%OutputFile%") do (
	set "fname=%%~nxI"
	set "size_b=%%~zI"
	call :FileSize
	) else (set size=%r_%Error: file not found!%_%)
echo  %_%Generated icon:%ESC%%c_%%fname%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%OutputFile%%ESC%
echo %w_%----------------------------------------------------------------------------------------
PUSHD "%TPath%"
	for /f "delims=" %%i in ('"forfiles /m "%TnameXfor%" /c "cmd /c echo @ftime""') do set "Tdate=%%i"
POPD
if /i not "%TemplateTestMode-AutoExecute%"=="yes" goto FI-Template-TestMode
if /i "%error%"=="detected" echo %i_%Error Detected! Auto execution is PAUSED. Press any key to continue.%_%&pause>nul&set "Error="
if "%TdateX%"=="%Tdate%" echo The template will be automatically executed when a file modification is detected.&%p2%&cls&goto FI-Template-TestMode-Auto
set "TdateX=%Tdate%"
set "TestModeAuto=Execute"
if exist "%OutputFile%" del "%OutputFile%" >nul
cls
goto FI-Template-TestMode-Auto

:FI-Template-Edit
echo            %i_%%w_%  Template Configuration  %_%
echo.
echo %TAB%    %w_%Choose Template:%_%
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
echo                     %g_%    Search folder icon  on Google image search, Just type
echo                     %g_% in the keyword then hit [Enter],  you will be redirected 
echo                     %g_% to Google search image results with filters on  so it is 
echo                     %g_% easier to find.
echo.&echo.&echo.&echo.
echo                                       %i_%%w_% SEARCH FOLDER ICON %_%
echo.
set "SrcInput=0"
set /p "SrcInput=%_%%w_%                                      %_%%w_%"
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
echo                 %w_%%i_%     K E Y W O R D S     %_%
echo.
call :Config-UpdateVar
rem echo.
rem echo %TAB%%Keywords%
rem echo %TAB%%KeywordsFind%
echo %TAB%%r_%*%g_%Certain characters can causing an error, such as: 
echo %TAB%%r_% %g_%%g_%%c_%%%%g_% %c_%"%g_% %c_%(%g_% %c_%)%g_% %c_%<%g_% %c_%>%g_% %c_%[%g_% %c_%&%g_%%_%
echo.
echo %TAB%%r_%*%g_%Use comma to separate multiple keywords, for example:
echo %TAB%%r_% %c_%folder icon.ico, folder art.png, favorite image.jpg
echo.
echo %TAB%%r_%*%g_%Spaces, dots, hypens, underscores will be interpreted as a wildcard.
echo.
echo.
echo.
echo %TAB%%w_%Current keywords:%_% %KeywordsPrint%
set "newKeywords=*"
set /p "newKeywords=%-%%-%%-%%g_%%i_%Change  keywords:%_% %c_%"
if "%newKeywords%"=="*" set "newKeyword=%Keywords%"
set "Keywords=%newKeywords%"

goto FI-Keyword-Selected
echo %TAB%%r_%%i_%  Somthing when wrong :/ ^?.  %-%
echo.
goto options

:FI-Keyword-ImageSupport          
call set "KeywordsFind=%%KeywordsFind:%ImgExtS%=*%ImgExtS%%%"
exit /b

:FI-Keyword-Selected              
call :Config-Save
call :Config-UpdateVar
if "%Context%"=="DefKey" (
	cls &echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo %TAB%%TAB%%w_%%i_% Keywords %_%
	echo %TAB%%KeywordsPrint%
	echo.
	echo %TAB%%g_%The keywords will be use to find and generate folder icon.
	ping localhost -n 2 >nul
	goto options
)
echo.&echo.
goto Status

:FI-Activate                      
echo %TAB%%cc_%  Activating folder Icon.. %_%
echo %TAB%%cc_%----------------------------------------%_%
if "%RefreshOpen%"=="Select" (
	FOR %%D in (%xSelected%) do (
		attrib +r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%w_%📁%ESC%%%~nxD%ESC%
	)
) else (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		attrib +r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%w_%📁%ESC%%%D%ESC%
	)
)
echo %TAB%%cc_%----------------------------------------%_%
echo.
echo %TAB%%cc_% %i_%   Done!   %-%
goto options
:FI-Deactivate                    
echo %TAB%%cc_%    Deactivating folder Icon.. %_%
echo %TAB%%cc_%----------------------------------------%_%
if "%RefreshOpen%"=="Select" (
	FOR %%D in (%xSelected%) do (
		attrib -r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%g_%📁%ESC%%g_%%%~nxD%ESC%
	)
) else (
	FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
		attrib -r "%%~fD" &attrib |EXIT /B
		Echo  %TAB%%g_%📁%ESC%%g_%%%D%ESC%
	)
)
echo %TAB%%cc_%----------------------------------------%_%
echo.
echo %TAB%%cc_% %i_%   Done!   %-%
goto options

:FI-Remove                        
@echo off
set "result=0"
set "delresult=0"
IF /I "%DELETE%"=="CONFIRM" goto FI-Remove-Confirm
echo %TAB%%r_%   %i_%  Remove Folder Icon  %-%
echo.
echo %TAB%%w_%Directory:%ESC%%w_%%cd%%ESC%
echo %TAB%%w_%==============================================================================%_%
call :FI-Remove-Get
echo %TAB%%w_%==============================================================================%_%
IF /i %result% LSS 1 if defined Context cls
IF /i %result% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%r_%%result%%_%%_%^) Couldn't find any folder icon. &goto options
echo. &echo %_%%TAB%  ^(%y_%%result%%_%%_%^) Folder icon found.%_% &echo.&echo.
echo       %_%%r_%Continue to Remove (%y_%%result%%_%%r_%^) folder icons^?%-% 
echo %TAB%%ast%%g_%The folder icon will be deactivated from the folder, "desktop.ini"
echo %TAB% and "foldericon.ico"   inside   the  folder   will   be  deleted.
echo %TAB%%g_% Options:%_% %gn_%Y%_%/%gn_%N%_% %g_%^| Press %gg_%Y%g_% to confirm.%_%%bk_%
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="1" set "DELETE=CONFIRM" &goto FI-Remove
IF "%ERRORLEVEL%"=="2" echo %_%%TAB%  %I_%     Canceled     %_% &goto options

:FI-Remove-Confirm                
if defined Context cls
if defined Context (
	echo.&echo.&echo.&echo.
	echo %TAB%%r_%   %i_%  Removing Folder Icon..  %-%
	echo.
	if /i not "%cdonly%"=="true" echo %TAB%%w_%Directory:%ESC%%w_%%cd%%ESC%
	if /i not "%cdonly%"=="true" echo %TAB%%w_%==============================================================================%_%
	if /i not "%cdonly%"=="true" echo.
)

call :FI-Remove-Get

if defined Context if /i not "%cdonly%"=="true" echo %TAB%%w_%==============================================================================%_%
IF /i %result% LSS 1 if defined Context cls
IF /i %result% LSS 1 echo.&echo.&echo. &echo %_%%TAB%^(%r_%%result%%_%%_%^) Couldn't find any folder icon. &goto options
if %delresult% GTR 0 echo. &echo %TAB% ^(%r_%%delresult%%_%^) Folder icon deleted.
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
FOR /f "tokens=*" %%D in ('dir /b /a:d') do (
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

:FI-Remove-Act                    
if /i not "%delete%"=="confirm" (
	if exist "%iconresource%" (
		set /a result+=1
		echo %ESC%%TAB%%y_%📁 %foldername%%ESC% &exit /b
	)
	exit /b
)
if exist "%iconresource%" (
	set /a result+=1
	if /i "%delete%"=="confirm" (
		if not defined timestart call :timer-start
		echo %ESC%%TAB%%w_%📁 %_%%foldername%%ESC%
		echo %TAB% %g_%Folder icon:%ESC%%c_%%iconresource%%ESC%
		for %%I in ("%iconresource%") do (
			if "%%~dpI"=="%cd%\" (
				attrib -s -h "%iconresource%" 
				attrib |exit /b
				echo %TAB% %g_%Deleting%ESC%%g_%%iconresource%%ESC%%r_%
				del /f /q "%iconresource%"			
			) else (echo %TAB%%ESC%%c_%%%~nxI%_% %g_%file is outside of %_%📁 %foldername%%g_%, %ESC%&echo %TAB% %g_%so it will not be deleted.)
		)
		echo %TAB% %g_%Deleting desktop.ini%r_%
	rem	attrib /d -r "%cd%" 
		attrib -h -s "Desktop.ini"
		attrib |exit /b		
		del /f /q "Desktop.ini"
		if not exist "desktop.ini" if not exist "%iconresource%" echo %TAB% %g_%%i_%  Done!  %-% &set /a delresult+=1 &echo.
	)
)
EXIT /B

:FI-Refresh                       
call :timer-start
if exist "%RCFI%\resources\refresh.RCFI" (if defined Context exit else goto options) else (echo    refreshing >>"%RCFI%\resources\refresh.RCFI")
if /i not "%Context%"=="" echo.&echo.&echo.
echo %_%%g_%%TAB%Note: In case if the process gets stuck and explorer doesn't come back.
echo %TAB%Hold %i_% CTRL %_%%g_%+%i_% SHIFT %_%%g_%+%i_% ESC %_%%g_%%-% %g_%^> Click File ^> Run New Task ^> Type "explorer" ^> OK.
echo %TAB%%cc_%Restarting Explorer and updating icon cache ..%r_%
echo.&set "startexplorer="
rem ie4uinit.exe -ClearIconCache
rem ie4uinit.exe -show
set Context=&Set Setup=
taskkill /F /IM explorer.exe >nul ||echo 	echo %i_%%r_% Failed to Terminate "Explorer.exe" %_%
PUSHD "%userprofile%\AppData\Local\Microsoft\Windows\Explorer"
if exist "iconcache_*.db" attrib -h iconcache_*.db
if exist "%localappdata%\IconCache.db" DEL /A /Q "%localappdata%\IconCache.db"
if exist "%localappdata%\Microsoft\Windows\Explorer\iconcache*" DEL /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\iconcache*"
start explorer.exe ||set "startexplorer=fail"
POPD
if "%startexplorer%"=="fail" (
	echo.
	echo %i_%%r_%  Failed to start "Explorer.exe"  %_%
	%P4%
	)
if /i "%RefreshOpen%"=="Select" (explorer.exe /select, "%cd%") else explorer.exe "%cd%"
echo %TAB%%TAB%%cc_%%i_%    Done!   %-%
if /i "%cdonly%"=="true" set "cdonly="&cd /d ..
call :FI-Refresh-NoRestart
if /i "%act%"=="Refresh" exit /b
goto options

:FI-Refresh-NoRestart             
@echo off
set "WaitRefreshDelay=echo.&echo.&echo %g_%  if the folder icon hasn't changed yet, Please&echo   wait for 30-40 seconds then refresh again.%_%"
mode con:cols=50 lines=9
title  refresh folder icon..
set refreshCount=0
for %%F in (.) do (
	set "foldername=%%~nxF"
	if exist "desktop.ini" (
		title  "%%~nxF"
		%WaitRefreshDelay%
		echo.
		echo %TAB%%w_%Refreshing ..%_%
		echo %ESC%%cc_%%%~nxF%ESC%%r_%
		attrib -r "%cd%"
		attrib -s -h 		"desktop.ini"
		ren "desktop.ini" "DESKTOP INI"
		ren "DESKTOP INI" "desktop.ini"
		attrib +r "%cd%"
		Attrib %Attrib% 		"desktop.ini"
		attrib |exit /b
		set /a refreshCount+=1
	) else (
		title  "%%~nxF"
		echo %TAB%%w_%Refreshing ..%_%
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
			echo %TAB%%w_%Refreshing ..%_%
			echo %ESC%%cc_%%%R%ESC%%r_%
			attrib -r "%%~fR"
			attrib -s -h 		"desktop.ini"
			ren "desktop.ini" "DESKTOP INI"
			ren "DESKTOP INI" "desktop.ini"
			attrib +r "%%~fR"
			Attrib %Attrib% 		"desktop.ini"
			attrib |exit /b
			set /a refreshCount+=1
		) else (
			title  "%%R"
			echo %TAB%%w_%Refreshing ..%_%
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
echo %TAB%               %i_%%w_%    Done!    %_%
echo. &echo.
ping localhost -n 2 >nul
del "%RCFI%\resources\refresh.RCFI" 2
ping localhost -n 1 >nul
exit

:FI-ID                            
set "digit=6"
set "string=C2DF5GHJ7KL8QRST9VXZ"
set "string_lenght=20"
set "digit_count=" &set "get_ID="

:FI-ID-get                        
set /a "digit_count+=1" &set /a "x=%random% %% %string_lenght%"
call set "get_ID=%get_ID%%%string:~%x%,1%%"
if not "%digit_count%"=="%digit%" goto FI-ID-get
set "FI-ID=%get_ID%"
exit /b

:IMG-Generate_icon
if /i "%TemplateAlwaysAsk%"=="Yes" (call :FI-Template-AlwaysAsk&cls&echo.&echo.&echo.)
call :timer-start
FOR %%T in ("%Template%") do set "TName=%%~nT"
echo %TAB%       %i_%%w_%    Generating Icon..    %_%
echo.
echo %TAB%Template:%ESC%%cc_%%Tname%%ESC%
echo %TAB%%_%----------------------------------------------------%_%
if "%Context%"=="IMG.Generate.PNG" (set "OutputExt=.png") else (set "OutputExt=.ico")
FOR %%I in (%xSelected%) do (
	set "IMGpath=%%~dpI"
	set "IMGfullpath=%%~fI"
	set "IMGname=%%~nI"
	set "IMGext=%%~xI"
	set "Size_B=%%~zI"
	set "-=%g_%-"
	call :FileSize
	echo.
	Call :IMG-Generate_icon-FileList
	call :IMG-Generate_icon-Act
	call :IMG-Generate_icon-Done
)
echo.
echo %TAB%%_%----------------------------------------------------%_%
echo.
echo %TAB%%g_%%i_%  Done!  %_%
goto options

:IMG-Generate_icon-FileList
if /i "%IMGext%"==".ico" set "IMGext=%y_%%IMGext%"
if /i "%IMGext%"==".png" set "IMGext=%cc_%%IMGext%"
echo %_%%TAB%%ESC%%c_%%IMGname%%bb_%%IMGext% %g_%(%pp_%%size%%g_%)%ESC%%r_%
exit /b

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
exit /b

:IMG-Generate_icon-Done
if exist "%OutputFile%" (
		for %%G in ("%OutputFile%") do (
			set "Size_B=%%~zG"
			set "IMGname=%%~nG"
			set "IMGext=%%~xG"
			set "Size_B=%%~zG"
			set "-=%g_%-"
			call :FileSize
			call :IMG-Generate_icon-FileList
		)
	) else (echo %TAB%%r_%Failed to generate icon.)
exit /b

:IMG-Convert                      
call :timer-start
set separator=echo %TAB% %_%--------------------------------------------------------------------%_%
if not defined Action echo %TAB%       %i_%%w_%    IMAGE CONVERTER    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %i_%%cc_%    IMAGE CONVERTER    %_%
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
echo  %TAB%%g_%%i_%  Done!  %_%
goto options

:IMG-Convert-FileList             
echo %TAB%%_%%ESC%- %c_%%ImgName%%ImgExt%%_% %G_%(%pp_%%size%%G_%)%ESC%%r_%
exit /b

:IMG-Convert-Options              
echo.
echo %TAB%%g_%To select, just press the %gg_%number%g_% associated below.
echo.
echo %TAB%  Select Image extension:
echo %TAB%  %gn_%1%_% ^>%cc_%.jpg%_%
echo %TAB%  %gn_%2%_% ^>%cc_%.png%_%
echo %TAB%  %gn_%3%_% ^>%cc_%.ico%_%
echo %TAB%  %gn_%4%_% ^>%cc_%.bmp%_%
echo %TAB%  %gn_%5%_% ^>%cc_%.svg%_%
echo %TAB%  %gn_%6%_% ^>%cc_%.webp%_%
echo %TAB%  %gn_%7%_% ^>%cc_%.heif%_%
echo.
echo %TAB%%g_%Press %gn_%i%g_% to input any extension you want. %_%^| %g_%Press %gn_%c%g_% to cancel.%bk_%
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
	echo %TAB%%g_%Input file extension you want, example: %yy_%.gif%g_%
	set /p "ImgExtNew=%-%%-%%-%%w_%Input:%yy_%"
)
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options
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
	if not exist "%ImgPath%%ImgOutput%" exit /b
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
	echo %TAB%-%ESC%%c_%%ImgName%%nTag%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	exit /b
)
if %Size_B% LSS 100 (
	echo %TAB% %r_%Convert Fail!%_%
	del "%ImgPath%%ImgOutput%"
)
exit /b

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
if not defined Action echo %TAB%       %i_%%w_%    IMAGE RESIZER    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %i_%%cc_%    IMAGE CONVERTER    %_%
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
echo  %TAB%%g_%%i_%  Done!  %_%
goto options

:IMG-Resize-FileList              
echo %TAB%%ESC%- %c_%%ImgName%%ImgExt%%g_% (%pp_%%size%%g_%)%ESC%%r_%
exit /b

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
echo %TAB%%g_%To select, just press the %gg_%number%g_% associated below.
echo.
echo %TAB%  Select Image size:
echo %TAB%  %gn_%1%_% ^>%cc_%%IMGResize1Name%%_%
echo %TAB%  %gn_%2%_% ^>%cc_%%IMGResize2Name%%_%
echo %TAB%  %gn_%3%_% ^>%cc_%%IMGResize3Name%%_%
echo %TAB%  %gn_%4%_% ^>%cc_%%IMGResize4Name%%_%
echo %TAB%  %gn_%5%_% ^>%cc_%%IMGResize5Name%%_%
echo %TAB%  %gn_%6%_% ^>%cc_%%IMGResize6Name%%_%
echo %TAB%  %gn_%7%_% ^>%cc_%%IMGResize7Name%%_%
echo.
echo %TAB%%g_%Press %gn_%i%g_% to input your prefer output.%_% ^| %g_%Press %gn_%c%g_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgResizeCode=%IMGResize1Code%"&set "ImgTag=%IMGResize1Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="2" set "ImgResizeCode=%IMGResize2Code%"&set "ImgTag=%IMGResize2Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="3" set "ImgResizeCode=%IMGResize3Code%"&set "ImgTag=%IMGResize3Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="4" set "ImgResizeCode=%IMGResize4Code%"&set "ImgTag=%IMGResize4Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="5" set "ImgResizeCode=%IMGResize5Code%"&set "ImgTag=%IMGResize5Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="6" set "ImgResizeCode=%IMGResize6Code%"&set "ImgTag=%IMGResize6Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="7" set "ImgResizeCode=%IMGResize7Code%"&set "ImgTag=%IMGResize7Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Resize
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options

echo %TAB%%g_%Input your own  command, example: 
echo %TAB%%yy_%-resize 1000x1000!%g_% = force resize tha image to 1000px1000p and ignore the aspect ratio.
echo %TAB%%yy_%-quality 85%g_%        = compress the image to 85%% quality.
echo %TAB%%yy_%-resize 1000x%g_%      = resize the image to a width of 1000p.
echo %TAB%%yy_%-resize x1000%g_%      = resize the image to a height of 1000p.
echo %TAB%%yy_%-resize 720x720 -quality 80%g_% = resize the image to 720p and compress the quality to 80%%.

echo.
set /p "ImgResizeCode=%-%%-%%-%%w_%Input:%yy_%"
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
	echo %TAB%%ESC%- %c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	exit /b
)

if not %size_B% LSS 10 (
	echo %TAB%%ESC%- %c_%%ImgName%%cc_%%ImgTag%%nTag%%c_%%ImgExt%%g_% (%pp_%%size%%g_%)%ESC%%r_%
) else (
	echo %TAB%%ESC%- %c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	del "%ImgPath%%ImgOutput%"
	exit /b
)
exit /b


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
if not defined Action echo %TAB%       %i_%%w_%    IMAGE COMPRESSOR    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %i_%%cc_%    IMAGE CONVERTER    %_%
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
echo  %TAB%%g_%%i_%  Done!  %_%
goto options

:IMG-Compress-FileList              
echo %TAB%%ESC%- %c_%%ImgName%%ImgExt%%g_% (%pp_%%size%%g_%)%ESC%%r_%
exit /b

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
echo %TAB%%g_%To select, just press the %gg_%number%g_% associated below.
echo.
echo %TAB%  Select Image compression level quality:
echo %TAB%  %gn_%1%_% ^>%cc_%%IMGCompress1Name%%_%
echo %TAB%  %gn_%2%_% ^>%cc_%%IMGCompress2Name%%_%
echo %TAB%  %gn_%3%_% ^>%cc_%%IMGCompress3Name%%_%
echo %TAB%  %gn_%4%_% ^>%cc_%%IMGCompress4Name%%_%
echo %TAB%  %gn_%5%_% ^>%cc_%%IMGCompress5Name%%_%
echo %TAB%  %gn_%6%_% ^>%cc_%%IMGCompress6Name%%_%
echo %TAB%  %gn_%7%_% ^>%cc_%%IMGCompress7Name%%_%
echo.
echo %TAB%%g_%Press %gn_%i%g_% to input your prefer output.%_% ^| %g_%Press %gn_%c%g_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgCompressCode=%IMGCompress1Code%"&set "ImgTag=%IMGCompress1Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="2" set "ImgCompressCode=%IMGCompress2Code%"&set "ImgTag=%IMGCompress2Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="3" set "ImgCompressCode=%IMGCompress3Code%"&set "ImgTag=%IMGCompress3Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="4" set "ImgCompressCode=%IMGCompress4Code%"&set "ImgTag=%IMGCompress4Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="5" set "ImgCompressCode=%IMGCompress5Code%"&set "ImgTag=%IMGCompress5Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="6" set "ImgCompressCode=%IMGCompress6Code%"&set "ImgTag=%IMGCompress6Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="7" set "ImgCompressCode=%IMGCompress7Code%"&set "ImgTag=%IMGCompress7Tag%"&if not defined timestart call :timer-start&set "Action=Start" &cls&goto IMG-Compress
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options

echo %TAB%%g_%Input your own  command, example: 
echo %TAB%%yy_%-resize 1000x1000!%g_% = force resize tha image to 1000px1000p and ignore the aspect ratio.
echo %TAB%%yy_%-quality 85%g_%        = compress the image to 85%% quality.
echo %TAB%%yy_%-resize 1000x%g_%      = resize the image to a width of 1000p.
echo %TAB%%yy_%-resize x1000%g_%      = resize the image to a height of 1000p.
echo %TAB%%yy_%-resize 720x720 -quality 80%g_% = resize the image to 720p and compress the quality to 80%%.
echo.
set /p "ImgCompressCode=%-%%-%%-%%w_%Input:%yy_%"
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
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	exit /b
)

if not %size_B% LSS 1000 (
	echo %TAB%%ESC%- %c_%%ImgName%%cc_%%ImgTag%%nTag%%c_%%ImgExt%%g_% (%pp_%%size%%g_%)%ESC%%r_%
) else (
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	del "%ImgPath%%ImgOutput%"
	exit /b
)
exit /b


:FileSize                         
if "%size_B%"=="" set size=0 KB&echo %r_%Error: Fail to get file size!%_% &exit /b
set /a size_KB=%size_B%/1024
set /a size_MB=%size_KB%00/1024
set /a size_GB=%size_MB%/1024
set size_MB=%size_MB:~0,-2%.%size_MB:~-2%
set size_GB=%size_GB:~0,-2%.%size_GB:~-2%
if %size_B% NEQ 1024 set size=%size_B% Bytes
if %size_B% GEQ 1024 set size=%size_KB% KB
if %size_B% GEQ 1024000 set size=%size_MB% MB
if %size_B% GEQ 1024000000 set size=%size_GB% GB
exit /b

:Timer-start
set timestart=%time%
exit /b

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
exit /b



:Config                      
call :Config-Load
echo %TAB%       %i_%%pp_% RCFI Tools Configuration %_%
echo %TAB%%_%to change the configurations, you  have to edit the "RCFI.config.ini" file
echo %TAB%which is located at:%ESC%%w_%%RCFI%\%c_%RCFI.config.ini%ESC%
echo.
echo %TAB%%w_% Current Config %_%
echo %TAB%%_%----------------------------------------------------------------------
echo %TAB%%yy_%Converter%_%
echo %TAB%"%Converter%"
if exist "%Converter%" for %%I in ("%Converter%") do (
	echo %TAB%%g_%"%%~nxI" will be used to convert the image into icon.
) else (
	echo %TAB%%r_%^! %g_%Config value is not valid because
	echo %TAB%"%converter%" %r_%doesn't exist.%_%
)
echo.
echo %TAB%%yy_%DrivePath%_%
echo %TAB%"%DrivePath%"
if exist "%DrivePath%" for %%I in ("%DrivePath%") do (
	echo %TAB%%g_%"%%~nxI" is the current active working directory.
) else (
	echo %TAB%%r_%^! %g_%Config value is not valid because 
	echo %TAB%"%converter%" %r_%doesn't exist.%_%
)
echo.
echo %TAB%%yy_%Keywords%_%
echo %TAB%"%Keywords%%Keyword-extension%"
echo %TAB%%g_%Keyword will  be used to  search for the  target  image  to  use  as a 
echo %TAB%%g_%folder  icon.
echo.
echo %TAB%%yy_%Template%_%
echo %TAB%"%Template%"
if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%g_%Template:%ESC%%cc_%%%~nxI%g_%%ESC%
	echo %TAB%%g_%The template will be used to generate a folder icon.
) else (
	echo %TAB%%r_%^! %g_%Config value is not valid because 
	echo %TAB%"%converter%" %r_%doesn't exist.%_%
)
echo.
REM echo %TAB%%yy_%AlwaysGenerateSample%_%
REM echo %TAB%"%AlwaysGenerateSample%"
REM echo %TAB%%g_%If the  value is not "NO", RCFI Tools will  generate a sample image every
REM echo %TAB%%g_%time  you  select  a  template via "choose template" menu.
REM echo.
if exist "%TemplateForICO%" for %%I in ("%TemplateForICO%") do (
	echo %TAB%%yy_%TemplateForICO%_%
	echo %TAB%"%TemplateForICO%"%_%
	echo %TAB%%g_%Template:%ESC%%cc_%%%~nxI%ESC%%g_%
	echo %TAB%%g_%will be used to generate a folder icon if the selected  image is %c_%.ico%g_%.
) else (
	echo %TAB%%yy_%TemplateForICO%g_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%g_%"%cc_%%%~nxI%g_%" will be used to generate a folder icon.
	)
)
echo.
if exist "%TemplateForPNG%" for %%I in ("%TemplateForPNG%") do (
	echo %TAB%%yy_%TemplateForPNG%_%
	echo %TAB%"%TemplateForPNG%"%_%
	echo %TAB%%g_%Template:%ESC%%cc_%%%~nxI%ESC%%g_%
	echo %TAB%%g_%will be used to generate a folder icon if the selected  image is %c_%.png%g_%.
) else (
	echo %TAB%%yy_%TemplateForPNG%g_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%g_%"%cc_%%%~nxI%g_%" will be used to generate a folder icon.
	)
)
echo.
if exist "%TemplateForJPG%" for %%I in ("%TemplateForJPG%") do (
	echo %TAB%%yy_%TemplateForJPG%_%
	echo %TAB%"%TemplateForJPG%"%_%
	echo %TAB%%g_%Template:%ESC%%cc_%%%~nxI%ESC%%g_%
	echo %TAB%%g_%will be used to generate a folder icon if the selected  image is %c_%.jpg%g_%.
) else (
	echo %TAB%%yy_%TemplateForJPG%g_%
	echo %TAB%Value is not valid/The path doesn't exist.%_%
	if exist "%Template%" for %%I in ("%Template%") do (
	echo %TAB%%g_%"%cc_%%%~nxI%g_%" will be used to generate a folder icon.
	)
)
echo.
echo %TAB%%yy_%TemplateAlwaysAsk%_%
echo %TAB%"%TemplateAlwaysAsk%"%_%
echo %TAB%%g_%If the  value is "YES", RCFI Tools will  ask for choosing the template
echo %TAB%%g_%every  time  you  generate  a  folder icon. 
echo.
echo %TAB%%yy_%RunAsAdmin%_%
echo %TAB%"%RunAsAdmin%"%_%
echo %TAB%%g_%If  the  value  is  "YES",  RCFI  Tools  will  be  elevated to  run as
echo %TAB%%g_%administrator  every  time  it  runs.
echo.
echo %TAB%%yy_%ExitWait%_%
echo %TAB%"%ExitWait%"%_%
echo %TAB%%g_%The window will  automatically  close  after %ExitWait% seconds. If the  value 
echo %TAB%%g_%is  more  than  99  automatic  close  will  be  disable.
echo %TAB%%_%----------------------------------------------------------------------
echo %TAB%%cc_%^>%_% Press %gg_%O%_% to open folder containing "RCFI.config.ini".
echo %TAB%%cc_%^>%_% Press %gg_%C%_% to exit.%bk_%
choice /C:oc /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" (
	echo %TAB%%w_% Opening..
	echo %TAB%%ESC%%i_%%RCFI%%ESC%
	explorer.exe /select, "%RCFI%\RCFI.config.ini"
	goto options
)
if /i "%ImgSizeInput%"=="2" echo %TAB%%_%Exiting configuration.. &goto options
goto options

:Config-Save                      
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
	echo HideAsSystemFiles="%HideAsSystemFiles%"
	echo DeleteOriginalFile="%DeleteOriginalFile%"
	echo TextEditor="%TextEditor%"
	echo ----------------------------------
	echo DrivePath="%cd%"	
)>"%RCFI.config.ini%"
if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="
set "Template=%RCFI%\templates\%Template:"=%.bat"
set "TemplateForICO=%RCFI%\templates\%TemplateForICO:"=%.bat"
set "TemplateForPNG=%RCFI%\templates\%TemplateForPNG:"=%.bat"
set "TemplateForJPG=%RCFI%\templates\%TemplateForJPG:"=%.bat"
EXIT /B

:Config-Load                      
REM Load Config from RCFI.config.ini
if not exist "%RCFI.config.ini%" call :Config-GetDefault
if not exist "%~dp0RCFI.templates.ini" call :Config-GetTemplatesConfig

if exist "%RCFI.config.ini%" (
	for /f "usebackq tokens=1,2 delims==" %%C in ("%RCFI.config.ini%") do (set "%%C=%%D")
) else (
	echo.&echo.&echo.&echo.
	echo       %w_%Couldn't load RCFI.config.ini.   %r_%Access is denied.
	echo       %w_%Try Run As Admin.%_%
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
set "HideAsSystemFiles=%HideAsSystemFiles:"=%"
set "DeleteOriginalFile=%DeleteOriginalFile:"=%"
set "TextEditor=%TextEditor:"=%"


if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="

if /i "%HideAsSystemFiles%"=="yes" (set "Attrib=+s +h") else (set Attrib=+h)

REM "AlwaysGenerateSample=%AlwaysGenerateSample:"=%"
rem set "RunAsAdmin=%RunAsAdmin:"=%"
set "ExitWait=%ExitWait:"=%"

EXIT /B

:Config-GetDefault                
cd /d "%~dp0"
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
	echo HideAsSystemFiles="No"
	echo DeleteOriginalFile="No"
	echo TextEditor="%windir%\notepad.exe"
	echo DrivePath="%cd%"
)>"%RCFI.config.ini%"
EXIT /B

:Config-GetTemplatesConfig                
cd /d "%~dp0"
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
title %name% %version%    "%cd%"
set "result=0"
set "keywordsFind=*%keywords%*"
set "keywordsFind=%keywordsFind: =*%"
set "keywordsFind=%keywordsFind:.=*%
set "keywordsFind=%keywordsFind:_=*%
set "keywordsFind=%keywordsFind:-=*%
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
call set "KeywordsPrint=%%Keywords:,=%c_%,%_%%%"
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
set "ntc_=%_%%i_%%w_% %_%%-%"
set "TAB=   "
set ESC=[30m"[0m
set "AST=%r_%*%_%"

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
if exist "%DrivePath%" (cd /d "%DrivePath%") else (cd /d "%~dp0")
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
exit /b


:Config-Startup                   
if /i "%act%"=="Refresh"		goto FI-Refresh
if /i "%act%"=="RefreshNR"	goto FI-Refresh-NoRestart
if /i "%act%"=="FI-Template-Sample-All" goto FI-Template-Sample-All
if /i "%Context%"=="Refresh.Here"	cd /d "%SelectedThing%" &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh
if /i "%Context%"=="RefreshNR.Here"	cd /d "%SelectedThing%" &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh-NoRestart
if /i "%Context%"=="Refresh"			cd /d "%SelectedThing%" &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh
if /i "%Context%"=="RefreshNR"		cd /d "%SelectedThing%" &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh-NoRestart
EXIT /B


:Help                             
echo   %w_%       %u_%   O P T I O N S   %_%         %_%
echo.
echo   %gg_% Keyword%_%,%gg_% ky%_%    : Define a keyword that will be used to select an image to be used as a folder icon.
echo   %gg_% Scan%_%,%gg_% Sc%_%       : Scan and check which image will be selected as the folder icon for a specific folder.
echo   %gg_% Scans%_%,%gg_% Scs%_%     : Scan icluding all subfolders.
echo   %gg_% Template%_%,%gg_% Tp%_%   : Choose a template for folder icon.
echo   %gg_% Generate%_%,%gg_% Gn%_%   : Generate folder icon using the selected image defined by keyword.
echo   %gg_% Generates%_%,%gg_% Gns%_% : Generate including all subfolders.
echo   %gg_% Refresh%_%,%gg_% Rf%_%    : Refresh icon cache.
echo   %gg_% RefreshFc%_%,%gg_% Rfc%_% : Refresh icon cache using force methode, it will restart Explorer.
echo   %gg_% Search%_%,%gg_% Sr%_%     : Search a folder icon.
echo   %gg_% Remove%_%,%gg_% Rm %_%    : Remove all folder icon in current directory.
echo   %gg_% ON%_%             : Turn on all folder icon properties in current directory.
echo   %gg_% OFF%_%            : Turn off all folder icon properties in current directory.
echo   %gg_% O%_%              : Open current directory.
echo   %gg_% S%_%              : View current status.
echo   %gg_% R%_%              : Restart RCFI Tools.
echo   %gg_% CLS%_%            : Clear current command screen.
echo   %gg_% RCFI%_%           : Open the RCFI Tools directory.
echo   %gg_% Config%_%,%gg_% cfg %_%   : Open configurations menu.
echo   %gg_% Setup%_%          : Open the setup menu.
echo   %gg_% Activate, Act%_%  : Activate the Right Click Folder Icon Tools.
echo   %gg_% Deactivate, Dct%_%: Deactivate the Right Click Folder Icon Tools.
echo.
goto Options-Input

:Setup                            
if /i "%setup%" EQU "Deactivate" set "setup_select=2" &goto Setup-Choice
if exist "%RCFI%\resources\deactivating.RCFI" set "Setup=Deactivate" &set "setup_select=2" &goto Setup-Choice
if exist "%RCFID%" (
	for /f "useback tokens=1,2 delims=:" %%S in ("%RCFID%") do set /a "InstalledRelease=%%T" 2>nul
	call :Setup-Update
	exit /b
) else echo.&echo.&echo.&set "setup_select=1" &goto Setup-Choice
echo.&echo.&echo.
Goto Setup-Options

:Setup-Update
set /a "CurrentRelease=%version:v0.=%"
if %CurrentRelease% GTR %InstalledRelease% echo Need to update!
exit /b

:Setup-Options                    
echo.&echo.
echo               %i_%     %name% %version%     %_%
echo.
echo            %g_%Activate or Deactivate Folder Icon Tools on Explorer Right Click menus
echo            %g_%Press %gn_%1%g_% to %w_%Activate%g_%, Press %gn_%2%g_% to %w_%Deactivate%g_%, Press %gn_%3%g_% to %w_%Exit%g_%.%bk_%
echo.&echo.
choice /C:123 /N
set "setup_select=%errorlevel%"

:Setup-Choice                     
if "%setup_select%"=="1" (
	echo %g_%Activating RCFI Tools%_%
	set "Setup_action=install"
	set "HKEY=HKEY"
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v MultipleInvokePromptMinimum /t REG_DWORD /d 0x000003e8 /f >nul
	goto Setup_process
)
if "%setup_select%"=="2" (
	echo %g_%Deactivating RCFI Tools%_%
	set "Setup_action=uninstall"
	set "HKEY=-HKEY"
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v MultipleInvokePromptMinimum /t REG_DWORD /d 0x0000000f /f >nul
	goto Setup_process
)
if "%setup_select%"=="3" goto options
goto Setup-Options

:Setup_process                   
set "Setup_Write=%~dp0Setup_%Setup_action%.reg"
call :Setup_Writing
if not exist "%~dp0Setup_%Setup_action%.reg" goto Setup_error
echo %g_%Updating shell extension menu ..%_%
regedit.exe /s "%~dp0Setup_%Setup_action%.reg" ||goto Setup_error
del "%~dp0Setup_%Setup_action%.reg"

REM installing -> create "uninstall.bat"
if /i "%setup_select%"=="1" (
	echo cd /d "%%~dp0">"%RCFID%"
	echo set "Setup=Deactivate" ^&call "%name%" ^|^|pause^>nul :%version:v0.=%>>"%RCFID%"
	del /q "%RCFI%\#𝐏𝐀𝐒𝐒𝐖𝐎𝐑𝐃 𝟏𝟐𝟑𝟒" 2>nul
	echo %w_%%name% %version%  %cc_%Activated%_%
	echo %g_%Folder Icon Tools has been added to the right-click menus. %_%
	if not defined input (goto intro)
)

REM uninstalling -> delete "uninstall.bat"
if /i "%setup_select%"=="2" (
	del "%RCFI%\resources\deactivating.RCFI" 2>nul
	if exist "%RCFID%" del "%RCFID%"
	echo %w_%%name% %version%  %r_%Deactivated%_%
	echo %g_%Folder Icon Tools have been removed from the right-click menus.%_%
if /i "%Setup%"=="Deactivate" set "Setup=Deactivated"
)
if /i "%Setup%"=="Deactivated" %p5%&%p3%&exit
goto options

:Setup_error                      
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo            %r_%Setup fail.
echo            %w_%Permission denied.
set "setup="
set "context="
del "%RCFI%\Setup_%Setup_action%.reg" 2>nul
del "%RCFI%\resources\deactivating.RCFI" 2>nul
pause>nul&exit


:Setup_Writing                    
echo %g_%Preparing registry entry ..%_%

rem Escaping the slash using slash
	set "curdir=%~dp0_."
	set "curdir=%curdir:\_.=%"
	set "curdir=%curdir:\=\\%"

rem Multi Select, Separate instance
	set cmd=cmd.exe /c
	set "RCFITools=%~f0"
	set RCFIexe=^&call \"%RCFITools:\=\\%\"
	set SCMD=\"%curdir%\\resources\\SingleInstanceAccumulator.exe\" \"-c:cmd /c
	set SRCFIexe=^^^&set xSelected=$files^^^&call \"\"%RCFITools:\=\\%\"\"\"


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
	echo "MUIVerb"="Set as Folder Icon"
	echo "Icon"="shell32.dll,-16805"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Set.As.Folder.Icon\command]
	echo @="%cmd% set \"Context=IMG-Set.As.Folder.Icon\"%RCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Choose.and.Set.As
	echo [%RegExShell%\RCFI.IMG-Choose.and.Set.As]
	echo "MUIVerb"="Choose and Set as Folder Icon"
	echo "Icon"="shell32.dll,-270"
	echo [%RegExShell%\RCFI.IMG-Choose.and.Set.As\command]
	echo @="%cmd% set \"Context=IMG-Choose.and.Set.As\"%RCFIexe% \"%%1\""

	:REG-FI-IMAGE-Choose.Template
	echo [%RegExShell%\RCFI.IMG.Choose.Template]
	echo "MUIVerb"="Choose Template"
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
	echo "MUIVerb"="Generate Template Samples"
	echo "Icon"="imageres.dll,-1003"
	echo [%RegExShell%\RCFI.IMG.Template.Samples\command]
	echo @="%cmd% set \"Context=IMG.Template.Samples\"%RCFIexe% \"%%1\""
		
	:REG-FI-IMAGE-Convert
	echo [%RegExShell%\RCFI.IMG-Convert]
	echo "MUIVerb"="Convert Image"
	echo "Icon"="shell32.dll,-16826"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Convert\command]
	echo @="%SCMD% set \"Context=IMG-Convert\"%SRCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Resize
	echo [%RegExShell%\RCFI.IMG-Resize]
	echo "MUIVerb"="Resize Image"
	echo "Icon"="shell32.dll,-16826"
	echo [%RegExShell%\RCFI.IMG-Resize\command]
	echo @="%SCMD% set \"Context=IMG-Resize\"%SRCFIexe% \"%%1\""

	:REG-FI-IMAGE-Compress
	echo [%RegExShell%\RCFI.IMG-Compress]
	echo "MUIVerb"="Compress Image"
	echo "Icon"="shell32.dll,-16826"
	echo [%RegExShell%\RCFI.IMG-Compress\command]
	echo @="%SCMD% set \"Context=IMG-Compress\"%SRCFIexe% \"%%1\""

	REM Selected_Dir
	:REG-FI-Change.Folder.Icon
	echo [%RegExShell%\RCFI.Change.Folder.Icon]
	echo "MUIVerb"="Change Folder Icon"
	echo "Icon"="imageres.dll,-5303"
	echo [%RegExShell%\RCFI.Change.Folder.Icon\command]
	echo @="%cmd% set \"Context=Change.Folder.Icon\"%RCFIexe% \"%%V\""
	
	:REG-FI-Select.And.Change.Folder.Icon
	echo [%RegExShell%\RCFI.Select.And.Change.Folder.Icon]
	echo "MUIVerb"="Change Folder Icon"
	echo "Icon"="imageres.dll,-148"
	echo [%RegExShell%\RCFI.Select.And.Change.Folder.Icon\command]
	echo @="%Scmd% set \"Context=Select.And.Change.Folder.Icon\"%SRCFIexe% \"%%V\""
	
	:REG-FI.Search.Folder.Icon
	echo [%RegExShell%\RCFI.Search.Folder.Icon]
	echo "MUIVerb"="Search Folder Icon"
	echo "Icon"="shell32.dll,-251"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Search.Folder.Icon\command]
	echo @="%cmd% set \"Context=FI.Search.Folder.Icon\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Poster
	echo [%RegExShell%\RCFI.Search.Poster]
	echo "MUIVerb"="Search Poster"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Poster\command]
	echo @="%cmd% set \"Context=FI.Search.Poster\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Logo
	echo [%RegExShell%\RCFI.Search.Logo]
	echo "MUIVerb"="Search Logo"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Logo\command]
	echo @="%cmd% set \"Context=FI.Search.Logo\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Icon
	echo [%RegExShell%\RCFI.Search.Icon]
	echo "MUIVerb"="Search Icon"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Icon\command]
	echo @="%cmd% set \"Context=FI.Search.Icon\"%RCFIexe% \"%%V\""

	:REG-FI.Search.Folder.Icon.Here
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here]
	echo "MUIVerb"="Search Folder Icon"
	echo "Icon"="shell32.dll,-251"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here\command]
	echo @="%cmd% set \"Context=FI.Search.Folder.Icon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh
	echo [%RegExShell%\RCFI.Refresh]
	echo "MUIVerb"="Refresh Icon Cache (Restart Explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh\command]
	echo @="%cmd% set \"Context=Refresh\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh-No.Restart
	echo [%RegExShell%\RCFI.RefreshNR]
	echo "MUIVerb"="Refresh Icon Cache (Without Restart)"
	echo "Icon"="shell32.dll,-16739"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RefreshNR\command]
	echo @="%cmd% set \"Context=RefreshNR\"%RCFIexe% \"%%V\""
	
	:REG-FI-Choose.Template
	echo [%RegExShell%\RCFI.DIR.Choose.Template]
	echo "MUIVerb"="Choose Template"
	echo "Icon"="shell32.dll,-270"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.DIR.Choose.Template\command]
	echo @="%Scmd% set \"Context=DIR.Choose.Template\"%SRCFIexe% \"%%V\""
		
	:REG-FI-Scan
	echo [%RegExShell%\RCFI.Scan]
	echo "MUIVerb"="Scan"
	echo "Icon"="shell32.dll,-23"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Scan\command]
	echo @="%Scmd% set \"Context=Scan\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Define.Keyword
	echo [%RegExShell%\RCFI.DefKey]
	echo "MUIVerb"="Define keyword"
	echo "Icon"="shell32.dll,-242"
	echo [%RegExShell%\RCFI.DefKey\command]
	echo @="%scmd% set \"Context=DefKey\"%sRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Keyword
	echo [%RegExShell%\RCFI.GenKey]
	echo "MUIVerb"="Generate from Keyword"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey\command]
	echo @="%Scmd% set \"Context=GenKey\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG
	echo [%RegExShell%\RCFI.GenJPG]
	echo "MUIVerb"="Generate from *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
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
	
	:REG-FI-Activate_Folder_Icon
	echo [%RegExShell%\RCFI.ActivateFolderIcon]
	echo "MUIVerb"="Activate Folder Icon"
	echo "Icon"="imageres.dll,-166"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.ActivateFolderIcon\command]
	echo @="%Scmd% set \"Context=ActivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Deactivate_Folder_Icon
	echo [%RegExShell%\RCFI.DeactivateFolderIcon]
	echo "MUIVerb"="Deactivate Folder Icon"
	echo "Icon"="imageres.dll,-4"
	echo [%RegExShell%\RCFI.DeactivateFolderIcon\command]
	echo @="%Scmd% set \"Context=DeactivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Remove_Folder_Icon
	echo [%RegExShell%\RCFI.RemFolderIcon]
	echo "MUIVerb"="Remove Folder Icon"
	echo "Icon"="shell32.dll,-145"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RemFolderIcon\command]
	echo @="%Scmd% set \"Context=RemFolderIcon\"%SRCFIexe% \"%%V\""
	
	REM Background Dir
	:REG-FI-Refresh_here
	echo [%RegExShell%\RCFI.Refresh.Here]
	echo "MUIVerb"="Refresh Icon Cache (Restart Explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh.Here\command]
	echo @="%cmd% set \"Context=Refresh.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh_No_Restart_here
	echo [%RegExShell%\RCFI.RefreshNR.Here]
	echo "MUIVerb"="Refresh Icon Cache (Without Restart)"
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
	
	:REG-FI-Generate_Keyword_here
	echo [%RegExShell%\RCFI.GenKey.Here]
	echo "MUIVerb"="Generate from keyword"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey.Here\command]
	echo @="%cmd% set \"Context=GenKey.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG_here
	echo [%RegExShell%\RCFI.GenJPG.Here]
	echo "MUIVerb"="Generate from *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
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
	
	:REG-FI-Activate_Folder_Icon_here
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here]
	echo "MUIVerb"="Activate Folder Icons"
	echo "Icon"="imageres.dll,-166"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here\command]
	echo @="%cmd% set \"Context=ActivateFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Deactivate_Folder_Icon_here
	echo [%RegExShell%\RCFI.DeactivateFolderIcon.Here]
	echo "MUIVerb"="Deactivate Folder Icons"
	echo "Icon"="imageres.dll,-3"
	echo [%RegExShell%\RCFI.DeactivateFolderIcon.Here\command]
	echo @="%cmd% set \"Context=DeactivateFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Remove_Folder_Icon_here
	echo [%RegExShell%\RCFI.RemFolderIcon.Here]
	echo "MUIVerb"="Remove Folder Icons"
	echo "Icon"="shell32.dll,-145"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RemFolderIcon.Here\command]
	echo @="%cmd% set \"Context=RemFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Deactivate
	echo [%RegExShell%\RCFI.Deactivate]
	echo "MUIVerb"="             Deactivate %name%"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Deactivate\command]
	echo @="%cmd% set \"Context=FI.Deactivate\"%RCFIexe%"		
	
	:REG-FI-Edit.Template
	echo [%RegExShell%\RCFI.Edit.Template]
	echo "MUIVerb"="Template Configuration"
	echo "Icon"="imageres.dll,-69"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Edit.Template\command]
	echo @="%cmd% set \"Context=Edit.Template\"%RCFIexe%"
	
	:REG-FI-Edit.Config
	echo [%RegExShell%\RCFI.Edit.Config]
	echo "MUIVerb"="RCFI Tools Configuration"
	echo "Icon"="imageres.dll,-69"
	echo [%RegExShell%\RCFI.Edit.Config\command]
	echo @="%cmd% set \"Context=Edit.Config\"%RCFIexe%"
	
	:REG-FI-Ver.Context.Click
	echo [%RegExShell%\RCFI.Ver.Context.Click]
	echo "MUIVerb"="                 %name% %version%"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Ver.Context.Click\command]
	echo @="%cmd% set \"Context=Ver.Context.Click\"%RCFIexe%"
	
	:REG-Context_Menu-FI-Folder
	echo [%RegExDir%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.Select.And.Change.Folder.Icon;RCFI.RefreshNR;RCFI.DIR.Choose.Template;RCFI.Scan;RCFI.DefKey;RCFI.GenKey;RCFI.GenJPG;RCFI.GenPNG;RCFI.GenPosterJPG;RCFI.Search.Folder.Icon;RCFI.Search.Poster;RCFI.Search.Icon;RCFI.ActivateFolderIcon;RCFI.DeactivateFolderIcon;RCFI.RemFolderIcon"
	
	:REG-Context_Menu-FI-Background
	echo [%RegExBG%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.RefreshNR.Here;RCFI.Refresh.Here;RCFI.DIR.Choose.Template;RCFI.Search.Folder.Icon.Here;RCFI.Scan.Here;RCFI.DefKey;RCFI.GenKey.Here;RCFI.GenJPG.Here;RCFI.GenPNG.Here;RCFI.GenPosterJPG.Here;RCFI.ActivateFolderIcon.Here;RCFI.DeactivateFolderIcon.Here;RCFI.RemFolderIcon.Here;RCFI.Edit.Template;RCFI.Edit.Config;RCFI.Ver.Context.Click;"
	
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
exit /b