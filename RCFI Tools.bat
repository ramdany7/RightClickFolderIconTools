@echo off
chcp 65001 >nul
set name=RCFI Tools
set version=v0.01
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
if not defined OpenFrom echo                         %i_% %name% %version% %_%%-%&echo.
echo %TAB%          %pp_%Drag and  drop%_%%g_%  an %c_%image%g_%  to  this  window
echo %TAB%          then press Enter to change the folder icon.%_%
echo.
if not defined OpenFrom echo %ESC%%u_%%gg_%Template:%_%%cc_% %TemplateName%%gg_%     %u_%Keyword:%_% %printTagFI%%ESC%
goto Options-Input

:Status                           
%p1%
echo   %_%------- Status ----------------------------------------
echo   Directory           :%ESC%%u_%%cd%%-%%ESC%
echo   Target Folder Icon  : %printTagFI%
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
		pause>nul&exit
	)
	echo. &echo.
	if /i "%input%"=="Scan" (
		echo %TAB%%TAB%%g_%%processingtime% Press any key to close this window.
		pause >nul &exit
	)
	if /i "%cdonly%"=="true" (
		echo %TAB%%g_%%processingtime% This window will close in %ExitWait% sec.
		ping localhost -n %ExitWait% >nul&exit
	)
	if /i "%input%"=="Generate" (
		echo %TAB%%TAB%%g_%%processingtime% Press any key to close this window.
		pause >nul &exit
	)
	echo %TAB%%g_%%processingtime% This window will close in %ExitWait% sec.
	ping localhost -n %ExitWait% >nul&exit
)

:Options-Input                    
if not defined OpenFrom echo %_%%GG_%Keyword%G_%^|%GG_%Scan%G_%^|%GG_%Template%G_%^|%GG_%Generate%G_%^|%GG_%Refresh%G_%^|%GG_%RefreshFc%G_%^|%GG_%Search%G_%^|%GG_%ON%G_%^|^
%GG_%OFF%G_%^|%GG_%Remove%G_%^|%GG_%Config%G_%^|%GG_%Setup%G_%^|%GG_%RCFI%G_%^|%GG_%O%G_%^|%GG_%S%G_%^|%GG_%Help%G_%^|..
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
if /i "%Command%"=="template"	goto FI-Template
if /i "%Command%"=="template:"	goto Status 
if /i "%Command%"=="tp"			goto FI-Template
if /i "%Command%"=="Tes"			goto FI-Template-Sample
if /i "%Command%"=="s"			goto Status
if /i "%Command%"=="help"		goto Help
if /i "%Command%"=="cd.."		cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"==".."			cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%Command%"=="o"			echo %TAB%%_% Opening..   &echo %TAB%%ESC%%i_%%cd%%ESC% &explorer.exe "%cd%" &goto options
if /i "%Command%"=="rcfi"		echo %TAB%%_% Opening..   &echo %TAB%%ESC%%i_%%~dp0%ESC% &echo. &explorer.exe "%~dp0" &goto options
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
title %name% %version% ^| "%SelectedThing%"
set Dir=cd /d "%SelectedThing%"
set SetIMG=set "img=%SelectedThing%"
cls 
echo. &echo. &echo.
REM Selected Image
if /i "%Context%"=="IMG-Actions"				goto IMG-Actions
if /i "%Context%"=="IMG-Set.As.Folder.Icon"	cd /d "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput
if /i "%Context%"=="IMG-Choose.and.Set.As"		cd /d "%SelectedThingPath%" &set "input=%SelectedThing%"&set "RefreshOpen=Select" &goto DirectInput

if /i "%Context%"=="IMG.Choose.Template"		%setIMG%&goto FI-Template
if /i "%Context%"=="IMG.Edit.Template"			start "" notepad.exe "%template%"&exit
if /i "%Context%"=="IMG.Template.Samples"		%setIMG%&goto FI-Template-Sample-All
if /i "%Context%"=="IMG.Generate.icon"			goto IMG-Generate_icon
if /i "%Context%"=="IMG.Generate.PNG"			goto IMG-Generate_icon
if /i "%Context%"=="IMG-Set.As.Cover"			%setIMG%&goto IMG-Set_as_MKV_cover
if /i "%Context%"=="IMG-Convert"				goto IMG-Convert
if /i "%Context%"=="IMG-Resize"					goto IMG-Resize
REM Selected Dir	
if /i "%Context%"=="Change.Folder.Icon"		%Dir% &call :Config-Save	&set "Context="&set "OpenFrom=Context" &cls &echo.&echo.&echo.&goto Intro

if /i "%Context%"=="Select.And.Change.Folder.Icon" (
	if /i "%TemplateAlwaysAsk%"=="yes" (
		cls
		echo %g_%%i_% %_%%g_%'%r_%TemplateAlwaysAsk%g_%' feature is not available yet in this menu.%_%
		echo %g_%%i_% %_%%g_%so it will use "%cc_%%TemplateName%%g_%" as the template.%_%
		echo.
		echo.
		echo.
	)
	goto FI-Selected_folder
)

if /i "%Context%"=="DIR.Choose.Template"		goto FI-Template
if /i "%Context%"=="FI.Search.Folder.Icon"		goto FI-Search
if /i "%Context%"=="FI.Search.Poster"			goto FI-Search
if /i "%Context%"=="FI.Search.Folder.Icon.Here"	goto FI-Search
if /i "%Context%"=="Scan"						set "input=Scan" 			&set "cdonly=true" &goto FI-Scan
if /i "%Context%"=="DefKey"						goto FI-Keyword
if /i "%Context%"=="GenKey"						set "input=Generate"											&set "cdonly=true" &goto FI-Generate
if /i "%Context%"=="GenJPG"						set "input=Generate"		&set "Target=*.jpg" 				&set "cdonly=true" &goto FI-Generate
if /i "%Context%"=="GenPNG"						set "input=Generate"		&set "Target=*.png" 				&set "cdonly=true" &goto FI-Generate
if /i "%Context%"=="GenPosterJPG"				set "input=Generate"		&set "Target=*Poster*.jpg" 		&set "cdonly=true" &goto FI-Generate
if /i "%Context%"=="GenLandscapeJPG"			set "input=Generate"		&set "Target=*Landscape*.jpg"	&set "cdonly=true" &goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon"		set "RefreshOpen=Select"	&goto FI-Activate
if /i "%Context%"=="DeactivateFolderIcon"		set "RefreshOpen=Select"	&goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon"				set "delete=confirm"		&set "cdonly=true"				&goto FI-Remove
REM Background Dir	                         	
if /i "%Context%"=="DIRBG.Choose.Template"		goto FI-Template
if /i "%Context%"=="Scan.Here"					%Dir% &set "input=Scan" 			&goto FI-Scan
if /i "%Context%"=="GenKey.Here"				%Dir% &set "input=Generate"											&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenJPG.Here"				%Dir% &set "input=Generate"		&set "Target=*.jpg" 				&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPNG.Here"				%Dir% &set "input=Generate"		&set "Target=*.png" 				&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenPosterJPG.Here"			%Dir% &set "input=Generate"		&set "Target=*Poster*.jpg" 		&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="GenLandscapeJPG.Here"		%Dir% &set "input=Generate"		&set "Target=*Landscape*.jpg"	&set "cdonly=false" &goto FI-Generate
if /i "%Context%"=="ActivateFolderIcon.Here"	%Dir% &goto FI-Activate
if /i "%Context%"=="DeactivateFolderIcon.Here" %Dir% &goto FI-Deactivate
if /i "%Context%"=="RemFolderIcon.Here"		%Dir% &set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%Context%"=="Edit.Config"				start "" notepad.exe "%rcfi%\config.ini"&exit
if /i "%Context%"=="Ver.Context.Click"			echo %TAB%%_%Opening..   		&echo %TAB%%i_%%~dp0%-% &echo. &explorer.exe "%~dp0" &%p3%&exit
REM Other
if /i "%Context%"=="MKV.Cover-Delete"		goto MKV-Cover-Delete
if /i "%Context%"=="MKV.Subtitle-Merge"	goto MKV-Subtitle-Merge
if /i "%Context%"=="MKV.Extract"			goto MKV-Extract
if /i "%Context%"=="MP4.to.MKV"				goto MKV-Convert
if /i "%Context%"=="AVI.to.MKV"				goto MKV-Convert
if /i "%Context%"=="TS.to.MKV"				goto MKV-Convert
if /i "%Context%"=="SRT.Rename"				goto SUB-Rename
if /i "%Context%"=="ASS.Rename"				goto SUB-Rename
if /i "%Context%"=="XML.Rename"				goto SUB-Rename
if /i "%Context%"=="FI.Deactivate" 			set "Setup=Deactivate" &goto Setup
goto Input-Error


:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%
echo.
if defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Context%%_%
if not defined Context echo %ESC%%TAB%%TAB%%i_%%r_%%Command%%_%
echo.
echo %TAB%%g_%The command, file path, or directory path is unavailable. 
echo %TAB%Use %gn_%Help%g_% to see available commands.
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
for %%D in ("%cd%") do set "foldername=%%~nD%%~xD" &set "folderpath=%%~dpD"
if /i "%Direct%"=="Confirm" echo %TAB%%ESC%%yy_%📁 %foldername%%_%%ESC% &goto DirectInput-Generate-Confirm
if not exist desktop.ini echo %TAB%%ESC%%yy_%📁 %foldername%%_%%ESC% &goto DirectInput-Generate-Confirm
for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do set "%%C=%%D" 2>nul
if not exist "%iconresource%" echo %TAB%%ESC%%y_%📁 %foldername%%_%%ESC% &goto DirectInput-Generate-Confirm
echo %TAB%%ESC%%y_%📁 %foldername%%_%%ESC%
echo %TAB%%ESC%Folder icon:%c_%%iconresource%%ESC%
attrib -s -h "%iconresource%"
attrib |exit /b
echo.
echo %TAB% This folder already has a folder icon.
echo %TAB% Do you want to replace it^? %gn_%Y%_%/%gn_%N%bk_%
echo %TAB%%g_% Press %gg_%Y%g_% to confirm.%_%%bk_%
CHOICE /N /C YN
IF "%ERRORLEVEL%"=="2" (
	echo %_%%TAB% %I_%     Canceled     %_%
	attrib +s +h "%iconresource%"
	attrib -|exit /b
	goto options
)
IF "%ERRORLEVEL%"=="1" if defined Context cls &echo.&set "Direct=Confirm"&echo.&echo.&echo.&echo %TAB%%ESC%%yy_%📁 %foldername%%_%%ESC%
:DirectInput-Generate-Confirm     
set "ReplaceThis=%iconresource%"
attrib -s -h "%filepath%%filename%"
attrib |exit /b
if /i "%TemplateAlwaysAsk%"=="Yes" if /i not "%Already%"=="Asked" set "referer=FI-Generate"&call :FI-Template
if /i "%Context%"=="IMG-Choose.and.Set.As" if /i not "%Already%"=="Asked" set "referer=FI-Generate"&call :FI-Template
call :timer-start
call :FI-Generate-Folder_Icon
goto options

:FI-Selected_folder
set "input=_0"
set "cdonly=true"
set "context="
echo %TAB% %i_%  Change folder icon for selected folders.  %_%
echo %TAB% %_%--------------------------------------------------------------------%_%
for %%S in (%xSelected%) do (
	PUSHD "%%~fS" 2>nul &&echo %TAB% 📂%ESC%%%~nxS%ESC%
	POPD
)
echo %TAB% %_%--------------------------------------------------------------------%_%
echo %TAB% %g_%Template:%ESC%%cc_%%TemplateName%%ESC%
echo.
echo %g_%press %gn_%1%g_% then hit enter to change them separatly in each different window.%_%
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
set "context=FI-Selected_folder"
goto options

:FI-Selected_folder-input
if not exist "%input%" echo %g_%to enter the image path you can drag and drop the image here. then press enter. ^
 &echo %g_%------------------------------------------------------------------------------- ^
 &set /p "Input=%_%%w_%Enter the image path:%_%%c_%"
set "Input=%Input:"=%"
if "%input%"=="1" goto FI-Selected_folder-Separate
if not exist "%Input%" (
	echo.
	echo.
	echo %TAB% %_%Invalid path.
	echo %TAB%%ESC%%r_%%i_%%input%%ESC%
	echo %TAB% %g_%Make sure to enter a valid file path.%_%
	echo.
	echo.
	call :FI-Selected_folder-input
)
set "RefreshOpen=Select"
set "Selected="
for %%I in ("%input%") do (
	set "filename=%%~nxI"
	set "filepath=%%~dpI"
	set "fileext=%%~xI"
	)
