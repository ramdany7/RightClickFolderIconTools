:: Author  : Ramdany
:: Name    : RCFI Tools
:: Created	: 26 March 2023
:: Note: 
:: - Variable "%1" cannot pass to the inside "call :label", it only exist when it's "Exit /b" from the "call"
::   so make sure to always "exit /b" from "call :label".
:: - Make sure to "exit /b" after calling another program such as "attrib", "convert.exe", etc..
::   so it doesn't ruin the unicode support. (chcp)
:: - Any variable inside "()" parentheses need to escape using double quotes (") so if there is
::   any parentheses inside the variable, it doesn't break the code.
:: - To be safe, always use "rem" instead of "::" for commenting

@ECHO off
chcp 65001 >nul
set name=RCFI Tools
set version=v0.01
title %name%   "%cd%"

:Start                            
set SelectedThing=%1
call :Config-Varset
call :Config-Startup
call :Setup
if defined xInput goto Input-Context

:Intro                            
echo. &echo                        %i_% %name% %version% %_%%-%&echo.
echo %TAB% %pp_%Drag and drop%_%%g_% a %yy_%folder%g_% or an %c_%image%g_% to  this  Terminal screen
echo %TAB% then  press  Enter  %_%to change  the folder icon.%_%
echo.
echo %ESC%%u_%%g_%Template:%_%%cc_% %TemplateName%%g_%   %u_%Keyword:%_% %printTagFI%%ESC%
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
if /i "%xInput%"=="refresh.NR" exit
if defined xInput (
	if %exitwait% GTR 9 echo.&echo.&echo %TAB%%g_% Press Any Key to Close this window. &pause>nul&exit
	echo. &echo.
	if /i "%input%"=="Scan" (
		echo %TAB%%TAB%%g_%Press any key to close this window.
		pause >nul &exit
	)
	if /i "%cdonly%"=="true" (
		echo %TAB%%g_%This window will close in %ExitWait% sec.
		ping localhost -n %ExitWait% >nul&exit
	)
	if /i "%input%"=="Generate" (
		echo %TAB%%TAB%%g_%Press any key to close this window.
		pause >nul &exit
	)
	echo %TAB%%g_%This window will close in %ExitWait% sec.
	ping localhost -n %ExitWait% >nul&exit
)

:Options-Input                    
echo %_%%GG_%Keyword%G_%^|%GG_%Scan%G_%^|%GG_%Template%G_%^|%GG_%Generate%G_%^|%GG_%Refresh%G_%^|%GG_%RefreshFc%G_%^|%GG_%Search%G_%^|%GG_%ON%G_%^|^
%GG_%OFF%G_%^|%GG_%Remove%G_%^|%GG_%Config%G_%^|%GG_%Setup%G_%^|%GG_%RCFI%G_%^|%GG_%O%G_%^|%GG_%S%G_%^|%GG_%Help%G_%^|..
echo %g_%--------------------------------------------------------------------------------------------------
title %name% %version%   "%cd%"
call :Config-Save
call :Config-UpdateVar
call :Config-Load

:Input-Command                    
set "cInput=(none)"
set /p "cInput=%_%%w_%%cd%%_%%gn_%>"
set "cInput=%cInput:"=%"
echo %-% &echo %-% &echo %-%
if /i "%cInput%"=="keyword"		goto FI-Keyword
if /i "%cInput%"=="ky"				goto FI-Keyword
if /i "%cInput%"=="key"			goto FI-Keyword
if /i "%cInput%"=="scan"			set "recursive=no"		&goto FI-Scan
if /i "%cInput%"=="sc"				set "recursive=no"		&goto FI-Scan
if /i "%cInput%"=="scans"			set "recursive=yes"		&goto FI-Scan
if /i "%cInput%"=="scs"			set "recursive=yes"		&goto FI-Scan
if /i "%cInput%"=="generate"		set "recursive=no"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%cInput%"=="gn"				set "recursive=no"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%cInput%"=="generates"		set "recursive=yes"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%cInput%"=="gns"			set "recursive=yes"		&set "cdonly=false"	&set "input=Generate"	&goto FI-Generate
if /i "%cInput%"=="Remove"		set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%cInput%"=="Rm"				set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
if /i "%cInput%"=="on"				set "refreshopen=index"	&goto FI-Activate
if /i "%cInput%"=="off"			set "refreshopen=index"	&goto FI-Deactivate
if /i "%cInput%"=="copy"			goto CopyFolderIcon
if /i "%cInput%"=="refresh"		echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%cInput%"=="refreshforce"	echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=Refresh"		&start "" "%~f0" &goto options
if /i "%cInput%"=="rf"				echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=RefreshNR"	&start "" "%~f0" &goto options
if /i "%cInput%"=="rff"			echo %TAB%%cc_%Refreshing icon cache..%_%&set "act=Refresh"		&start "" "%~f0" &goto options
if /i "%cInput%"=="template"		goto FI-Template 
if /i "%cInput%"=="tp"				goto FI-Template
if /i "%cInput%"=="Tes"			goto FI-Template-Sample
if /i "%cInput%"=="s"				goto Status
if /i "%cInput%"=="help"			goto Help
if /i "%cInput%"=="cd.."			cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%cInput%"==".."				cd /d .. &echo %TAB% Changing to the parent directory. &goto options
if /i "%cInput%"=="o"				echo %TAB%%_%Opening..   &echo %TAB%%i_%%cd%%-% &explorer.exe "%cd%" &goto options
if /i "%cInput%"=="rcfi"			echo %TAB%%_%Opening..   &echo %TAB%%i_%%~dp0%-% &echo. &explorer.exe "%~dp0" &goto options
if /i "%cInput%"=="cls"			cls&goto options
if /i "%cInput%"=="r"				start "" "%~f0" &exit
if /i "%cInput%"=="tc"				goto Colour
if /i "%cInput%"=="search"		set "xinput=FI.Search.Folder.Icon.Here"&echo %TAB%Opening search..&start "" "%~f0" &set "xinput="&goto options
if /i "%cInput%"=="sr"				set "xinput=FI.Search.Folder.Icon.Here"&echo %TAB%Opening search..&start "" "%~f0" &set "xinput="&goto options
if /i "%cInput%"=="setup"			goto Setup-Options
if /i "%cInput%"=="Activate"		set "Setup_Select=1" &goto Setup-Choice
if /i "%cInput%"=="Deactivate"	set "Setup_Select=2" &goto Setup-Choice
if /i "%cInput%"=="Act"			set "Setup_Select=1" &goto Setup-Choice
if /i "%cInput%"=="Dct"			set "Setup_Select=2" &goto Setup-Choice
if /i "%cInput%"=="config"		goto config-menu
if /i "%cInput%"=="cfg"			goto config-menu
if /i "%cInput%"=="cmd"			cls&cmd.exe
if exist "%cInput%" goto directInput
goto Input-Error


:Input-Context                    
title %name% %version% ^| %1
set Dir=cd /d %1
set Dir1=cd /d "%~dp1"
cls &echo. &echo. &echo.
REM Selected Image
if /i "%xInput%"=="IMG-Actions"						goto IMG-Actions
if /i "%xInput%"=="IMG-Set.As.Folder.Icon"			%Dir1% &set input=%1&set "RefreshOpen=Select" &goto DirectInput
if /i "%xInput%"=="IMG.Choose.Template"			set img=%1&goto FI-Template
if /i "%xInput%"=="IMG-Set.As.Cover"				set img=%1&goto IMG-Set_as_MKV_cover
if /i "%xInput%"=="IMG-Convert"						set img=%1&goto IMG-Convert
if /i "%xInput%"=="IMG-Resize"						set img=%1&goto IMG-Resize
REM Selected Dir	
if /i "%xInput%"=="OpenHere"							%Dir% &call :Config-Save 			&set "xInput=" &cls &goto Intro
if /i "%xInput%"=="DIR.Choose.Template"				goto FI-Template
if /i "%xInput%"=="FI.Search.Folder.Icon"			goto FI-Search
if /i "%xInput%"=="FI.Search.Folder.Icon.Here"	goto FI-Search
if /i "%xInput%"=="Scan"								set "input=Scan" 			&set "cdonly=true" &goto FI-Scan
if /i "%xInput%"=="DefKey"							goto FI-Keyword
if /i "%xInput%"=="GenKey"							set "input=Generate"											&set "cdonly=true" &goto FI-Generate
if /i "%xInput%"=="GenJPG"							set "input=Generate"		&set "Target=*.jpg" 				&set "cdonly=true" &goto FI-Generate
if /i "%xInput%"=="GenPNG"							set "input=Generate"		&set "Target=*.png" 				&set "cdonly=true" &goto FI-Generate
if /i "%xInput%"=="GenPosterJPG"					set "input=Generate"		&set "Target=*Poster*.jpg" 		&set "cdonly=true" &goto FI-Generate
if /i "%xInput%"=="GenLandscapeJPG"					set "input=Generate"		&set "Target=*Landscape*.jpg"	&set "cdonly=true" &goto FI-Generate
if /i "%xInput%"=="ActivateFolderIcon"				set "RefreshOpen=Select"	&goto FI-Activate
if /i "%xInput%"=="DeactivateFolderIcon"			set "RefreshOpen=Select"	&goto FI-Deactivate
if /i "%xInput%"=="RemFolderIcon"					set "delete=confirm"		&set "cdonly=true"				&goto FI-Remove
REM Background Dir	                         	
if /i "%xInput%"=="DIRBG.Choose.Template"			goto FI-Template
if /i "%xInput%"=="Scan.Here"						%Dir% &set "input=Scan" 			&goto FI-Scan
if /i "%xInput%"=="GenKey.Here"						%Dir% &set "input=Generate"											&set "cdonly=false" &goto FI-Generate
if /i "%xInput%"=="GenJPG.Here"						%Dir% &set "input=Generate"		&set "Target=*.jpg" 				&set "cdonly=false" &goto FI-Generate
if /i "%xInput%"=="GenPNG.Here"						%Dir% &set "input=Generate"		&set "Target=*.png" 				&set "cdonly=false" &goto FI-Generate
if /i "%xInput%"=="GenPosterJPG.Here"				%Dir% &set "input=Generate"		&set "Target=*Poster*.jpg" 		&set "cdonly=false" &goto FI-Generate
if /i "%xInput%"=="GenLandscapeJPG.Here"			%Dir% &set "input=Generate"		&set "Target=*Landscape*.jpg"	&set "cdonly=false" &goto FI-Generate
if /i "%xInput%"=="ActivateFolderIcon.Here"		%Dir% &goto FI-Activate
if /i "%xInput%"=="DeactivateFolderIcon.Here"		%Dir% &goto FI-Deactivate
if /i "%xInput%"=="RemFolderIcon.Here"				%Dir% &set "delete=ask"			&set "cdonly=false"	&goto FI-Remove
REM Other
if /i "%xInput%"=="FI.Deactivate" set "Setup=Deactivate" &goto Setup
goto Input-Error

:Input-Error                      
echo %TAB%%TAB%%r_% Invalid input.  %_%
echo.
if defined xInput echo %ESC%%TAB%%TAB%%i_%%r_%%xInput%%_%
if not defined xInput echo %ESC%%TAB%%TAB%%i_%%r_%%Input%%_%
echo.
echo %TAB%%g_%The command, file path, or directory path is unavailable. 
echo %TAB%Use %gn_%Help%g_% to see available commands.
goto options

:DirectInput                      
set "cdonly=true"
set "input=%cInput:"=%"
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
		if /i %%~xI==.jpg 	goto DirectInput-Generate
		if /i %%~xI==.png 	goto DirectInput-Generate
		if /i %%~xI==.jpeg 	goto DirectInput-Generate
		if /i %%~xI==.bmp 	goto DirectInput-Generate
		if /i %%~xI==.tiff 	goto DirectInput-Generate
		if /i %%~xI==.ico 	goto DirectInput-Generate
		)
