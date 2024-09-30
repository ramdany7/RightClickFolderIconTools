:: Template-Version=v1.2
:: 2024-06-22 Fix: The star image was rendered in the generated folder icon even when the “.nfo” file didn’t exist.
:: 2024-06-24 Adding Global Config to override template config using RCFI.template.ini.

::                Template Info
::========================================================
::`  Image template by 90scomics.com
::`  Convert and Edit using ImageMagick.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=Yes"

::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderNameShort-characters-limit=10"
set "FolderNameLong-characters-limit=40"
set "FolderName-Center=Auto"

::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=26"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=yes"
::========================================================


::                Images Source
::========================================================
set "foldervertical-side=%rcfi%\images\foldervertical-side.png"
set "foldervertical-sidefx=%rcfi%\images\foldervertical-sidefx.png"
set "foldervertical-sideshadow=%rcfi%\images\foldervertical-sideshadow.png"
set "foldervertical-main=%rcfi%\images\foldervertical-main.png"
set "foldervertical-mainfx=%rcfi%\images\foldervertical-mainfx.png"
set "star-image=%rcfi%\images\star.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================
setlocal
chcp 65001 >nul
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
call :LAYER-LOGO
call :LAYER-CLEARART
call :LAYER-FOLDER_NAME

 "%Converter%"              ^
  %CODE-BACKGROUND%         ^
  %CODE-POSTER-SIDE%        ^
  %CODE-FOLDER-NAME-SHORT%  ^
  %CODE-FOLDER-NAME-LONG%   ^
  %CODE-LOGO-IMAGE%         ^
  %CODE-POSTER-SIDE-SHADOW% ^
  %CODE-POSTER-MAIN%        ^
  %CODE-CLEARART-IMAGE%     ^
  %CODE-STAR-IMAGE%         ^
  %CODE-RATING%             ^
  %CODE-GENRE%              ^
  %CODE-ICON-SIZE%          ^
 "%OutputFile%"
endlocal
exit /b



:::::::::::::::::::::::::::   CODE START   ::::::::::::::::::::::::::::::::

:LAYER-BASE
if /i "%use-GlobalConfig%"=="Yes" (
	for /f "usebackq tokens=1,2 delims==" %%A in ("%RCFI.templates.ini%") do (
		if /i not "%%B"=="" if /i not %%B EQU ^" %%A=%%B
	)
)