for %%X in (%ImageSupport%) do (
	if "%%X"=="%fileext%" (
		echo.
		echo %TAB%%ESC%%yy_%📁 %FolderName%%_%%ESC%

			if defined iconresource if /i not "%replace%"=="all" (
				echo %TAB%%ESC%Folder icon:%c_%%iconresource%%ESC%
				attrib -s -h "%iconresource%"
				attrib |exit /b
				echo.
				echo %TAB% This folder already has a folder icon.
				echo %TAB% Do you want to replace it^? %gn_%A%_%/%gn_%Y%_%/%gn_%N%bk_%
				echo %TAB%%g_% Press %gg_%Y%g_% to confirm.%_%%g_% Press %gg_%A%g_% to confirm all.%k_%
				CHOICE /N /C AYN
				IF "%ERRORLEVEL%"=="1" set "replace=all"
				IF "%ERRORLEVEL%"=="3" (
					echo %_%%TAB% %I_%     Skip     %_%
					attrib +h "%iconresource%"
					attrib -|exit /b
					set "iconresource="
					exit /b
				)
				set "ReplaceThis=%iconresource%"
			)
			if not defined timestart call :Timer-start
			call :FI-Generate-Folder_Icon
		
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

:FI-Selected_folder-Separate
for %%S in (%xSelected%) do (
	PUSHD "%%~fS" 2>nul &&(
		start "" cmd.exe /c set "Context=Change.Folder.Icon"^&call "%~f0" "%%~fS"
	)
	POPD
)
exit

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
:FI-Scan                          
set "yy_result=0"
set "y_result=0"
set "g_result=0"
set "r_result=0"
set "success_result=0"
set "fail_result=0"
set "target=%target: =*%"
echo %TAB%%TAB%%cc_%%i_%  Scanning folder.. %-%
Echo %TAB%Keyword   : %target%
echo %TAB%Directory :%ESC%%cd%%ESC%
echo %TAB%%w_%==============================================================================%_%
call :timer-start
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
echo.
echo.

IF /i %result%		LSS 10 (set "s=   "		) else (IF /i %result%		GTR 9 set "s=  "		&IF /i %result%		GTR 99	set "s= "		&IF /i %result%		GTR 999 set "s="	)
IF /i %R_result%		LSS 10 (set "R_s=   "		) else (IF /i %R_result%		GTR 9 set "R_s=  "	&IF /i %R_result%		GTR 99	set "R_s= "	&IF /i %R_result%		GTR 999 set "R_s="	)		
IF /i %Y_result%		LSS 10 (set "Y_s=   "		) else (IF /i %Y_result%		GTR 9 set "Y_s=  "	&IF /i %Y_result%		GTR 99 set "Y_s= "	&IF /i %Y_result%		GTR 999 set "Y_s="	)		
IF /i %G_result%		LSS 10 (set "G_s=   "		) else (IF /i %G_result%		GTR 9 set "G_s=  "	&IF /i %G_result%		GTR 99 set "G_s= "	&IF /i %G_result%		GTR 999 set "G_s="	)		
IF /i %YY_result%		LSS 10 (set "YY_s=   "	) else (IF /i %YY_result%		GTR 9 set "YY_s=  "	&IF /i %YY_result%	GTR 99 set "YY_s= "	&IF /i %YY_result%	GTR 999 set "YY_s="	)		

echo %TAB%%s%%u_%%result% Folder found.%_%
IF /i %YY_result%		GTR 0 echo %TAB%%yy_%%YY_s%%YY_result%%_% Folder can be processed.
IF /i %R_result%		GTR 0 echo %TAB%%r_%%R_s%%R_result%%_% Folder icon is missing and can be changed.
IF /i %Y_result%		GTR 0 echo %TAB%%y_%%Y_s%%Y_result%%_% Folder already has an icon.
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% No file match "%c_%%Target%%_%" inside the folder.
IF /i %YY_result%		LSS 1 echo.&echo %TAB% Folder cantaining "%c_%%Target%%_%" couldn't be found.
echo.
echo   %g_%Note: If there is more than one file named "%target%" inside the folder, the one 
echo   selected as the folder icon will be the one that appear first in the folder.
set "result=0" &goto options

:FI-Scan-Desktop.ini              
	if "%locationCheck%"=="%location%" EXIT /B
PUSHD "%location%"
	set "locationCheck=%location%" &set "Selected="
	if not exist "desktop.ini" (
		if exist "%Target%" (
			if "%newline%"=="yes" echo.
			echo %TAB%%ESC%%yy_%📁 %foldername%%ESC%
			set /a YY_result+=1 
			call :FI-Scan-Find_Target
			POPD&EXIT /B
		)
		echo %TAB%%ESC%%g_%📁 %foldername%%ESC%
		set /a G_result+=1
		set "newline=yes"
		POPD&EXIT /B
	)
	if exist "desktop.ini" for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do set "%%C=%%D"
	if exist "desktop.ini" if not defined iconresource (
		if exist "%Target%" (
			if "%newline%"=="yes" echo.
			echo %TAB%%ESC%%yy_%📁 %foldername%%ESC%
			set /a YY_result+=1
			echo %TAB% - "desktop.ini" already exist, creating backup.. %r_%
			attrib -s -h "desktop.ini" &attrib |EXIT /B
			copy "desktop.ini" "desktop.shellinfo.ini" >nul||echo %TAB%     %r_%%i_% copy fail! %-%
			attrib +s +h "desktop.ini"
			call :FI-Scan-Find_Target
			POPD&EXIT /B
		)
		echo %TAB%%ESC%%g_%📁 %foldername%%ESC%
		set /a G_result+=1
		set "newline=yes"
		POPD&EXIT /B
	)
	if exist "desktop.ini" if not exist "%iconresource%" (
		if exist "%Target%" (
			if "%newline%"=="yes" echo.
			echo %TAB%%ESC%%r_%📁 %yy_%%foldername%%ESC%
			set /a R_result+=1
			echo %TAB%%ESC%Folder icon:%r_%%iconresource% %_%(Not Found!)%ESC%
			echo %TAB%%g_% This folder previously had a folder icon, but the icon file is missing.%_%
			echo %TAB%%g_% The icon will be replaced by the selected image.%_%
			call :FI-Scan-Find_Target
			set "iconresource="
			POPD&EXIT /B
		)
	echo %TAB%%ESC%%g_%📁 %foldername%%ESC%
	set /a G_result+=1
	set "newline=yes"
	POPD&EXIT /B
	)
	set "newline=yes"
	if exist "desktop.ini" if exist "%iconresource%" echo %TAB%%ESC%%y_%📁 %foldername%%ESC% &set /a Y_result+=1
	set "newline=yes"
	set "iconresource="
	if /i "%Context%"=="Create" call :FI-Scan-Find_Target
POPD&EXIT /B
rem if exist "desktop.shellinfo.ini" >desktop.ini type desktop.shellinfo.ini &>>desktop.ini echo Tes &>>desktop.ini echo Satu &>>desktop.ini echo dua &echo. &EXIT /B

:FI-Scan-Find_Target              
for %%F in (%target%) do (
	set "newline=no"
	set "Filename=%%~nxF"
	set "FilePath=%%~dpF"
	set "FileExt=%%~xF"
	if /i "%input%"=="Scan" call :FI-Scan-Display_Result
	if /i "%input%"=="Generate" call :FI-Generate-Folder_Icon
)
echo. &EXIT /B

:FI-Scan-Display_Result           
if not defined Selected (
	set "Selected=%Filename%" 
	echo %TAB%%ESC%%_%Selected Image:%c_%%Filename%%ESC%
)
EXIT /B

:FI-Generate                      
set "referer="
set "yy_result=0"
set "y_result=0"
set "g_result=0"
set "r_result=0"
set "success_result=0"
set "fail_result=0"

	echo %TAB%%TAB%%w_%%i_%  Generating folder icon..  %-%
	echo.
	echo %TAB%Keyword   :%ESC%%target%%ESC%
	if exist "%Template%" for %%T in ("%Template%") do (
	echo %TAB%Template  :%ESC%%cc_%%%~nT%ESC% 
	)
	echo %TAB%Directory :%ESC%%cd%%ESC%
	echo %TAB%%w_%==============================================================================%_%
if /i "%TemplateAlwaysAsk%"=="Yes" if /i not "%Already%"=="Asked" set "referer=FI-Generate"&call :FI-Template
call :timer-start
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
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
	echo %TAB%%w_%Couldn't find %target%
	echo %TAB%Make sure there is file ^(%target%^) inside selected folder.%_%
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

echo %TAB%%s%%u_%%result% Folder found.%_%
IF NOT "%YY_result%"=="%success_result%" IF /i %YY_result%		GTR 0 echo %TAB%%yy_%%YY_s%%YY_result%%_% Folder processed.
IF /i %R_result%		GTR 0 echo %TAB%%r_%%R_s%%R_result%%_% Folder icon changed.
IF /i %Y_result%		GTR 0 echo %TAB%%y_%%Y_s%%Y_result%%_% Folder already has an icon.
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% No file match "%c_%%Target%%_%" inside the folder.
IF /i %YY_result%		LSS 1 IF /i %success_result%	LSS 1 echo.&echo %TAB% ^(No folders to be procced.^)
IF /i %fail_result%	GTR 0 echo %TAB%%fail_s%%r_%%fail_result%%_% Folder icon failed to generate.
IF /i %success_result%	GTR 1 echo %TAB%%success_s%%cc_%%success_result%%_% Folder icon generated. 
echo %TAB%------------------------------------------------------------------------------
goto options

:FI-Generate-Folder_Icon          
if not defined Selected call :FI-ID
if not defined Selected (
	if not defined Context (
		set "inputfile=%filepath%%filename%" &set "OutputFile=%cd%\foldericon(%FI-ID%).ico"
		) else (
			set "inputfile=%filepath%%filename%" &set "OutputFile=%filepath%foldericon(%FI-ID%).ico"
			)
	)
if not defined Selected (
	
	rem Removing READ ONLY attribute, hopfully it will refresh folder icon 
	rem when it re added later "(?)"
	
	attrib -r "%cd%"
	attrib |exit /b
	
	rem Display "template" and "selected image"
	set "Selected=%Filename%" 
	echo %TAB%%ESC%%_%Selected Image:%c_%%Filename%%ESC%
	if /i "%cdonly%"=="true" echo %TAB%%ESC%Template: %cc_%%TemplateName%%ESC%%r_%
	
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
	
	rem Create desktop.ini and adding READ ONLY attribute to folder
	if exist "foldericon(%FI-ID%).ico" (
		echo  %g_%%TAB%%g_%Applying resources and attributes..%r_%
		if exist "desktop.ini" attrib -s -h "desktop.ini" &attrib |exit /b
		>Desktop.ini	echo ^[.ShellClassInfo^]
		>>Desktop.ini	echo IconResource=foldericon^(%FI-ID%^).ico
		>>Desktop.ini	echo ^;Folder Icon generated using %name% %version%.
		attrib +r "%cd%"
		attrib |exit /b	
	) else (echo %r_%%i_%Convert failed. %_%&set /a "fail_result+=1")
	
	rem Hiding "desktop.ini" and "foldericon.ico"
	if exist "desktop.ini" if exist "foldericon(%FI-ID%).ico" (
		ren "Desktop.ini" "desktop.ini.temp"
		ren "desktop.ini.temp" "desktop.ini"
		attrib +h "desktop.ini"
		attrib +h "foldericon(%FI-ID%).ico"
		attrib |exit /b
		echo %TAB% %i_%%g_%  Success!  %-% 
		set /a "success_result+=1"
		if defined ReplaceThis if exist "%ReplaceThis%" for %%R in ("%ReplaceThis%") do (
			if /i "%%~dpR"=="%cd%\" if /i "%%~xR"==".ico" del "%ReplaceThis%">nul&set "ReplaceThis="
		)
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




:FI-Template                      
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
PUSHD "%rcfi%\template"
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
	echo %TAB%%TAB%%gn_% S%_% ^> %w_%See all sample icons, using:%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
) else (echo %TAB%%TAB%%gn_% S%_% ^> %w_%See all sample icons%_%)
echo.
echo %g_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
goto FI-Template-Input

:FI-Template-Input
rem Input template options
set "TemplateChoice=NotSelected"
set /p "TemplateChoice=%_%%w_%%TAB%%TAB%Select option:%_%%gn_%"
if /i "%TemplateChoice%"=="NotSelected" echo %_%%TAB%   %i_%  CANCELED  %-%&%p2%&goto options
if /i "%TemplateChoice%"=="r" cls&echo.&echo.&echo.&goto FI-Template
if /i "%TemplateChoice%"=="s" set "act=FI-Template-Sample-All"	&set "FITSA=%TemplateSampleImage%"&start "" "%~f0"&cls&echo.&echo.&echo.&goto FI-Template

rem Process valid selected options
set "TSelector=Select"&set "TCount=0"
PUSHD "%rcfi%\template"
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
if /i "%referer%"=="FI-Generate" (
	set "Already=Asked"
	echo.&echo.
	if defined Context (cls &goto Input-Context) else (if exist "%input%" (set "Direct=Confirm"&goto DirectInput) else goto FI-Generate)
) else (
	call :Config-Save
)
goto options

:FI-Template-Get_List             
if /i "%Tselector%"=="GetList" if "%TemplateName%"=="%TName%" (set TNameList=%ESC%%cc_%%TName%%_%%ESC%) else set TNameList=%ESC%%w_%%TName%%_%%ESC%
if /i "%Tselector%"=="GetList" (
	if %TCount% LSS 10 echo %TAB%%TAB% %gn_%%TCount%%_% ^>%TNameList%
	if %TCount% GTR 9  echo %TAB%%TAB%%gn_%%TCount%%_% ^>%TNameList%
	exit /b
	)
set "_info="
if /i "%TSelector%"=="Select" (
	if /i not "%TCount%"=="%TemplateChoice%" exit /b
	if defined Context cls &echo.&echo.&echo.&echo.
	set "Template=%TFullPath%"
	if /i not	"%referer%"=="FI-Generate" (
		rem Display Template info.
		echo.
		echo   %_%%ESC%%cc_%  %TName%%_% selected.%ESC%
		%p1%
		for /f "usebackq tokens=1,2 delims=`" %%I in ("%TFullPath%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
		%p2%
	)
	set "TemplateChoice=Selected"
	)
	if /i "%TemplateTestMode%"=="yes" (
	call :Config-Save
	call :FI-Template-TestMode-TnameX_forfiles_resolver
	set "Ttest="
	set "referer=FI-Template"
	set "inputfile=%TemplateSampleImage%"
	set "OutputFile=%rcfi%\Template\sample\%TName%.ico"
	cls
	goto FI-Template-TestMode
	)
exit /b


:FI-Template-Sample               
if /i "%referer%"=="FI-Generate" exit /b
call :Config-UpdateVar
if not exist "%rcfi%\template\sample" md "%rcfi%\template\sample"
set "inputfile=%TemplateSampleImage%"
set "OutputFile=%rcfi%\Template\sample\%TName%.ico"
if /i "%Context%"=="IMG.Choose.Template" set "inputfile=%img%"
REM if /i "%testmode%"=="yes" set "AlwaysGenerateSample=No"

if exist "%OutputFile%" del "%OutputFile%"

echo.&echo.
echo %i_%%g_%  Generating sample preview.. %-%
echo %g_%Selected Template:%ESC%%cc_%%TName%%ESC%%r_%
for %%I in ("%inputfile%") do set "TSampleName=%%~nxI"&set "TSamplePath=%%~dpI"
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
echo %TAB%"%rcfi%\template\sample\"
echo.
if not exist "%rcfi%\template\sample" md "%rcfi%\template\sample"
pushd "%rcfi%\template\sample"
	for %%I in (*.ico) do del "%%~fI"
popd
set /a TCount=0
PUSHD "%rcfi%\template"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TSampling=%%~fT"
		call :FI-Template-Sample-All-Generate
	)
POPD
echo %TAB%%i_%%yy_%   Done!   %_%
if /i "%Context%"=="IMG.Template.Samples" (
	md "%rcfi%\template\sample\montage" 2>nul
	for /f "tokens=*" %%I in ('dir /b "%rcfi%\template\sample\*.ico"') do (
		"%converter%" "%rcfi%\template\sample\%%~nxI" -define icon:auto-resize="256" "%rcfi%\template\sample\montage\%%~nI.ico"
	)
	"%montage%" -pointsize 3 -label "%%f" -density 300 -tile 4x0 -geometry +3+2 -border 1 -bordercolor rgba^(210,210,210,0.3^) -background rgba^(255,255,255,0.4^) "%rcfi%\template\sample\montage\*.ico" "%~dpn1-Folder_Samples.png"
	explorer.exe "%~dpn1-Folder_Samples.png"
	rd /s /q "%rcfi%\template\sample\montage" 
) else explorer.exe "%rcfi%\template\sample\"
goto options

:FI-Template-Sample-All-Generate  
set "inputfile=%FITSA%"
set "OutputFile=%rcfi%\template\sample\%TName%.ico"
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

for %%I in ("%inputfile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%inputfile%%ESC%

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

for %%I in ("%inputfile%") do (
	set "size_b=%%~zI"
	call :FileSize
	)
echo  %_%Sample image  :%ESC%%c_%%TSampleName%%g_% (%pp_%%size%%g_%)%ESC%
echo %ESC%%g_%%inputfile%%ESC%

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



:FI-Search                        
set "PreAppliedKeywordFolder=folder icon site:deviantart.com OR site:freeiconspng.com OR site:iconarchive.com OR site:icon-icons.com OR site:pngwing.com OR site:iconfinder.com OR site:icons8.com OR site:pinterest.com OR site:pngegg.com&tbm=isch&tbs=ic:trans"
set "PreAppliedKeywordPoster=poster site:themoviedb.org OR site:imdb.com OR site:impawards.com OR site:fanart.tv OR site:myanimelist.net OR site:anidb.net&tbm=isch&tbs=isz:l"
set "PreAppliedKeyword=%PreAppliedKeywordFolder%"
if /i "%Context%"=="FI.Search.Folder.Icon" (set "SrcInput=%~nx1"&goto FI-Search-Input)
if /i "%Context%"=="FI.Search.Poster" (set "SrcInput=%~nx1"&set "PreAppliedKeyword=%PreAppliedKeywordPoster%"&goto FI-Search-Input)
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
if /i "%Context%"=="FI.Search.Folder.Icon" exit
if /i "%Context%"=="FI.Search.Poster" exit
goto FI-Search

:FI-Keyword                       
echo %TAB%%g_%Current keyword:%ESC%%c_%%Keyword%%ESC%%_%
echo %TAB%%g_%This keyword will be used to search for file names to generate folder icons.%_%
set "newKeyword=*"
echo.
set /p "newKeyword=%-%%-%%-%%w_%Change keyword:%c_%"
if "%newKeyword%"=="*" set "newKeyword=%Keyword%"
set "Keyword=%newKeyword%"
echo. &echo. &echo.
for %%X in (%ImageSupport%) do (
	if /i "%%X"=="%Keyword:~-4%" (
		call set "Keyword=%%Keyword:%keyword:~-4%=%%"
		set "Keyword-Extension=%keyword:~-4%"
		goto FI-Keyword-Selected
	)
	if /i "%%X"=="%Keyword:~-5%" (
		call set "Keyword=%%Keyword:%keyword:~-5%=%%"
		set "Keyword-Extension=%keyword:~-5%"
		goto FI-Keyword-Selected
	)
)
echo %TAB%%_%%g_%Current extension: %c_%%Keyword-Extension%%_%
echo %TAB%%g_%During the generation process, matched file name and file extension will be
echo %TAB%%g_%automatically converted into .ico format and set as the folder icon.
echo.
echo %TAB%%w_%Select extention:
echo %TAB%%gn_%  1%_% ^> %c_%.Png%_%
echo %TAB%%gn_%  2%_% ^> %c_%.Jpg%_%
echo %TAB%%gn_%  3%_% ^> %c_%.Ico%_%
echo %TAB%%gn_%  4%_% ^> %c_%.webp%_%
echo %TAB%%gn_%  5%_% ^> %c_%.svg%_%
echo %TAB%%gn_%  6%_% ^> %c_%.bmp%_%
echo %TAB%%gn_%  7%_% ^> %c_%.tiff%_%
echo %TAB%%gn_%  8%_% ^> %c_%.heic%_%
echo %TAB%%gn_%  9%_% ^> %c_%.jpeg%_%
echo.
echo %TAB%%g_%to select, just press the number assosiated to the options.%_%
CHOICE /N /C 123456789
	IF "%ERRORLEVEL%"=="1" set "Keyword-Extention=.png"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="2" set "Keyword-Extention=.jpg"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="3" set "Keyword-Extention=.ico"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="4" set "Keyword-Extention=.webp"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="5" set "Keyword-Extention=.svg"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="6" set "Keyword-Extention=.bmp"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="7" set "Keyword-Extention=.tiff"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="8" set "Keyword-Extention=.heic"	&goto FI-Keyword-Selected
	IF "%ERRORLEVEL%"=="9" set "Keyword-Extention=.jpeg"	&goto FI-Keyword-Selected
echo.
echo %TAB%%_%%i_%  Invalid selection.  %-%
echo.
goto options
:FI-Keyword-Selected              
call :Config-Save
call :Config-UpdateVar
if "%Context%"=="DefKey" (
	cls &echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
	echo %TAB%%TAB%%TAB%%TAB%%_%%ESC%%printTagFI%%ESC% will be use to generate folder icon.
	ping localhost -n 3 >nul
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
echo       %_%%r_%Continue to Remove (%y_%%result%%_%%r_%^) folder icon^?%-% 
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
if exist "%rcfi%\resources\refresh." (if defined Context exit else goto options) else (echo    refreshing .. >>"%rcfi%\resources\refresh.")
if /i not "%Context%"=="" echo.&echo.&echo.
echo %_%%g_%%TAB%Note: In case if the process gets stuck and explorer doesn't come back.
echo %TAB%Hold %i_% CTRL %_%%g_%+%i_% SHIFT %_%%g_%+%i_% ESC %_%%g_%%-% %g_%^> Click File ^> Run New Task ^> Type "explorer" ^> OK.
echo %TAB%%cc_%Restarting Explorer and updating icon cache ..%r_%
echo.&set "startexplorer="
rem ie4uinit.exe -ClearIconCache
rem ie4uinit.exe -show
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
set "WaitRefreshDelay= echo %g_%  if the folder icon hasn't changed yet, Please&echo   wait for 30-40 seconds then refresh again.%_%"
if defined Context echo.
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
		attrib +h 		"desktop.ini"
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
			attrib +h 		"desktop.ini"
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
echo. &echo. &ping localhost -n 2 >nul
del "%rcfi%\resources\refresh." 2>nul
if exist "%rcfi%\resources\refresh." (
	echo   %r_%Fail to delete "refresh." in main directory!
	echo   %_%"%RCFI%"
	echo   %r_%Permission denied%_%
	pause
)
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
call :timer-start
if /i "%TemplateAlwaysAsk%"=="Yes" if /i not "%already%"=="Asked" set "referer=FI-Generate"&goto FI-Template
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
	call :FileSize
	Call :IMG-Generate_icon-FileList	
	call :IMG-Generate_icon-Act
	call :IMG-Generate_icon-Done
)
echo %TAB%%_%----------------------------------------------------%_%
echo.
echo %TAB%%g_%%i_%  Done!  %_%
goto options

:IMG-Generate_icon-FileList
if "%IMGext%"==".ico" set "IMGext=%y_%%IMGext%"
echo %_%%TAB%-%ESC%%c_%%IMGname%%bb_%%IMGext% %g_%(%pp_%%size%%g_%)%ESC%%r_%
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
			call :FileSize
			call :IMG-Generate_icon-FileList
		)
	) else (echo %TAB%%r_%Generate icon fail!)
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
set "ImgOutput=%ImgName%%ImgExtNew%"
"%converter%" "%ImgPath%%ImgName%%ImgExt%" %convertcode% "%ImgPath%%ImgOutput%"

if "%ImgExt%"==".ico" (
	PUSHD "%ImgPath%"
	if exist "%ImgName%-*%ImgExtNew%" (
		echo.
		echo %TAB%    %_%The icon file contains multiple resolution resources.
		for /f %%G in ('dir /b "%ImgName%-*%ImgExtNew%"') do (
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
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExtNew%%g_% (%r_%Convert Fail!%g_%)%_%
	exit /b
)
if %Size_B% LSS 100 (
	echo %TAB% %r_%Convert Fail!%_%
	del "%ImgPath%%ImgOutput%"
)
exit /b

:IMG-Resize                       
if not exist "%RCFI%\resizer.ini" (
	(
	echo.
	echo     [  IMAGE RESIZER CONFIG  ]
	echo.
	echo IMGResize1Tag="_256p"
	echo IMGResize1Name="256p"
	echo IMGResize1Code="-resize x256  -quality 100"
	echo.
	echo IMGResize2Tag="_512p"
	echo IMGResize2Name="512p"
	echo IMGResize2Code="-resize x512  -quality 100"
	echo.
	echo IMGResize3Tag="_720p"
	echo IMGResize3Name="720p"
	echo IMGResize3Code="-resize x720  -quality 95"
	echo.
	echo IMGResize4Tag="_1080p"
	echo IMGResize4Name="1080p"
	echo IMGResize4Code="-resize x1080  -quality 95"
	echo.
	echo IMGResize5Tag="_1440p"
	echo IMGResize5Name="1440p"
	echo IMGResize5Code="-resize x1440  -quality 95"
	echo.
	echo IMGResize6Tag="_2160p"
	echo IMGResize6Name="2160p"
	echo IMGResize6Code="-resize x2160  -quality 95"
	echo.
	echo IMGResize7Tag="_3240p"
	echo IMGResize7Name="3240p"
	echo IMGResize7Code="-resize x3240  -quality 95"
	)>"%RCFI%\resizer.ini"
)
set separator=echo %TAB% %_%--------------------------------------------------------------------%_%
if not defined Action echo %TAB%       %i_%%w_%    IMAGE RESIZER    %_%&%separator%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%       %i_%%cc_%    IMAGE CONVERTER    %_%
	%separator%
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
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
for /f "usebackq tokens=1,2 delims==" %%C in ("%RCFI%\resizer.ini") do (set "%%C=%%D")
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
if /i "%ImgSizeInput%"=="1" set "ImgResizeCode=%IMGResize1Code%"&set "ImgTag=%IMGResize1Tag%" 
if /i "%ImgSizeInput%"=="2" set "ImgResizeCode=%IMGResize2Code%"&set "ImgTag=%IMGResize2Tag%"
if /i "%ImgSizeInput%"=="3" set "ImgResizeCode=%IMGResize3Code%"&set "ImgTag=%IMGResize3Tag%"
if /i "%ImgSizeInput%"=="4" set "ImgResizeCode=%IMGResize4Code%"&set "ImgTag=%IMGResize4Tag%"
if /i "%ImgSizeInput%"=="5" set "ImgResizeCode=%IMGResize5Code%"&set "ImgTag=%IMGResize5Tag%"
if /i "%ImgSizeInput%"=="6" set "ImgResizeCode=%IMGResize6Code%"&set "ImgTag=%IMGResize6Tag%"
if /i "%ImgSizeInput%"=="7" set "ImgResizeCode=%IMGResize7Code%"&set "ImgTag=%IMGResize7Tag%"
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options
	
echo %TAB%%g_%Input your own  command, example: %yy_%-resize 720x720  -quality 80%g_%  it will resize the
echo %TAB%image to 720x720 pixels and compress the quality to 80%%. You can also specify only
echo %TAB%a width or a height of the image,  example: %yy_%-resize 1000x%g_% it will resize the image 
echo %TAB%to a width of 1000p or %yy_%-resize x1000%g_% to resize it to a height of 1000p.
echo.
set /p "ImgResizeCode=%-%%-%%-%%w_%Input:%yy_%"
set "ImgResizeCode=%ImgResizeCode:"=%"
set "ImgTag=_(%IMGResizeCode%)"
call :timer-start
set "Action=Start" &cls&goto IMG-Resize

:IMG-Resize-Action                
set size_B=1
set "ImgOutput=%ImgName%%ImgTag%%ImgExt%"
"%converter%" "%ImgPath%%ImgName%%ImgExt%" %ImgResizeCode% "%ImgPath%%ImgOutput%"
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
	echo %TAB%%ESC%- %c_%%ImgName%%cc_%%ImgTag%%c_%%ImgExt%%g_% (%pp_%%size%%g_%)%ESC%%r_%
) else (
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	del "%ImgPath%%ImgOutput%"
	exit /b
)
exit /b


:MKV-Cover-Delete
call :timer-start
echo %TAB%    %i_%  Deleting MKV Cover..  %_%
echo.
FOR %%K in (%xSelected%) do (
	echo %TAB%%c_%🎞%ESC%%c_%%%~nxK%ESC%
	PUSHD "%%~dpK" || echo %i_%%r_%  FAIL to PUSHD..  %_%
		"%MKVPROPEDIT%" "%%~nxK"	--delete-attachment name:cover.jpg  --delete-attachment name:cover.png ^
									--delete-attachment name:cover.jpeg --delete-attachment name:cover.gif ^
									--delete-attachment name:cover.tiff --delete-attachment name:cover.webp ^
									--delete-attachment name:cover.bmp --delete-attachment name:cover.svg ^
									--delete-attachment name:cover >nul
		MKVPROPEDIT.exe |exit /b
	POPD
)
echo.
echo %TAB%   %i_%%cc_%  Done!  %_%
goto options

:MKV-Convert
call :timer-start
echo %TAB%    %i_%  Converting to MKV..  %_%
echo.
for %%M in (%xSelected%) do (
	for %%X in (%VideoSupport%) do (
		if /i "%%~xM"=="%%X" (
			set "MP4name=%%~nxM"
			set "size_B=%%~zM"
			set "display=NOTMKV"
			call :FileSize
			call :MKV-Convert-display
			PUSHD "%%~dpM" || echo %i_%%r_%  FAIL to PUSHD..  %_%
				start /wait "%%~nxM" cmd.exe /c echo.^&echo.^&echo. ^
				^&echo %TAB%%cc_%Converting..%_% ^
				^&echo  "%c_%%%~nxM%_%"%gg_% ^
				^&"%MKVmerge%" -o "%%~nM.mkv" "%%~nxM"
			POPD
			if exist "%%~dpnM.mkv" (
				for %%K in ("%%~dpnM.mkv") do (
					set "MKVname=%%~nxK"
					set "size_B=%%~zK"
					set "display=MKV"
					call :FileSize
					call :MKV-Convert-display
				)
			) else (echo %TAB%%r_%%i_%Convert Fail!%_% "%%~nxM")
		)
	)
)
echo.
echo %TAB%   %i_%%cc_%  Done!  %_%
goto options

:MKV-Convert-display
if "%display%"=="MKV" (
	echo %TAB%%c_%🎞%ESC%%MKVname% %pp_%%size%%_% %g_%(%size_B% Bytes)%ESC%
) else (
	echo %TAB%%gg_%🎞%ESC%%MP4name% %pp_%%size%%_% %g_%(%size_B% Bytes)%ESC%
)
exit /b

:MKV-Subtitle-Merge
set MKVMergeSeparator=echo %_%-------------------------------------------------------------------------%_%
echo %TAB%    %i_%  Merging subtitle into MKV..  %_%
echo.
REM Detecting font..
for %%S in (%xSelected%) do (set "MKVpath=%%~dpS")
cd /d "%MKVpath%"
call :MKV-Subtitle-Font
echo.

REM Get MKV List
for %%S in (%xSelected%) do (
	if /i "%%~xS"==".mkv" (
		set "MKVname=%%~nS"
		set "MKVdir=%%~dpS__"
		set "size_B=%%~zS"
		call :FileSize
		call :MKV-Subtitle-merge_process
	)
)
echo       %_%%i_%   Done!   %_%
goto options

:MKV-Subtitle-merge_process
set "MKVDisplay=yes"
set MKVfileDisplay=%c_%🎞%ESC%%c_%%MKVname%.mkv%_% %pp_%%size% %g_%(%size_B% Bytes)%ESC%
set MKVfileDisplay_=%c_%🎞%ESC%%c_%%MKVname%.mkv%_% %pp_%%size% %g_%(%size_B% Bytes)%ESC%
PUSHD "%MKVdir:\__=%" || echo %i_%%r_% PUSH DIRECTORY FAIL! -^>%_%"%MKVdir%"

REM Search subtitle
set /a Found=0
for %%X in (%SubtitleSupport%) do (

	REM Search Sub with the same name.

	if exist "%MKVname%.%%X" (
		set /a Found+=1
		set "subLang=%subLanguage%"
		set "subFound=%MKVname%.%%X"
		call :MKV-Subtitle-display_sub
		set subtitleSet= ^
		--language			0:%subLanguage% ^
		--track-name		0:"%SubName%" ^
		--default-track	0:%SubSetAsDefault% ^
		--forced-display-flag 0:%SubForcedDisplay% ^
		"%MKVname%.%%X" 
	)

	REM Search Sub with the same name with language Tag.

	for %%S in ("%MKVname%__*.%%X") do (
		set /a Found+=1
		set "subFormat=.%%X"
		set "subFound=%%S"
		set "subLang=%%S"
		call :MKV-Subtitle-get_language
		call :MKV-Subtitle-display_sub
	)
)

if %Found% LSS 1 (
	%MKVMergeSeparator%
	echo %MKVfileDisplay_%
	echo %r_%📄 %g_%No subtitles matched the MKV file name.%_%
	%MKVMergeSeparator%
	echo.&echo.
	POPD&exit /b
)

echo %_%Subtitle found ^(%gn_%%Found%%_%^), %_%Adding subtitle into MKV ..%g_%
"%MKVMERGE%" -o "%MKVname%_subs.mkv" "%MKVname%.mkv" %subtitleSet%
if exist "%MKVname%.xml" (
	echo %_%Chapters found: "%MKVname%.xml"
	set AddChapters=--chapters "%MKVname%.xml"
	)
if exist "%MKVname%_subs.mkv" if defined AddFonts (
	echo %_%Fonts found ^(%gn_%%FontFound%%_%^), Adding fonts and chapters into MKV ..%g_%
	"%MKVPROPEDIT%" "%MKVname%_subs.mkv" %AddFonts% %AddChapters%
	if defined AddFonts1 "%MKVPROPEDIT%" "%MKVname%_subs.mkv" %AddFonts1% >nul
	if defined AddFonts2 "%MKVPROPEDIT%" "%MKVname%_subs.mkv" %AddFonts2% >nul
	if defined AddFonts3 "%MKVPROPEDIT%" "%MKVname%_subs.mkv" %AddFonts3% >nul
	if defined AddFonts4 "%MKVPROPEDIT%" "%MKVname%_subs.mkv" %AddFonts4% >nul
)

if exist "%MKVname%_subs.mkv" (
	for %%O in ("%MKVname%_subs.mkv") do (
		set "size_B=%%~zO" 
		call :FileSize
	)
)
if exist "%MKVname%_subs.mkv" echo %cc_%Success: %cc_%🎞%ESC%%cc_%%MKVname%%cc_%_subs%cc_%.mkv%_% %pp_%%size% %g_%(%size_B% Bytes)%ESC%
if not exist "%MKVname%_subs.mkv" echo %r_%Fail!%_% %g_%Make sure it has a valid "name" and a valid "language id".%_%
echo.&echo.
POPD&exit /b

:MKV-Subtitle-display_sub
%MKVMergeSeparator%
for %%F in ("%subFound%") do (
	set "size_B=%%~zF"
	call :FileSize
)
if /i "%MKVDisplay%"=="yes" if found GEQ 1 echo %MKVfileDisplay%
if /i "%MKVDisplay%"=="yes" if found LSS 1 echo %MKVfileDisplay_%
set "MKVDisplay=no"
echo %yy_%📄%ESC%%yy_%%subFound%%_% %pp_%%size% %g_%(%size_B% Bytes)%_%%ESC%
echo %ESC%  %g_%Name:%w_%%SubName%	%g_%Language:%w_%%subLang%	%g_%Default:%w_%%SubSetAsDefault%	%g_%Force:%w_%%SubForcedDisplay%%ESC%
%MKVMergeSeparator%
exit /b

:MKV-Subtitle-get_language
call set "subLang=%%Sublang:%MKVname%__=%%"
call set "subLang=%%Sublang:%SubFormat%=%%"
set subtitleSet= %subtitleSet%^
	--language			0:"%subLang%" ^
	--track-name		0:"%SubName%" ^
	--default-track	0:"%SubSetAsDefault%" ^
	"%subFound%"
exit /b

:MKV-Subtitle-Font
set "FontFound=0"
if exist "fonts" (
	PUSHD "fonts"
		for %%F in (*.ttf,*.otf) do (
			set /a FontFound+=1
			set "Font=%%~fF"
			call :MKV-Subtitle-Font-Collect
		)
	POPD
)
if %FontFound% GEQ 1 (
	echo %_%Fonts detected%ESC%(%gg_%%FontFound%%_%).%ESC%
	echo Fonts will be added into MKV.
)
exit /b

:MKV-Subtitle-Font-Collect
if %fontfound% GEQ 200 (
	set AddFonts4=%AddFonts4% --add-attachment "%Font%"
	exit /b
	)
if %fontfound% GEQ 150 (
	set AddFonts3=%AddFonts3% --add-attachment "%Font%"
	exit /b
	)
if %fontfound% GEQ 100 (
	set AddFonts2=%AddFonts2% --add-attachment "%Font%"
	exit /b
	)
if %fontfound% GEQ 50 (
	set AddFonts1=%AddFonts1% --add-attachment "%Font%"
	exit /b
	)
set AddFonts=%AddFonts% --add-attachment "%Font%"
exit /b



:MKV-Extract
echo %TAB%    %i_%  Extracting MKV..  %_%
echo.
for %%S in (%xSelected%) do (set "MKVpath=%%~dpS")
cd /d "%MKVpath%"
echo.

REM Get MKV List
for %%S in (%xSelected%) do (
	if /i "%%~xS"==".mkv" (
		set "MKVname=%%~nS"
		set "MKVdir=%%~dpS__"
		set "MKVpath=%%~fS"
		set "size_B=%%~zS"
		call :FileSize
		call :MKV-Extract-Info
	)
)
echo       %_%%i_%   Done!   %_%
goto options

:MKV-Extract-Info
echo %TAB%%ESC%%c_% %MKVname%.mkv %g_%(%pp_%%size%%g_%)%ESC%
for /f "tokens=1,2,3,4 delims=:" %%C in ('call "%MKVinfo%" "%MKVpath%"') do (
	echo "[C]"%%C "[D]"%%D "[E]"%%E "[F]"%%F
)
echo.
exit /b



:SUB-Rename
cd /d "%SelectedThingPath%"
For %%V in (*.mkv, *.mp4) do (
	set /a "MKVcount+=1"
	set "VidN=%%~nV"
	set "VidNX=%%~nxV"
	set "VidX=%%~xV"
)
if not defined MKVcount echo %TAB%%r_%Video files not found.&goto options
set "SubtitleVid=%VidN%%~x1"
set "Subtitle=%~nx1"
set "SubtitleX=%~x1"
if %mkvcount% EQU 1 (
	echo.
	echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%Subtitle%%ESC%
	echo %TAB%%w_%🎞  Video   :%ESC%%c_%%VidNX%%ESC%
	echo.
	if not exist "%SubtitleVid%" (
		ren "%Subtitle%" "%SubtitleVid%"
		if exist "%SubtitleVid%" (
			echo %TAB%    %gn_%Subtitle rename successful.%_%
			echo %TAB%📄%ESC%%SubtitleVid%%ESC%
			goto options
		) else (
			echo %TAB%    %r_%Subtitle rename failed.%_%
			echo %TAB%📄%ESC%%SubtitleVid%%ESC%
			goto options
		)
	) else (
			echo %TAB%    %w_%Subtitle already exists.%_%
			echo %TAB%📄%ESC%%SubtitleVid%%ESC%
			goto options
	)
)
echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%Subtitle%%ESC%
echo.
echo %TAB%Please select which video to rename this subtitle to.
set "MKVcount="
set "SubVid=List"
For %%V in (*.mkv, *.mp4) do (
	set /a "MKVcount+=1"
	set /a "MKVTotal+=1"
	set "VidN=%%~nV"
	set "VidNX=%%~nxV"
	set "VidX=%%~xV"
	call :SUB-Rename-List
)
echo.

if %mkvcount% LSS 10 echo %g_%%TAB%to select, just press the number assosiated to the options.%_%
if %mkvcount% GTR 9 echo %g_%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
:SUB-Rename-Input
set "SubVid=Selecting"&set "SubVidInput=0"
if %mkvcount% LSS 10 CHOICE /N /C 123456789
	IF "%ERRORLEVEL%"=="1" set "SubVidInput=1"
	IF "%ERRORLEVEL%"=="2" set "SubVidInput=2"
	IF "%ERRORLEVEL%"=="3" set "SubVidInput=3"
	IF "%ERRORLEVEL%"=="4" set "SubVidInput=4"
	IF "%ERRORLEVEL%"=="5" set "SubVidInput=5"
	IF "%ERRORLEVEL%"=="6" set "SubVidInput=6"
	IF "%ERRORLEVEL%"=="7" set "SubVidInput=7"
	IF "%ERRORLEVEL%"=="8" set "SubVidInput=8"
	IF "%ERRORLEVEL%"=="9" set "SubVidInput=9"
if %mkvcount% GTR 9 set /p "SubVidInput=%_%%TAB%%w_%select video: %_%%gn_%"

set "SubVidInput=%SubVidInput:"=%"
set "MKVcount=0"
For %%V in (*.mkv, *.mp4) do (
	set /a "MKVcount+=1"
	set "VidN=%%~nV"
	set "VidNX=%%~nxV"
	set "VidX=%%~xV"
	call :SUB-Rename-List
)
if /i "%SubVid%"=="Selecting" (
	echo %TAB%%i_%%g_%  Invalid selection.  %-% 
	echo %TAB%%g_%The Options are beetween %gg_%1%g_% to %gg_%%MKVCount%%g_% only.
	echo.
	goto SUB-Rename-Input
	)
goto options
:SUB-Rename-List
if /i "%SubVid%"=="Selecting" (
	if /i "%SubVidInput%"=="%MKVcount%" (
			cls
			echo.
			echo.
			echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%Subtitle%%ESC%
			echo %TAB%%w_%🎞  Video   :%ESC%%c_%%VidNX%%ESC%
			echo.
		if not exist "%VidN%%SubtitleX%" (
			ren "%Subtitle%" "%VidN%%SubtitleX%"
			if exist "%VidN%%SubtitleX%" (
				echo %TAB%    %gn_%Subtitle rename successful.%_%
				echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%VidN%%SubtitleX%%ESC%
			) else (
				echo %TAB%    %r_%Subtitle rename failed.%_%
				echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%VidN%%SubtitleX%%ESC%
			)
		) else (
				echo %TAB%    %w_%Subtitle already exists.%_%
				echo %TAB%%w_%📄 Subtitle:%ESC% %yy_%%VidN%%SubtitleX%%ESC%
		)
	goto options
	)
)
if "%Subvid%"=="List" (
	if %MKVCount% LSS 9 set "align=  "
	if %MKVCount% GTR 9  set "align= "
	if %MKVCount% GTR 99  set "align="
)
if "%Subvid%"=="List" echo %TAB%%gg_%%align%%MKVcount% %w_%^>%c_% 🎞%ESC%%c_%%VidNX%%ESC%
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
echo %TAB%%_%to change the configurations, you  have to edit the "config.ini" file
echo %TAB%which is located at:%ESC%%w_%%rcfi%\%c_%config.ini%ESC%
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
echo %TAB%%yy_%Keyword%_%
echo %TAB%"%Keyword%%Keyword-extension%"
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
echo %TAB%%cc_%^>%_% Press %gg_%O%_% to open folder containing "config.ini".
echo %TAB%%cc_%^>%_% Press %gg_%C%_% to exit.%bk_%
choice /C:oc /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" (
	echo %TAB%%w_% Opening..
	echo %TAB%%ESC%%i_%%rcfi%%ESC%
	explorer.exe /select, "%rcfi%\config.ini"
	goto options
)
if /i "%ImgSizeInput%"=="2" echo %TAB%%_%Exiting configuration.. &goto options
goto options

:Config-Save                      
REM Save current config to config.ini
if exist "%Template%"        (for %%T in ("%Template%")        do set "Template=%%~nT")       else (set "Template=%rcfi%\template\(none).bat")
if exist "%TemplateForICO%"	(for %%T in ("%TemplateForICO%") do set "TemplateForICO=%%~nT") else (set "TemplateForICO=(none)")
if exist "%TemplateForPNG%"	(for %%T in ("%TemplateForPNG%") do set "TemplateForPNG=%%~nT") else (set "TemplateForPNG=insert a template name to use for .png files")
if exist "%TemplateForJPG%"	(for %%T in ("%TemplateForJPG%") do set "TemplateForJPG=%%~nT") else (set "TemplateForJPG=insert a template name to use for .jpg files")
if not defined TemplateIconSize set "TemplateIconSize=Auto"
(
	echo         [RCFI TOOLS CONFIGURATION]
	echo DrivePath="%cd%"
	echo Keyword="%Keyword%"
	echo Keyword-Extension="%Keyword-Extension%"
	echo Template="%Template%"
	echo TemplateForICO="%TemplateForICO%"
	echo TemplateForPNG="%TemplateForPNG%"
	echo TemplateForJPG="%TemplateForJPG%"
	echo TemplateAlwaysAsk="%TemplateAlwaysAsk%"
	echo TemplateTestMode="%TemplateTestMode%"
	echo TemplateTestMode-AutoExecute="%TemplateTestMode-AutoExecute%"
	echo TemplateIconSize="%TemplateIconSize%"
	echo ExitWait="%ExitWait%"
	
)>"%~dp0config.ini"
if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="
set "Template=%rcfi%\template\%Template:"=%.bat"
set "TemplateForICO=%rcfi%\template\%TemplateForICO:"=%.bat"
set "TemplateForPNG=%rcfi%\template\%TemplateForPNG:"=%.bat"
set "TemplateForJPG=%rcfi%\template\%TemplateForJPG:"=%.bat"
EXIT /B

:Config-Load                      
REM Load Config from config.ini
if not exist "%~dp0config.ini" call :Config-GetDefault
if exist "%~dp0config.ini" (
	for /f "usebackq tokens=1,2 delims==" %%C in ("%~dp0config.ini") do (set "%%C=%%D")
) else (
	echo.&echo.&echo.&echo.
	echo       %w_%Couldn't load config.ini.   %r_%Access is denied.
	echo       %w_%Try Run As Admin.%_%
	%P5%&%p5%&exit
)
if exist %Template% (for %%T in (%Template%) do set Template="%%~nT")       
if exist %TemplateForICO%	(for %%T in (%TemplateForICO%) do set TemplateForICO="%%~nT")
if exist %TemplateForPNG%	(for %%T in (%TemplateForPNG%) do set TemplateForPNG="%%~nT")
if exist %TemplateForJPG%	(for %%T in (%TemplateForJPG%) do set TemplateForJPG="%%~nT")
set "DrivePath=%DrivePath:"=%"
set "Keyword=%Keyword:"=%"
set "Keyword-Extension=%Keyword-Extension:"=%"
set "Template=%rcfi%\template\%Template:"=%.bat"
set "TemplateForICO=%rcfi%\template\%TemplateForICO:"=%.bat"
set "TemplateForPNG=%rcfi%\template\%TemplateForPNG:"=%.bat"
set "TemplateForJPG=%rcfi%\template\%TemplateForJPG:"=%.bat"
set "TemplateAlwaysAsk=%TemplateAlwaysAsk:"=%"
set "TemplateTestMode=%TemplateTestMode:"=%"
set "TemplateTestMode-AutoExecute=%TemplateTestMode-AutoExecute:"=%"
set "TemplateIconSize=%TemplateIconSize:"=%"
if /i "%TemplateIconSize%"=="Auto" set "TemplateIconSize="
REM "AlwaysGenerateSample=%AlwaysGenerateSample:"=%"
rem set "RunAsAdmin=%RunAsAdmin:"=%"
set "ExitWait=%ExitWait:"=%"
EXIT /B

:Config-GetDefault                
cd /d "%~dp0"
(
	echo DrivePath="%cd%"
	echo Keyword="*"
	echo Keyword-Extension=".png"
	echo Template="(none)"
	echo TemplateForICO="(none)"
	echo TemplateForPNG="insert the template name to use for .png files"
	echo TemplateForJPG="insert the template name to use for .jpg files"
	echo TemplateAlwaysAsk="No"
	echo TemplateTestMode="No"
	echo TemplateTestMode-AutoExecute="No"
	echo TemplateIconSize="Auto"
rem	echo RunAsAdmin="No"
	echo ExitWait="100"
)>"%~dp0config.ini"
EXIT /B

:Config-UpdateVar                 
title %name% %version%    "%cd%"
set "result=0"
set "target=*%Keyword%*%Keyword-Extension%"
for %%T in ("%Template%") do set "TemplateName=%%~nT"
set "printTagFI=%ast%%c_%%Keyword%%ast%%_%%c_%%Keyword-Extension%%_%"
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
set p1=ping localhost -n 1 ^>nul
set p2=ping localhost -n 2 ^>nul
set p3=ping localhost -n 3 ^>nul
set p4=ping localhost -n 4 ^>nul
set p5=ping localhost -n 5 ^>nul
set "RCFI=%~dp0"
set "RCFI=%RCFI:~0,-1%"
set "RCFID=%rcfi%\uninstall.cmd"
set "Converter=%rcfi%\resources\Convert.exe"
set "montage=%rcfi%\resources\montage.exe"
set "ImageSupport=.jpg,.png,.ico,.webp,.wbmp,.bmp,.svg,.jpeg,.tiff,.heic,.heif,.tga"
set "TemplateSampleImage=%RCFI%\img\- test.jpg"

rem Define some variables for MKV Tools
set "mkvpropedit=%rcfi%\resources\mkvpropedit.exe"
set "mkvmerge=%rcfi%\resources\mkvmerge.exe"
set "mkvextract=%rcfi%\resources\mkvextract.exe"
set "mkvinfo=%rcfi%\resources\mkvinfo.exe"
set "ffmpeg=%rcfi%\resources\ffmpeg.exe"
set "VideoSupport=.mp4,.avi,.ts"
set "SubtitleSupport=srt,sub,ass"
set "SubLanguage=ID"
set "SubName=Bahasa Indonesia"
set "SubSetAsDefault=Yes"
set "SubForcedDisplay=No"

rem Load some variables from Config.ini
call :Config-Load
if /i "%Setup%"=="Deactivate" (echo.&echo.&echo.&>"%rcfi%\resources\deactivating" echo Deactivating)

rem initiate 'Run As Admin'
if /i "%RunAsAdmin%"=="yes" call :Config-RunAsAdmin
if exist "%temp%\rcfi.getAdmin" (for /f "usebackq tokens=*" %%A in ("%temp%\rcfi.getAdmin") do %%A&del "%temp%\rcfi.getAdmin")

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
	)> "%temp%\rcfi.getAdmin"
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
if exist "%rcfi%\resources\deactivating." set "Setup=Deactivate" &set "setup_select=2" &goto Setup-Choice
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
	echo %w_%%name% %version%  %cc_%Activated%_%
	echo %g_%Folder Icon Tools has been added to the right-click menus. %_%
	if not defined input (goto intro)
)