echo %TAB%%r_%File format not supported.%-%
echo %TAB%%g_%^(supported file: *.ico, *.jpg, *.png, *.bmp, *.tiff^)
goto options
:DirectInput-Generate             
for %%D in ("%cd%") do set "foldername=%%~nD%%~xD" &set "folderpath=%%~dpD"
if not exist desktop.ini echo %TAB%%ESC%%yy_%📁 %foldername%%_%%ESC% &goto directInput-generate-confirm
for /f "usebackq tokens=1,2 delims==," %%C in ("desktop.ini") do set "%%C=%%D"
if not exist "%iconresource%" echo %TAB%%ESC%%y_%📁 %foldername%%_%%ESC% &goto directInput-generate-confirm
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
IF "%ERRORLEVEL%"=="1" if defined xInput cls &echo.&echo.&echo.&echo.&echo %TAB%%ESC%%yy_%📁 %foldername%%_%%ESC%
:DirectInput-Generate-Confirm     
set "ReplaceThis=%iconresource%"
attrib -s -h "%filepath%%filename%"
attrib |exit /b
call :FI-Generate-Folder_Icon
goto options

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
Echo %TAB%Target    : %target%
echo %TAB%Directory :%ESC%%cd%%ESC%
echo %TAB%%w_%==============================================================================%_%
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
echo.
echo %TAB%  %u_%%result% Folder found.%_%
echo.
echo.
IF /i %R_result%		LSS 10 (set "R_s=   "		) else (IF /i %R_result%		GTR 9 set "R_s=  "	&IF /i %R_result%		GTR 99	set "R_s= "	&IF /i %R_result%		GTR 999 set "R_s="	)		
IF /i %Y_result%		LSS 10 (set "Y_s=   "		) else (IF /i %Y_result%		GTR 9 set "Y_s=  "	&IF /i %Y_result%		GTR 99 set "Y_s= "	&IF /i %Y_result%		GTR 999 set "Y_s="	)		
IF /i %G_result%		LSS 10 (set "G_s=   "		) else (IF /i %G_result%		GTR 9 set "G_s=  "	&IF /i %G_result%		GTR 99 set "G_s= "	&IF /i %G_result%		GTR 999 set "G_s="	)		
IF /i %YY_result%		LSS 10 (set "YY_s=   "	) else (IF /i %YY_result%		GTR 9 set "YY_s=  "	&IF /i %YY_result%	GTR 99 set "YY_s= "	&IF /i %YY_result%	GTR 999 set "YY_s="	)		
IF /i %YY_result%		GTR 0 echo %TAB%%yy_%%YY_s%%YY_result%%_% Folder can be processed.
IF /i %R_result%		GTR 0 echo %TAB%%r_%%R_s%%R_result%%_% Folder icon is missing and can be changed.
IF /i %Y_result%		GTR 0 echo %TAB%%y_%%Y_s%%Y_result%%_% Folder already has an icon.
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% Folder skipped, Couldn't find "%c_%%Target%%_%" in the folder.
IF /i %YY_result%		LSS 1 echo.&echo %TAB% Folder cantaining "%c_%%Target%%_%" couldn't be found.
echo.
echo   %g_%Note: If there is more than one file named "%target%" in the folder, the one 
echo   selected as the folder icon will be the one that appears first in the folder.
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
			echo %TAB%%ESC%Folder icon:%c_%%iconresource%%ESC%%r_%%i_%Not Found!%-%
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
	if /i "%xinput%"=="Create" call :FI-Scan-Find_Target
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
if not defined cInput (
	echo %TAB%%TAB%%w_%%i_%  Generating folder icon..  %-%
	echo %TAB%Target    :%ESC%%target%%ESC%
	if exist "%Template%" for %%T in ("%Template%") do (
	echo %TAB%Template  :%ESC%%cc_%%%~nT%ESC% 
	)
	echo %TAB%Directory :%ESC%%cd%%ESC%
	echo %TAB%%w_%==============================================================================%_%
)
if /i "%AlwaysAskTemplate%"=="Yes" if /i not "%Already%"=="Asked" set "referer=FI-Generate"&call :FI-Template
call :FI-GetDir
echo %TAB%%w_%==============================================================================%_%
set /a "result=%yy_result%+%y_result%+%g_result%+%r_result%"
if /i "%cdonly%"=="true" if %success_result% EQU 1 goto options
if /i "%cdonly%"=="true" if %y_result% EQU 1 (
	cls &echo.&echo.&echo.&echo.
	echo %TAB%%ESC%%y_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%w_%Folder already has an icon. 
	echo %TAB%Remove it first.%_% 
	goto options
)
if /i "%cdonly%"=="true" if %g_result% EQU 1 (
	cls &echo.&echo.&echo.&echo.
	echo %TAB%%ESC%%g_%📁 %foldername%%ESC%
	echo.
	echo %TAB%%w_%Couldn't find %target%
	echo %TAB%Make sure there is file ^(%target%^) inside selected folder.%_%
	goto options
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
IF /i %G_result%		GTR 0 echo %TAB%%g_%%G_s%%G_result%%_% Folder skipped, Couldn't find "%c_%%Target%%_%".
IF /i %YY_result%		LSS 1 echo.&echo %TAB% ^(No folders to be procced.^)
IF /i %fail_result%	GTR 0 echo %TAB%%fail_s%%r_%%fail_result%%_% Folder icon failed to generate.
IF /i %success_result%	GTR 1 echo %TAB%%success_s%%cc_%%success_result%%_% Folder icon generated.

echo %TAB%------------------------------------------------------------------------------
goto options

:FI-Generate-Folder_Icon          
if not defined Selected call :FI-ID
if not defined Selected (
	if not defined xInput (
		set "inputfile=%filepath%%filename%" &set "outputfile=%cd%\foldericon(%FI-ID%).ico"
	) else (
		set "inputfile=%filepath%%filename%" &set "outputfile=%filepath%foldericon(%FI-ID%).ico"
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
	if /i "%fileExt%"==".ICO" if /i "%NoTemplateForPNG%"=="Yes" (
		echo %TAB%%ESC%%g_%File extension is %c_%.ico%g_%, Template will not be applied %cc_%(none)%ESC%.%r_%
		copy "%inputfile%" "%outputFile%" >nul ||echo %TAB%Copy file error. Pls. Run As Admin.
	)
	if /i "%fileExt%"==".PNG" if /i "%NoTemplateForPNG%"=="Yes" (
		if /i not "%TemplateName%"=="(none)" echo %TAB%%ESC%%g_%File extension is %c_%.png%g_%, Template will not be applied %cc_%(none)%ESC%.%r_%
		call "%RCfI%\Template\(none).bat" ||echo %r_%Fail! "%RCfI%\Template\(none).bat"
	)
	
	rem Executing "template" to convert and edit selected image
	call "%Template%"
	
	rem Check icon size, if icon size is less then 10kB then it's fail.
	if exist "foldericon(%FI-ID%).ico" for %%S in ("foldericon(%FI-ID%).ico") do (
		if %%~zS GTR 10000 echo %ESC%%g_%%TAB%Convert success - foldericon(%FI-ID%).ico (%%~zS Bytes) %r_%
		if %%~zS LSS 10000 echo %ESC%%r_%%TAB%Convert error - foldericon(%FI-ID%).ico (%%~zS Bytes) "%%~dpnxS"%r_% &del /q foldericon(%FI-ID%).ico >nul
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
	) else (echo  %r_%%i_% Convert failed. %_%%r_% "%Filename%". &set /a "fail_result+=1")
	
	rem Hiding "desktop.ini" and "foldericon.ico"
	if exist "desktop.ini" if exist "foldericon(%FI-ID%).ico" (
		ren "Desktop.ini" "desktop.ini"
		attrib +s +h "desktop.ini"
		attrib +s +h "foldericon(%FI-ID%).ico"
		attrib |exit /b
		echo %TAB% %i_%%g_%  Done!  %-% 
		set /a "success_result+=1"
		if defined ReplaceThis del /q "%ReplaceThis%"&set "ReplaceThis="
	)
)
EXIT /B

:FI-Generate-Get_Template         
for /f "usebackq tokens=1,2 delims==<>" %%C in ("%~dp0config.ini") do set %%C=%%D
if not exist "%Template%" (
	echo.
	echo %TAB% %w_%Couldn't load template.
	echo %TAB%%ESC%%r_%%Template%%ESC%
	echo %TAB% %i_%%r_%File not found.%-%
	goto options
)
EXIT /B

:FI-Template                      
if /i not	"%referer%"=="FI-Generate" if defined xinput cls &echo.&echo.&echo.&echo.
if /i		"%referer%"=="FI-Generate" echo %TAB%%w_%Choose Template to Generate Folder Icons:%_%
rem Show current template and descriptions
if /i not "%referer%"=="FI-Generate" (
	for %%I in ("%Template%") do (
		set "TName=%%~nI"
		echo %TAB%%w_%%u_%Current Template%_%:%ESC%%cc_%%%~nI%ESC%
		for /f "usebackq tokens=1,2 delims=#" %%I in ("%Template%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
		echo %TAB%%_%
		echo.
	)
)
rem Get template options
echo.
echo %TAB%%TAB%%i_%%cc_%   Template   %-%
echo.
set "TSelector=GetList"&set "TCount=0"
PUSHD "%rcfi%\template"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TPath=%%~fT"
		call :FI-Template-Get_List
	)
POPD

rem Get sample image to test the template
echo.
if /i "%xInput%"=="IMG.Choose.Template" (
	for %%I in (%img%) do (
	set "TSampleName=%%~nxI"
	set "size_B=%%~zI"
	call :FileSize
	)
)
if /i "%xInput%"=="IMG.Choose.Template" (
	echo %TAB%%TAB%%gn_% S%_% ^> %cc_%See all sample icons, using:%ESC%%c_%%TSampleName%%_% (%pp_%%size%%_%)%ESC%
) else (echo %TAB%%TAB%%gn_% S%_% ^> %cc_%See all sample icons%_%)
echo.
echo %g_%%TAB%%TAB%to select, insert the number assosiated to the options, then hit Enter.%_%
goto FI-Template-Input

:FI-Template-Input
rem Input template options
set "TemplateChoice=NotSelected"
set /p "TemplateChoice=%_%%w_%%TAB%%TAB%Choose template:%_%%gn_%"
if /i "%TemplateChoice%"=="NotSelected" echo %_%%TAB%   %i_%  CANCELED  %-%&%p2%&goto options
if /i "%TemplateChoice%"=="r" cls&echo.&echo.&echo.&goto FI-Template
if /i "%TemplateChoice%"=="s" set "act=FI-Template-Sample-All"	&start "" "%~f0"&cls&echo.&echo.&echo.&goto FI-Template

rem Proccess valid selected options
set "TSelector=Select"&set "TCount=0"
PUSHD "%rcfi%\template"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TPath=%%~fT"
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
	if defined xInput (cls &goto Input-Context) else goto FI-Generate
) else (
	call :Config-Save
)
goto options

:FI-Template-Get_List             
if /i "%Tselector%"=="GetList" (
	if %TCount% LSS 10 echo %TAB%%TAB% %gn_%%TCount%%_% ^>%ESC%%cc_%%TName%%_%%ESC%
	if %TCount% GTR 9  echo %TAB%%TAB%%gn_%%TCount%%_% ^>%ESC%%cc_%%TName%%_%%ESC%
	exit /b
)
set "_info="
if /i "%TSelector%"=="Select" (
	if /i not "%TCount%"=="%TemplateChoice%" exit /b
	if defined xinput cls &echo.&echo.&echo.&echo.
	set "Template=%TPath%"
	echo.
	echo   %_%%ESC%%cc_%  %TName%%_% selected.%ESC%
	%p1%
	for /f "usebackq tokens=1,2 delims=#" %%I in ("%TPath%") do if /i not "%%J"=="" echo %ESC%%%J%ESC%
	%p2%
	if /i not "%GenerateSample%"=="no" call :FI-Template-Sample
	set "TemplateChoice=Selected"
)
exit /b


:FI-Template-Sample               
call :Config-UpdateVar
if not exist "%rcfi%\template\sample" md "%rcfi%\template\sample"
set "inputfile=%rcfi%\Template\img\test.png"
set "outputfile=%rcfi%\Template\sample\%TName%.ico"
if exist "%outputFile%" del /q "%outputFile%"
if /i "%xInput%"=="IMG.Choose.Template" set "img=%img:"=%"
if /i "%xInput%"=="IMG.Choose.Template" set "inputfile=%img%"
echo.&echo.
echo %i_%%g_%  Generating sample preview.. %-%
echo %g_%Selected Template:%ESC%%cc_%%TName%%ESC%%r_%
for %%I in ("%inputfile%") do set "filename=%%~nxI"
echo %g_%Sample image     :%ESC%%c_%%filename%%ESC%%r_%
Call "%Template%"
if %ERRORLEVEL% NEQ 0 echo   %r_%%i_%   error ^(%ERRORLEVEL%^)   %-%
if exist "%outputFile%" for %%C in ("%outputFile%") do (
	if %%~zC GTR 10000 (echo %g_%Done! &explorer.exe "%outputFile%")
	if %%~zC LSS 10000 (echo %ESC%%r_%%TAB%Convert error - %c_%%%~nxC %_%(%pp_%%%~zC Bytes%_%)%ESC%
		del /q "%outputFile%" >nul
		pause>nul
		goto options)
)
exit /b

:FI-Template-Sample-All           
if /i "%xInput%"=="IMG.Choose.Template" set "img=%img:"=%"
if /i "%xInput%"=="IMG.Choose.Template" (
	for %%I in ("%img%") do (
	set "TSampleName=%%~nxI"
	set "img=%%~fI"
	set "size_B=%%~zI"
	call :FileSize
	)
) else (
	for %%I in ("%rcfi%\template\img\test.png") do (
	set "TSampleName=%%~nxI"
	set "img=%%~fI"
	set "size_B=%%~zI"
	call :FileSize
	)
)
echo.&echo %TAB%Sample image selected:
echo   %ESC%%c_%%TSampleName%%_% (%pp_%%size%%_%)
echo.
echo %TAB%%yy_%Generating all sample images..%_%
echo %TAB%"%rcfi%\template\sample\"
echo.
if not exist "%rcfi%\template\sample" md "%rcfi%\template\sample"
pushd "%rcfi%\template\sample"
	for %%I in (*.ico) do del /q "%%~fI"
popd
PUSHD "%rcfi%\template"
	FOR %%T in (*.bat) do (
		set /a TCount+=1
		set "TName=%%~nT"
		set "TSampling=%%~fT"
		call :FI-Template-Sample-All-Generate
	)
POPD
echo %TAB%%i_%%yy_%   Done!   %_%
explorer.exe "%rcfi%\template\sample\"
pause>nul&exit

:FI-Template-Sample-All-Generate  
set "inputfile=%img%"
set "outputfile=%rcfi%\template\sample\%TName%.ico"
if %TCount% LSS 10 echo %TAB%%gn_% %TCount%%_%%ESC%> %cc_%%TName%%ESC%
if %TCount% GTR 9  echo %TAB%%gn_%%TCount%%_%%ESC%> %cc_%%TName%%ESC%%r_%

call "%TSampling%"

if exist "%outputfile%" (
	for %%S in ("%outputfile%") do (
		if %%~zS GTR 10000 ( 
		rem	echo %TAB%    %ESC%%_%Convert success 
			echo %TAB%    %ESC%%c_%%%~nxS%_% (%pp_%%%~zS Bytes%_%)
		)
		if %%~zS LSS 10000 echo %TAB%%ESC%    %r_%Convert error: %c_%%%~nxS%_% (%pp_%%%~zS Bytes%_%) &del /q %outputfile% >nul
	)
) else (echo %TAB%    %r_%%i_% Convert failed. %_%)
echo.
exit /b

:FI-Search                        
if /i "%xInput%"=="FI.Search.Folder.Icon" (set "SrcInput=%~nx1" &goto FI-Search-Input)
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
Start "" "https://google.com/search?q=%SrcInput% folder icon site:deviantart.com&tbm=isch&tbs=ic:trans"
cls&if /i "%xInput%"=="FI.Search.Folder.Icon" exit
goto FI-Search

:FI-Keyword                       
echo %TAB%%g_%Current keyword:%ESC%%c_%%Keyword%%ESC%%_%
echo %TAB%%g_%This keyword will be use to search file name to generate folder icon.%_%
set "newKeyword=*"
echo.
set /p "newKeyword=%-%%-%%-%%w_%Change keyword:%c_%"
if "%newKeyword%"=="*" set "newKeyword=%Keyword%"
set "Keyword=%newKeyword%"
set "Keyword=%Keyword: =*%"
echo. &echo. &echo.
echo %TAB%%_%%g_%Current extension: %c_%%Extension%%_%
echo %TAB%%g_%In generate proccess, matched file name and file extension will
echo %TAB%%g_%automatically convert into .Ico and set it as folder icon.
echo.
echo %TAB%%gn_%  1%_% ^> %c_%.Png%_%
echo %TAB%%gn_%  2%_% ^> %c_%.Jpg%_%
echo %TAB%%gn_%  3%_% ^> %c_%.Ico%_%
echo %TAB%%gn_%  4%_% ^> %c_%.jpeg%_%
echo %TAB%%gn_%  5%_% ^> %c_%.bmp%_%
echo %TAB%%gn_%  6%_% ^> %c_%.tiff%_%
echo.
set "extChoice=0"
set /p "extChoice=%-%%-%%-%%w_%Select file extension:%gn_%"
if /i "%extChoice%"=="0"								 goto FI-Keyword-Selected
if /i "%extChoice%"=="1" set "Extension=.Png"	&goto FI-Keyword-Selected
if /i "%extChoice%"=="2" set "Extension=.Jpg"	&goto FI-Keyword-Selected
if /i "%extChoice%"=="3" set "Extension=.Ico"	&goto FI-Keyword-Selected
if /i "%extChoice%"=="4" set "Extension=.jpeg"	&goto FI-Keyword-Selected
if /i "%extChoice%"=="5" set "Extension=.bmp"	&goto FI-Keyword-Selected
if /i "%extChoice%"=="6" set "Extension=.tiff"	&goto FI-Keyword-Selected
echo.
echo %TAB%%_%%i_%  Invalid selection.  %-%
echo.
goto options
:FI-Keyword-Selected              
call :Config-Save
call :Config-UpdateVar
if "%xInput%"=="DefKey" (
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
IF /i %result% LSS 1 if defined xInput cls
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
if defined xInput cls
if defined xInput (
	echo.&echo.&echo.&echo.
	echo %TAB%%r_%   %i_%  Removing Folder Icon..  %-%
	echo.
	if /i not "%cdonly%"=="true" echo %TAB%%w_%Directory:%ESC%%w_%%cd%%ESC%
	if /i not "%cdonly%"=="true" echo %TAB%%w_%==============================================================================%_%
	if /i not "%cdonly%"=="true" echo.
)

call :FI-Remove-Get

if defined xInput if /i not "%cdonly%"=="true" echo %TAB%%w_%==============================================================================%_%
IF /i %result% LSS 1 if defined xInput cls
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
		echo %ESC%%TAB%%w_%📁 %_%%foldername%%ESC%
		echo %TAB% %g_%Folder icon:%ESC%%c_%%iconresource%%ESC%
		for %%I in ("%iconresource%") do (
			if "%%~dpI"=="%cd%\" (
				attrib -s -h "%iconresource%" 
				attrib |exit /b
				echo %TAB% %g_%Deleting%ESC%%g_%%iconresource%%ESC%%r_%
				del /f /q "%iconresource%"			
			) else (echo %TAB%%ESC%%c_%%%~nxI%_% %g_%file is outside of 📁 %_%%foldername%. so i wont delete it.%ESC%)
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
if exist "%RCFI%\refresh." (if defined xinput exit else goto options) else (echo    refreshing .. >>"%RCFI%\refresh.")
if /i not "%xInput%"=="" echo.&echo.&echo.
echo %_%%g_%%TAB%Note: In case if the process gets stuck and explorer doesn't come back.
echo %TAB%Hold %i_% CTRL %_%%g_%+%i_% SHIFT %_%%g_%+%i_% ESC %_%%g_%%-% %g_%^> Click File ^> Run New Task ^> Type "explorer" ^> OK.
echo %TAB%%cc_%Restarting Explorer and updating icon cache ..%r_%
echo.&set "startexplorer="
ie4uinit.exe -ClearIconCache
ie4uinit.exe -show
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
call :FI-Refresh-NoRestart
if /i "%act%"=="Refresh" exit /b
goto options

:FI-Refresh-NoRestart             
@echo off
if defined xinput echo.
mode con:cols=50 lines=9
title  refresh folder icon..
set refreshCount=0
for %%F in (.) do (
	set "foldername=%%~nxF"
	if exist "desktop.ini" (
		title  "%%~nxF"
		echo %TAB%%w_%Refreshing ..%_%
		echo %ESC%%cc_%%%~nxF%ESC%%r_%
		attrib -r "%cd%"
		attrib -s -h 		"desktop.ini"
		ren "desktop.ini" "DESKTOP INI"
		ren "DESKTOP INI" "desktop.ini"
		attrib +r "%cd%"
		attrib +s +h 		"desktop.ini"
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
		echo. &echo.
		if exist "desktop.ini" (
			title  refreshing.. "%%R"
			echo %TAB%%w_%Refreshing ..%_%
			echo %ESC%%cc_%%%R%ESC%%r_%
			attrib -r "%%~fR"
			attrib -s -h 		"desktop.ini"
			ren "desktop.ini" "DESKTOP INI"
			ren "DESKTOP INI" "desktop.ini"
			attrib +r "%%~fR"
			attrib +s +h 		"desktop.ini"
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

ie4uinit.exe -ClearIconCache >nul
ie4uinit.exe -show >nul
title  "%foldername%"
echo.&echo.&echo.
echo %TAB%               %i_%%w_%    Done!    %_%
echo. &echo. &ping localhost -n 2 >nul
del /q "%RCFI%\refresh." 2>nul
if exist "%RCFI%\refresh." (
	echo   %r_%Fail to delete "refresh." in main directory!
	echo   %_%"%RCFI%"
	echo   %r_%Pls. Run As Admin%_%
	pause
)
exit

:FI-ID                            
set "digit=6"
set "string=256789256789BCDFGHJKLMNPQRSTVWXYZ256789"
set "string_lenght=39"
set "digit_count=" &set "get_ID="

:FI-ID-get                        
set /a "digit_count+=1" &set /a "x=%random% %% %string_lenght%"
call set "get_ID=%get_ID%%%string:~%x%,1%%"
if not "%digit_count%"=="%digit%" goto FI-ID-get
set "FI-ID=%get_ID%"
exit /b

:IMG-Convert                      
echo %TAB%       %i_%%w_%    IMAGE CONVERTER    %_%
rem echo %TAB%%w_%==============================================================================%_%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%Converting image ... 
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
			call :IMG-Convert-FileList
			call :IMG-Convert-Action
		)
	)
) else (
	FOR %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do ( 
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
		)
		call :IMG-Convert-FileList
	)
	call :IMG-Convert-Options
)
rem echo %TAB%%w_%==============================================================================%_%
echo.
echo %TAB%%_%Done!
goto options

:IMG-Convert-FileList             
echo %TAB%%_%-%ESC%%c_%%ImgName%%ImgExt%%_% %G_%(%pp_%%size%%G_%)%r_%
exit /b

:IMG-Convert-Options              
echo.
echo %TAB%%g_%To select, just press the number assosiated below.
echo %TAB%you can also type in any extension you want.%_%
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
echo %TAB%%g_%Press %gn_%i%g_% to input any extension you want.
echo %TAB%Press %gn_%c%g_% to cancel.%bk_%
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
	echo %TAB%%g_%Input file extension you want, example "%yy_%.gif%g_%"
	set /p "ImgExtNew=%-%%-%%-%%w_%Input:%yy_%"
)
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options
set "ImgResizeCode=%ImgResizeCode:"=%"
set "Action=Start" &cls&goto IMG-Convert