set CODE-BACKGROUND= ( ^
	"%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ) -compose Over

set CODE-POSTER-MAIN= ( ^
	 "%inputfile%" ^
	 -scale 346x490! ^
	 -gravity Northwest ^
	 -geometry +70+14 ^
	 "%foldervertical-main%" ) -compose over -composite ^
	 ( "%foldervertical-mainfx%" -scale 512x512! ) -compose over -composite

set CODE-POSTER-SIDE= ( ^
	 "%inputfile%" ^
	 -scale 512x512! ^
	 -blur 0x19 ^
	 "%foldervertical-side%" ) -compose over -composite ^
	 ( "%foldervertical-sidefx%" -scale 512x512! ) -compose over -composite

set CODE-POSTER-SIDE-SHADOW= ( "%foldervertical-sideshadow%" -scale 512x512! ) -compose over -composite
set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set CODE-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x84! ^
	 -gravity Northwest ^
	 -geometry +46+417 ^
	 ( +clone -background BLACK -shadow 0x1.2+4+6 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite
	 if not defined rating exit /b

set CODE-RATING= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill rgba(0,0,0,0.9) ^
	 -density 400 ^
	 -pointsize 6 ^
	 -kerning 0 ^
	 label:"%rating%" ^
	 -gravity Northwest ^
	 -geometry +58+440  ^
	 ( +clone -background ORANGE -shadow 30x1.2+2+2 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 30x1.2-2-2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2-2+2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2+2-2 ) +swap -background none -layers merge ^
	 ) -compose Over -composite 
exit /b


:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined GENRE exit /b

set CODE-GENRE= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill BLACK ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 -gravity Northwest ^
	 -geometry +119+455 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:LAYER-LOGO
if /i not "%use-Logo-instead-folderName%"=="yes" exit /b

if exist "*logo.png" (
	for %%D in (*logo.png) do set "Logo=%%~fD"&set "LogoName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Logo        :%LogoName%%ESC%

set CODE-LOGO-IMAGE= ( "%Logo%" ^
	 -trim +repage ^
	 -scale 160x50^ ^
	 -background none ^
	 -gravity center ^
	 -geometry +190-114 ^
	 -rotate 90 ^
	 ) -compose Over -composite
exit /b

:LAYER-CLEARART
if /i not "%display-clearArt%"=="yes" exit /b

if exist "*clearart.png" (
	for %%D in (*clearart.png) do set "ClearArt=%%~fD"&set "ClearArtName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Clear Art   :%ClearArtName%%ESC%

set CODE-CLEARART-IMAGE= ( "%clearart%" ^
	 -trim +repage ^
	 -scale 380x ^
	 -background none ^
	 -gravity SouthWest ^
	 -geometry -250-320 ^
	 ( +clone -background BLACK -shadow 40x40+10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10-10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40+10-10 ) +swap -background none -layers merge ^
	 ) -compose Over -composite
exit /b

:LAYER-FOLDER_NAME
if /i "%display-FolderName%"=="no" exit /b
if defined CODE-LOGO-IMAGE exit /b

for %%F in ("%cd%") do set "foldername=%%~nxF"
if not defined foldername set "foldername=%cd:\= %"
set "FolNamShort=%foldername%"
set "FolNamShortLimit=%FolderNameShort-characters-limit%"
set /a "FolNamShortLimit=%FolNamShortLimit%+1"
set "FolNamLong=%foldername%"
set "FolNamLongLimit=%FolderNameLong-characters-limit%"
set /a "FolNamLongLimit=%FolNamLongLimit%+1"

:GetInfo-FolderName-Short
set /a FolNamShortCount+=1
if not "%_FolNamShort%"=="%FolderName%" (
	call set "_FolNamShort=%%FolderName:~0,%FolNamShortCount%%%"
	goto GetInfo-FolderName-Short
)
set /A "FolNamShortLimiter=%FolNamShortLimit%-4"
if %FolNamShortCount% GTR %FolNamShortLimit% call set "FolNamShort=%%FolderName:~0,%FolNamShortLimiter%%%..."

if %FolNamShortCount% LEQ %FolNamShortLimiter% (set "FolNamPos=-gravity Northwest -geometry +398+32") else (set "FolNamPos=-gravity center -geometry +200-114")
if /i "%FolderName-Center%"=="yes" set "FolNamPos=-gravity center -geometry +200-114"
if /i "%FolderName-Center%"=="no"  set "FolNamPos=-gravity Northwest -geometry +398+32"


:GetInfo-FolderName-Long
set /a FolNamLongCount+=1
if not "%_FolNamLong%"=="%FolderName%" (
	call set "_FolNamLong=%%FolderName:~0,%FolNamLongCount%%%"
	goto GetInfo-FolderName-Long
)
set /A "FolNamLongLimiter=%FolNamLongLimit%-4"
if %FolNamLongCount% GTR %FolNamLongLimit% call set "FolNamLong=%%FolderName:~0,%FolNamLongLimiter%%%..."

set CODE-FOLDER-NAME-SHORT= ^
	 ( ^
	 -font Arial-Bold ^
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 10x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.6-0.6 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b
set CODE-FOLDER-NAME-LONG= ^
	 ( ^
	 -font Arial-Bold  ^
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize 3.1 ^
	 -kerning 2 ^
	 -gravity Northwest ^
	 -geometry +375+5 ^
	 -background none ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 10x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.2-0.2 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "CODE-FOLDER-NAME-LONG="
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::