REM uninstalling -> delete "uninstall.bat"
if /i "%setup_select%"=="2" (
	del "%rcfi%\resources\deactivating." 2>nul
	if exist "%RCFID%" del "%RCFID%"
	echo %w_%%name% %version%  %r_%Deactivated%_%
	echo %g_%Folder Icon Tools have been removed from the right-click menus.%_%
	if /i "%Setup%"=="Deactivate" %p5%&%p3%&exit
)
goto options

:Setup_error                      
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo            %r_%Setup fail!
echo            %w_%Permission denied.
del "%~dp0Setup_%Setup_action%.reg"
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
	echo [%RegExShell%\RCFI.Search.Folder.Icon\command]
	echo @="%cmd% set \"Context=FI.Search.Folder.Icon\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Poster
	echo [%RegExShell%\RCFI.Search.Poster]
	echo "MUIVerb"="Search Poster"
	echo "Icon"="shell32.dll,-251"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Search.Poster\command]
	echo @="%cmd% set \"Context=FI.Search.Poster\"%RCFIexe% \"%%V\""

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
	echo "MUIVerb"="Generate from - *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.GenJPG\command]
	echo @="%Scmd% set \"Context=GenJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG
	echo [%RegExShell%\RCFI.GenPNG]
	echo "MUIVerb"="Generate from - *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG\command]
	echo @="%Scmd% set \"Context=GenPNG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG
	echo [%RegExShell%\RCFI.GenPosterJPG]
	echo "MUIVerb"="Generate from - *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG\command]
	echo @="%Scmd% set \"Context=GenPosterJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG
	echo [%RegExShell%\RCFI.GenLandscapeJPG]
	echo "MUIVerb"="Generate from - *Landscape.jpg"
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
	echo "MUIVerb"="Generate from - *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.GenJPG.Here\command]
	echo @="%cmd% set \"Context=GenJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG_here
	echo [%RegExShell%\RCFI.GenPNG.Here]
	echo "MUIVerb"="Generate from - *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG.Here\command]
	echo @="%cmd% set \"Context=GenPNG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG_here
	echo [%RegExShell%\RCFI.GenPosterJPG.Here]
	echo "MUIVerb"="Generate from - *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG.Here\command]
	echo @="%cmd% set \"Context=GenPosterJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG_here
	echo [%RegExShell%\RCFI.GenLandscapeJPG.Here]
	echo "MUIVerb"="Generate from - *Landscape.jpg"
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
	
	:REG-FI-Edit.Config
	echo [%RegExShell%\RCFI.Edit.Config]
	echo "MUIVerb"="RCFI Tools Configuration"
	echo "Icon"="imageres.dll,-69"
	echo "CommandFlags"=dword:00000020
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
	echo "SubCommands"="RCFI.Select.And.Change.Folder.Icon;RCFI.RefreshNR;RCFI.Refresh;RCFI.DIR.Choose.Template;RCFI.Search.Poster;RCFI.Search.Folder.Icon;RCFI.Scan;RCFI.DefKey;RCFI.GenKey;RCFI.GenJPG;RCFI.GenPNG;RCFI.GenPosterJPG;RCFI.ActivateFolderIcon;RCFI.DeactivateFolderIcon;RCFI.RemFolderIcon"
	
	:REG-Context_Menu-FI-Background
	echo [%RegExBG%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.RefreshNR.Here;RCFI.Refresh.Here;RCFI.DIR.Choose.Template;RCFI.Search.Folder.Icon.Here;RCFI.Scan.Here;RCFI.DefKey;RCFI.GenKey.Here;RCFI.GenJPG.Here;RCFI.GenPNG.Here;RCFI.GenPosterJPG.Here;RCFI.ActivateFolderIcon.Here;RCFI.DeactivateFolderIcon.Here;RCFI.RemFolderIcon.Here;RCFI.Edit.Config;RCFI.Ver.Context.Click;"
	
	:REG-Context_Menu-Images
	echo [%RegExImage%\RCFI.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG-Choose.and.Set.As;RCFI.IMG.Generate.Icon;RCFI.IMG.Generate.PNG;RCFI.IMG.Template.Samples;RCFI.IMG.Choose.Template;RCFI.IMG.Edit.Template;RCFI.IMG-Convert;RCFI.IMG-Resize;"
	
	:REG-Context_Menu-Images-SVG
	echo [%RegExSVG%\RCFI.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="imageres.dll,-190"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG-Choose.and.Set.As;RCFI.IMG.Generate.Icon;RCFI.IMG.Generate.PNG;RCFI.IMG.Template.Samples;RCFI.IMG.Choose.Template;RCFI.IMG.Edit.Template;RCFI.IMG-Convert;RCFI.IMG-Resize;"
	
)>"%Setup_Write%"
if not exist "%rcfi%\resources\mkvpropedit.exe" exit /b
if not exist "%rcfi%\resources\mkvmerge.exe" exit /b
echo %g_%MKV Tools detected%gg_%✓%g_%
(

	:REG-Context_Menu-MKV-Extract_Subtitle
	echo [%RegExMKV%\RCFI.MKV.Extract]
	echo "MUIVerb"="Extract MKV"
	echo [%RegExMKV%\RCFI.MKV.Extract\command]
	echo @="%SCMD% set \"Context=MKV.Extract\"%SRCFIexe% \"%%1\""

	:REG-Context_Menu-MKV-Cover_Remove
	echo [%RegExMKV%\RCFI.MKV.RemoveCover-Delete]
	echo "MUIVerb"="Remove MKV Cover"
	echo [%RegExMKV%\RCFI.MKV.RemoveCover-Delete\command]
	echo @="%SCMD% set \"Context=MKV.Cover-Delete\"%SRCFIexe% \"%%1\""
	
	:REG-Context_Menu-MKV-Merge_Subtitle
	echo [%RegExMKV%\RCFI.MKV.Subtitle-Merge]
	echo "MUIVerb"="Merge files into MKV"
	echo [%RegExMKV%\RCFI.MKV.Subtitle-Merge\command]
	echo @="%SCMD% set \"Context=MKV.Subtitle-Merge\"%SRCFIexe% \"%%1\""

	:REG-Context_Menu-MP4
	echo [%RegExMP4%\RCFI.MP4.Convert.to.MKV]
	echo "MUIVerb"="Convert MP4 to MKV"
	echo [%RegExMP4%\RCFI.MP4.Convert.to.MKV\command]
	echo @="%SCMD% set \"Context=MP4.to.MKV\"%SRCFIexe% \"%%1\""
	
	:REG-Context_Menu-AVI
	echo [%RegExAVI%\RCFI.AVI.Convert.to.MKV]
	echo "MUIVerb"="Convert AVI to MKV"
	echo [%RegExAVI%\RCFI.AVI.Convert.to.MKV\command]
	echo @="%SCMD% set \"Context=AVI.to.MKV\"%SRCFIexe% \"%%1\""

	:REG-Context_Menu-TS
	echo [%RegExTS%\RCFI.TS.Convert.to.MKV]
	echo "MUIVerb"="Convert TS to MKV"
	echo [%RegExTS%\RCFI.TS.Convert.to.MKV\command]
	echo @="%SCMD% set \"Context=TS.to.MKV\"%SRCFIexe% \"%%1\""

	:REG-Context_Menu-SRT_Rename
	echo [%RegExSRT%\RCFI.SRT.Rename]
	echo "MUIVerb"="Rename subtitle to video"
	echo [%RegExSRT%\RCFI.SRT.Rename\command]
	echo @="%CMD% set \"Context=SRT.Rename\"%RCFIexe% \"%%1\""


	:REG-Context_Menu-ASS_Rename
	echo [%RegExASS%\RCFI.ASS.Rename]
	echo "MUIVerb"="Rename subtitle to video"
	echo [%RegExASS%\RCFI.ASS.Rename\command]
	echo @="%CMD% set \"Context=ASS.Rename\"%RCFIexe% \"%%1\""

	:REG-Context_Menu-XML_Rename
	echo [%RegExXML%\RCFI.XML.Rename]
	echo "MUIVerb"="Rename XML to video"
	echo [%RegExXML%\RCFI.XML.Rename\command]
	echo @="%CMD% set \"Context=XML.Rename\"%RCFIexe% \"%%1\""
	
)>>"%Setup_Write%"
exit /b