:IMG-Convert-Action               
set Size_B=1
set "ImgOutput=%ImgName%%ImgExtNew%"
"%converter%" "%ImgPath%%ImgName%%ImgExt%" %convertcode% "%ImgPath%%ImgOutput%"
if exist "%ImgPath%%ImgOutput%" (
	for %%I in ("%ImgPath%%ImgOutput%") do (
		set "Size_B=%%~zI"
		call :FileSize
	)
) else (
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExtNew%%g_% (%r_%Convert Fail!%g_%)%_%
	exit /b
)
if not %Size_B% LSS 1000 (
	echo %TAB%%_%-%ESC%%c_%%ImgName%%cc_%%ImgExtNew%%g_% (%pp_%%size%%g_%)%_%
) else (
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExtNew%%g_% (%r_%Convert Fail!%g_%)%_%
	del /q "%ImgPath%%ImgOutput%"
	exit /b
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
echo %TAB%       %i_%%w_%    IMAGE RESIZER    %_%
rem echo %TAB%%w_%==============================================================================%_%
if /i "%Action%"=="Start" (
	echo.
	echo %TAB%Resizing image ... 
	for %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do (
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
			call :IMG-Resize-FileList
			call :IMG-Resize-Action
		)
	)
) else (
	FOR %%D in (%xSelected%) do (
		for %%I in ("%%~fD") do ( 
			set "ImgPath=%%~dpI"&set "ImgName=%%~nI"&set "ImgExt=%%~xI"&set "Size_B=%%~zI"
			call :FileSize
		)
		call :IMG-Resize-FileList
	)
	call :IMG-Resize-Options
)
rem echo %TAB%%w_%==============================================================================%_%
echo.
echo %TAB%%_%Done!
goto options

:IMG-Resize-FileList              
echo %TAB%%_%-%ESC%%c_%%ImgName%%ImgExt%%g_% (%pp_%%size%%g_%)%_%
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
echo %TAB%%g_%To select, just press the number assosiated below.
echo %TAB%you can also type in image size you want.%_%
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
echo %TAB%%g_%Press %gn_%i%g_% to input your own desire image size. 
echo %TAB%Press %gn_%c%g_% to cancel.%bk_%
choice /C:1234567ic /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" set "ImgResizeCode=%IMGResize1Code%"&set "ImgTag=%IMGResize1Tag%" 
if /i "%ImgSizeInput%"=="2" set "ImgResizeCode=%IMGResize2Code%"&set "ImgTag=%IMGResize2Tag%"
if /i "%ImgSizeInput%"=="3" set "ImgResizeCode=%IMGResize3Code%"&set "ImgTag=%IMGResize3Tag%"
if /i "%ImgSizeInput%"=="4" set "ImgResizeCode=%IMGResize4Code%"&set "ImgTag=%IMGResize4Tag%"
if /i "%ImgSizeInput%"=="5" set "ImgResizeCode=%IMGResize5Code%"&set "ImgTag=%IMGResize5Tag%"
if /i "%ImgSizeInput%"=="6" set "ImgResizeCode=%IMGResize6Code%"&set "ImgTag=%IMGResize6Tag%"
if /i "%ImgSizeInput%"=="7" set "ImgResizeCode=%IMGResize7Code%"&set "ImgTag=%IMGResize7Tag%"
if /i "%ImgSizeInput%"=="8" (
	echo %TAB%%g_%Input your own command, example "%yy_%-resize 720x720 -quality 80%g_%"
	echo %TAB%to ignore  the aspect  ratio put "%yy_%!%g_%" behind  the  pixel size.
	echo %TAB%example "%yy_%-resize 720x720! -quality 80%g_%".
	set /p "ImgResizeCode=%-%%-%%-%%w_%Input:%yy_%"
	set "ImgTag=_(Custom)"
)
if /i "%ImgSizeInput%"=="9" echo %TAB%  %w_%%i_%  CANCELED  %_%&goto options
set "ImgResizeCode=%ImgResizeCode:"=%"
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
	echo %TAB%%_%-%ESC%%c_%%ImgName%%cc_%%ImgTag%%c_%%ImgExt%%g_% (%pp_%%size%%g_%)%_%
) else (
	echo %TAB%-%ESC%%c_%%ImgName%%ImgExt%%g_% (%r_%Convert Fail!%g_%)%_%
	del /q "%ImgPath%%ImgOutput%"
	exit /b
)
exit /b

:FileSize                         
if "%size_B%"=="" echo %r_%Fail to get file size!%_% &exit /b
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

:Config-Menu                      
echo %TAB%       %i_%%w_% RCFI Tools Configuration %_%
echo %TAB%Simply,  you  can change the  configurations  using  "config.ini"
echo %TAB%inside  RCFI Tools  folder, which  is located  at:
echo %TAB%"%yy_%%rcfi%\%c_%config.ini%_%"
echo.
echo %TAB%or you can also use Configuration wizard in this terminal screen.
echo %TAB%%cc_%^>%_% Press %gg_%O%_% to open "config.ini" containing folder.
echo %TAB%%cc_%^>%_% Press %gg_%W%_% to open Configutaion wizard.
echo %TAB%%cc_%^>%_% Press %gg_%C%_% to exit.%bk_%
choice /C:owc /N
set "ImgSizeInput=%errorlevel%"
if /i "%ImgSizeInput%"=="1" explorer.exe /select, "%rcfi%\config.ini"&goto options
if /i "%ImgSizeInput%"=="3" goto options
echo.
echo %_%Wizard start..
goto options

:Config-Save                      
REM Save current config to config.ini
(
	echo         [RCFI TOOLS CONFIGURATION]
	echo Converter="%Converter%"
	echo DrivePath="%cd%"
	echo Keyword="%Keyword%"
	echo Extension="%Extension%"
	echo Template="%Template%"
	echo GenerateSample="%GenerateSample%"
	echo NoTemplateForICO="%NoTemplateForICO%"
	echo NoTemplateForPNG="%NoTemplateForPNG%"
	echo AlwaysAskTemplate="%AlwaysAskTemplate%"
	echo RunAsAdmin="%RunAsAdmin%"
	echo ExitWait="%ExitWait%"
	
)>"%~dp0config.ini"
EXIT /B

:Config-Load                      
REM Load Config from config.ini
if not exist "%~dp0config.ini" call :Config-GetDefault &%p3%
if exist "%~dp0config.ini" (
	for /f "usebackq tokens=1,2 delims==" %%C in ("%~dp0config.ini") do (set "%%C=%%D")
) else (echo.&echo.&echo.&echo.&echo.       %w_%Couldn't load %r_%config.ini%_%.&pause>nul&exit)
set "Converter=%Converter:"=%"
set "DrivePath=%DrivePath:"=%"
set "Keyword=%Keyword:"=%"
set "Extension=%Extension:"=%"
set "Template=%Template:"=%"
set "GenerateSample=%GenerateSample:"=%"
set "NoTemplateForICO=%NoTemplateForICO:"=%"
set "NoTemplateForPNG=%NoTemplateForPNG:"=%"
set "AlwaysAskTemplate=%AlwaysAskTemplate:"=%"
set "RunAsAdmin=%RunAsAdmin:"=%"
set "ExitWait=%ExitWait:"=%"
if /i "%RunAsAdmin%"=="yes" (
	IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
		>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
	) ELSE (
		>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
	)
)
if /i "%RunAsAdmin%"=="yes" (
	if '%errorlevel%' NEQ '0' (
		echo Requesting administrative privileges...
		echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
		set params = %*:"=""
		echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
		"%temp%\getadmin.vbs"
		del "%temp%\getadmin.vbs"
		exit
	)
)
EXIT /B

:Config-GetDefault                
(
	echo Converter="%~dp0Convert.exe"
	echo DrivePath="%cd%"
	echo Keyword="*"
	echo Extension=".png"
	echo Template="%rcfi%\template\(none).bat"
	echo GenerateSample="Yes"
	echo NoTemplateForICO="Yes"
	echo NoTemplateForPNG="Yes"
	echo AlwaysAskTemplate="No"
	echo RunAsAdmin="No"
	echo ExitWait="4"
	
)>"%~dp0config.ini"
EXIT /B

:Config-UpdateVar                 
title %name% %version%    "%cd%"
set "result=0"
set "target=*%Keyword%*%Extension%"
for %%T in ("%Template%") do set "TemplateName=%%~nT"
set "printTagFI=%ast%%c_%%Keyword%%ast%%_%%c_%%Extension%%_%"
EXIT /B

:Config-Varset                    
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
set "ESC=[30m"[0m"
set "AST=%r_%*%_%"                         
set p1=ping localhost -n 1 ^>nul
set p2=ping localhost -n 2 ^>nul
set p3=ping localhost -n 3 ^>nul
set p4=ping localhost -n 4 ^>nul
set "RCFI=%~dp0_."
set "RCFI=%RCFI:\_.=%"
set "RCFID=%~dp0deactivator.cmd"
if /i "%Setup%"=="Deactivate" (echo.&echo.&echo.&>"%RCFI%\Deactivating" echo Deactivating)
call :Config-Load
if exist "%DrivePath%" (cd /d "%DrivePath%") else (cd /d "%~dp0")
call :Config-UpdateVar
EXIT /B

:Config-Startup                   
if /i "%act%"=="Refresh"		goto FI-Refresh
if /i "%act%"=="RefreshNR"	goto FI-Refresh-NoRestart
if /i "%act%"=="FI-Template-Sample-All" goto FI-Template-Sample-All
if /i "%xInput%"=="Refresh.Here"	cd /d %selectedthing% &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh
if /i "%xInput%"=="RefreshNR.Here"	cd /d %selectedthing% &set "cdonly=false"	&set "RefreshOpen=Index"		&goto FI-Refresh-NoRestart
if /i "%xInput%"=="Refresh"			cd /d %selectedthing% &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh
if /i "%xInput%"=="RefreshNR"		cd /d %selectedthing% &set "cdonly=true"	&set "RefreshOpen=Select"	&goto FI-Refresh-NoRestart
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
if exist "%RCFI%\Deactivating." set "Setup=Deactivate" &set "setup_select=2" &goto Setup-Choice
if exist "%RCFID%" (exit /b) else echo.&echo.&echo.&set "setup_select=1" &goto Setup-Choice
echo.&echo.&echo.

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
	goto Setup_Proccess
)
if "%setup_select%"=="2" (
	echo %g_%Deactivating RCFI Tools%_%
	set "Setup_action=uninstall"
	set "HKEY=-HKEY"
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v MultipleInvokePromptMinimum /t REG_DWORD /d 0x0000000f /f >nul
	goto Setup_Proccess
)
if "%setup_select%"=="3" goto options
goto Setup-Options

:Setup_Proccess                   
set "Setup_Write=%~dp0Setup_%Setup_action%.reg"
call :Setup_Writing
if not exist "%~dp0Setup_%Setup_action%.reg" goto Setup_error
echo %g_%Updating shell extension menu ..%_%
regedit.exe /s "%~dp0Setup_%Setup_action%.reg" ||goto Setup_error
del /q "%~dp0Setup_%Setup_action%.reg"

if /i "%setup_select%"=="1" (
	echo cd /d "%%~dp0">"%RCFID%"
	echo set "Setup=Deactivate">>"%RCFID%"
	echo call "%name% %version%" ^|^|pause^>nul >>"%RCFID%"
	echo %w_%%name% %version%  %cc_%Activated%_%
	echo %g_%Folder Icon Tools right-click menus have been added. %_%
	%p2%
	if not defined input (cls&goto intro)
)
if /i "%setup_select%"=="2" (
	del /q "%RCFI%\Deactivating." 2>nul
	if exist "%RCFID%" del /q "%RCFID%"
	echo %w_%%name% %version%  %r_%Deactivated%_%
	echo %g_%Folder Icon Tools right-click menus have been removed.%_%
	if /i "%Setup%"=="Deactivate" %p4%&exit
)
goto options

:Setup_error                      
cls
echo.&echo.&echo.&echo.&echo.&echo.&echo.&echo.
echo            %r_%Setup fail!
echo            %w_%Pls. Run As Admin.
del /q "%~dp0Setup_%Setup_action%.reg"
pause>nul&exit


:Setup_Writing                    
echo %g_%Preparing registry entry ..%_%

rem Escaping the slash using slash
	set "curdir=%~dp0_."
	set "curdir=%curdir:\_.=%"
	set "curdir=%curdir:\=\\%"


rem Multi Select, Separate instance
	set cmd=cmd.exe /c
	set RCFIexe=^&call \"%curdir%\\%name% %version%.bat\"
	set SCMD=\"%curdir%\\SingleInstanceAccumulator.exe\" \"-c:cmd /c
	set SRCFIexe=^^^&set xSelected=$files^^^&call \"\"%curdir%\\%name% %version%.bat\"\"\"


rem Define registry root
	set RegExBG=%HKEY%_CLASSES_ROOT\Directory\Background\shell
	set RegExDir=%HKEY%_CLASSES_ROOT\Directory\shell
	set RegExImage=%HKEY%_CLASSES_ROOT\SystemFileAssociations\image\shell
	set RegExShell=%HKEY%_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell


rem Generating setup_*.reg
(
	echo Windows Registry Editor Version 5.00

	:REG-FI-IMAGE-Set.As.Folder.Icon
	echo [%RegExShell%\RCFI.IMG-Set.As.Folder.Icon]
	echo "MUIVerb"="Set As Folder Icon"
	echo "Icon"="shell32.dll,-16801"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Set.As.Folder.Icon\command]
	echo @="%cmd% set \"xInput=IMG-Set.As.Folder.Icon\"%RCFIexe% \"%%1\""

	:REG-FI-IMAGE-FI.Choose.Template
	echo [%RegExShell%\RCFI.IMG.Choose.Template]
	echo "MUIVerb"="Template"
	echo "Icon"="shell32.dll,-270"
	echo [%RegExShell%\RCFI.IMG.Choose.Template\command]
	echo @="%cmd% set \"xInput=IMG.Choose.Template\"%RCFIexe% \"%%1\""	
	
	:REG-FI-IMAGE-Convert
	echo [%RegExShell%\RCFI.IMG-Convert]
	echo "MUIVerb"="Convert"
	echo "Icon"="shell32.dll,-236"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.IMG-Convert\command]
	echo @="%SCMD% set \"xInput=IMG-Convert\"%SRCFIexe% \"%%1\""
	
	:REG-FI-IMAGE-Resize
	echo [%RegExShell%\RCFI.IMG-Resize]
	echo "MUIVerb"="Resize"
	echo "Icon"="shell32.dll,-236"
	echo [%RegExShell%\RCFI.IMG-Resize\command]
	echo @="%SCMD% set \"xInput=IMG-Resize\"%SRCFIexe% \"%%1\""


	REM Selected_Dir
	:REG-FI-Open
	echo [%RegExShell%\RCFI.OpenHere]
	echo "MUIVerb"="%name% %version%"
	echo "Icon"="shell32.dll,-35"
	echo [%RegExShell%\RCFI.OpenHere\command]
	echo @="%cmd% set \"xInput=OpenHere\"%RCFIexe% \"%%V\""
	
	:REG-FI.Search.Folder.Icon
	echo [%RegExShell%\RCFI.Search.Folder.Icon]
	echo "MUIVerb"="Search Folder Icon"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Folder.Icon\command]
	echo @="%cmd% set \"xInput=FI.Search.Folder.Icon\"%RCFIexe% \"%%V\""

	:REG-FI.Search.Folder.Icon.Here
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here]
	echo "MUIVerb"="Search Folder Icon"
	echo "Icon"="shell32.dll,-251"
	echo [%RegExShell%\RCFI.Search.Folder.Icon.Here\command]
	echo @="%cmd% set \"xInput=FI.Search.Folder.Icon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh
	echo [%RegExShell%\RCFI.Refresh]
	echo "MUIVerb"="Refresh Icon Cache (Restart Explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh\command]
	echo @="%cmd% set \"xInput=Refresh\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh_No_Restart
	echo [%RegExShell%\RCFI.RefreshNR]
	echo "MUIVerb"="Refresh Icon Cache (Without Restart)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.RefreshNR\command]
	echo @="%cmd% set \"xInput=RefreshNR\"%RCFIexe% \"%%V\""
	
	:REG-FI-Choose_Template
	echo [%RegExShell%\RCFI.DIR.Choose.Template]
	echo "MUIVerb"="Template"
	echo "Icon"="shell32.dll,-270"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.DIR.Choose.Template\command]
	echo @="%Scmd% set \"xInput=DIR.Choose.Template\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Choose_Template
	echo [%RegExShell%\RCFI.DIRBG.Choose.Template]
	echo "MUIVerb"="Template"
	echo "Icon"="shell32.dll,-270"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.DIRBG.Choose.Template\command]
	echo @="%cmd% set \"xInput=DIRBG.Choose.Template\"%RCFIexe% \"%%V\""
	
	:REG-FI-Scan
	echo [%RegExShell%\RCFI.Scan]
	echo "MUIVerb"="Scan"
	echo "Icon"="shell32.dll,-23"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Scan\command]
	echo @="%Scmd% set \"xInput=Scan\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Define_Keyword
	echo [%RegExShell%\RCFI.DefKey]
	echo "MUIVerb"="Define keyword"
	echo "Icon"="shell32.dll,-242"
	echo [%RegExShell%\RCFI.DefKey\command]
	echo @="%cmd% set \"xInput=DefKey\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Keyword
	echo [%RegExShell%\RCFI.GenKey]
	echo "MUIVerb"="Generate from Keyword"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey\command]
	echo @="%Scmd% set \"xInput=GenKey\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG
	echo [%RegExShell%\RCFI.GenJPG]
	echo "MUIVerb"="Generate from - *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.GenJPG\command]
	echo @="%Scmd% set \"xInput=GenJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG
	echo [%RegExShell%\RCFI.GenPNG]
	echo "MUIVerb"="Generate from - *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG\command]
	echo @="%Scmd% set \"xInput=GenPNG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG
	echo [%RegExShell%\RCFI.GenPosterJPG]
	echo "MUIVerb"="Generate from - *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG\command]
	echo @="%Scmd% set \"xInput=GenPosterJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG
	echo [%RegExShell%\RCFI.GenLandscapeJPG]
	echo "MUIVerb"="Generate from - *Landscape.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenLandscapeJPG\command]
	echo @="%Scmd% set \"xInput=GenLandscapeJPG\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Activate_Folder_Icon
	echo [%RegExShell%\RCFI.ActivateFolderIcon]
	echo "MUIVerb"="Activate Folder Icon"
	echo "Icon"="shell32.dll,-210"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.ActivateFolderIcon\command]
	echo @="%Scmd% set \"xInput=ActivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Deactivate_Folder_Icon
	echo [%RegExShell%\RCFI.DeactivateFolderIcon]
	echo "MUIVerb"="Deactivate Folder Icon"
	echo "Icon"="shell32.dll,-4"
	echo [%RegExShell%\RCFI.DeactivateFolderIcon\command]
	echo @="%Scmd% set \"xInput=DeactivateFolderIcon\"%SRCFIexe% \"%%V\""
	
	:REG-FI-Remove_Folder_Icon
	echo [%RegExShell%\RCFI.RemFolderIcon]
	echo "MUIVerb"="Remove Folder Icon"
	echo "Icon"="shell32.dll,-145"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RemFolderIcon\command]
	echo @="%Scmd% set \"xInput=RemFolderIcon\"%SRCFIexe% \"%%V\""
	
	REM Background Dir
	:REG-FI-Refresh_here
	echo [%RegExShell%\RCFI.Refresh.Here]
	echo "MUIVerb"="Refresh Icon Cache (Restart Explorer)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.Refresh.Here\command]
	echo @="%cmd% set \"xInput=Refresh.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Refresh_No_Restart_here
	echo [%RegExShell%\RCFI.RefreshNR.Here]
	echo "MUIVerb"="Refresh Icon Cache (Without Restart)"
	echo "Icon"="shell32.dll,-16739"
	echo [%RegExShell%\RCFI.RefreshNR.Here\command]
	echo @="%cmd% set \"xInput=RefreshNR.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Scan_here
	echo [%RegExShell%\RCFI.Scan.Here]
	echo "MUIVerb"="Scan"
	echo "Icon"="shell32.dll,-23"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Scan.Here\command]
	echo @="%cmd% set \"xInput=Scan.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Keyword_here
	echo [%RegExShell%\RCFI.GenKey.Here]
	echo "MUIVerb"="Generate from keyword"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenKey.Here\command]
	echo @="%cmd% set \"xInput=GenKey.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.JPG_here
	echo [%RegExShell%\RCFI.GenJPG.Here]
	echo "MUIVerb"="Generate from - *.JPG"
	echo "Icon"="shell32.dll,-241"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.GenJPG.Here\command]
	echo @="%cmd% set \"xInput=GenJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_.PNG_here
	echo [%RegExShell%\RCFI.GenPNG.Here]
	echo "MUIVerb"="Generate from - *.PNG"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPNG.Here\command]
	echo @="%cmd% set \"xInput=GenPNG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Poster.JPG_here
	echo [%RegExShell%\RCFI.GenPosterJPG.Here]
	echo "MUIVerb"="Generate from - *Poster.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenPosterJPG.Here\command]
	echo @="%cmd% set \"xInput=GenPosterJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Generate_Landscape.JPG_here
	echo [%RegExShell%\RCFI.GenLandscapeJPG.Here]
	echo "MUIVerb"="Generate from - *Landscape.jpg"
	echo "Icon"="shell32.dll,-241"
	echo [%RegExShell%\RCFI.GenLandscapeJPG.Here\command]
	echo @="%cmd% set \"xInput=GenLandscapeJPG.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Activate_Folder_Icon_here
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here]
	echo "MUIVerb"="Activate Folder Icons"
	echo "Icon"="shell32.dll,-210"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.ActivateFolderIcon.Here\command]
	echo @="%cmd% set \"xInput=ActivateFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Deactivate_Folder_Icon_here
	echo [%RegExShell%\RCFI.DeactivateFolderIcon.Here]
	echo "MUIVerb"="Deactivate Folder Icons"
	echo "Icon"="shell32.dll,-4"
	echo [%RegExShell%\RCFI.DeactivateFolderIcon.Here\command]
	echo @="%cmd% set \"xInput=DeactivateFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Remove_Folder_Icon_here
	echo [%RegExShell%\RCFI.RemFolderIcon.Here]
	echo "MUIVerb"="Remove Folder Icons"
	echo "Icon"="shell32.dll,-145"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.RemFolderIcon.Here\command]
	echo @="%cmd% set \"xInput=RemFolderIcon.Here\"%RCFIexe% \"%%V\""
	
	:REG-FI-Deactivate
	echo [%RegExShell%\RCFI.Deactivate]
	echo "MUIVerb"="             Deactivate %name%"
	echo "CommandFlags"=dword:00000020
	echo [%RegExShell%\RCFI.Deactivate\command]
	echo @="%cmd% set \"xInput=FI.Deactivate\"%RCFIexe%"		
		
	:REG-Context_Menu-FI-Folder
	echo [%RegExDir%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="shell32.dll,-35"
	echo "SubCommands"="RCFI.OpenHere;RCFI.Refresh;RCFI.RefreshNR;RCFI.DIR.Choose.Template;RCFI.Search.Folder.Icon;RCFI.Scan;RCFI.DefKey;RCFI.GenKey;RCFI.GenJPG;RCFI.GenPNG;RCFI.GenPosterJPG;RCFI.GenLandscapeJPG;RCFI.ActivateFolderIcon;RCFI.DeactivateFolderIcon;RCFI.RemFolderIcon;RCFI.Deactivate"
	
	:REG-Context_Menu-FI-Background
	echo [%RegExBG%\RCFI.Folder.Icon.Tools]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="shell32.dll,-35"
	echo "SubCommands"="RCFI.OpenHere;RCFI.Refresh.Here;RCFI.RefreshNR.Here;RCFI.DIRBG.Choose.Template;RCFI.Search.Folder.Icon.Here;RCFI.Scan.Here;RCFI.DefKey;RCFI.GenKey.Here;RCFI.GenJPG.Here;RCFI.GenPNG.Here;RCFI.GenPosterJPG.Here;RCFI.GenLandscapeJPG.Here;RCFI.ActivateFolderIcon.Here;RCFI.DeactivateFolderIcon.Here;RCFI.RemFolderIcon.Here;RCFI.Deactivate"
	
	:REG-Context_Menu-Images
	echo [%RegExImage%\RCFI]
	echo "MUIVerb"="Folder Icon Tools"
	echo "Icon"="shell32.dll,-35"
	echo "SubCommands"="RCFI.IMG-Set.As.Folder.Icon;RCFI.IMG.Choose.Template;RCFI.IMG-Convert;RCFI.IMG-Resize;"
	
)>"%Setup_Write%"
exit /b


:Colour
start "Colour options" cmd /c "D:\Documents\Scripts\Text color in batch\Tes colour.bat"
goto options