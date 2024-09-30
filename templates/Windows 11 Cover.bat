:: Template-Version=v1.2
:: 2024-06-27 Add error handling: "LabelExpected ' @ error/annotate.c/GetMultilineTypeMetrics/804." 


::                Template Info
::========================================================
::` Windows 11 theme folder icon.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=Yes"

::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=32"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=yes"

::--------- Folder Name --------------------------
set "display-FolderName=yes"
set "FolderName-Center=Auto"
    :: options: Auto = Automatically put folder name on the center if numbers 
    ::                 of the characters is less than half of characters limit
    ::          Yes  = Always put folder name on the center
    ::          No   = Always put folder name on the left

	set "FolderNameShort-characters-limit=8"
	set "FolderNameShort-font=Microsoft-PhagsPa-Bold"
	set "FolderNameShort-size=7.7"

	:: Folder name position when it's on the left
	set "FolderNameShort-Pos-Left-Gravity=SouthWest"
	set "FolderNameShort-Pos-Left-X=+34"
	set "FolderNameShort-Pos-Left-Y=+385"
	
	:: Folder name position when it's on the center
	set "FolderNameShort-Pos-Center-Gravity=Center"
	set "FolderNameShort-Pos-Center-X=-137"
	set "FolderNameShort-Pos-Center-Y=-161"

	set "FolderNameLong-characters-limit=19"
	set "FolderNameLong-font=Microsoft-PhagsPa"
	set "FolderNameLong-size=3.5"
	set "FolderNameLong-Pos-Gravity=NorthWest"
	set "FolderNameLong-Pos-X=+0"
	set "FolderNameLong-Pos-Y=+83"

::--------- Picture Config -----------------
set "Picture-Opacity=100%"

set "Picture-Width=458"
set "Picture-Height=295"
set "Picture-Gravity=center"
set "Picture-Position-X=+1"
set "Picture-Position-Y=+14"

set "Picture-Drawing-Brightness=-20"
set "Picture-Drawing-Contrast=35"
set "Picture-Drawing-Exposure=50"
set "Picture-Drawing-Saturation=100"
set "Picture-Drawing-Smoothness=0"

::========================================================


::                Images Source
::========================================================
set "Win11Cover-Front=%rcfi%\images\Win11Cover-Front.png"
set "Win11Cover-BG=%rcfi%\images\Win11Cover.png"
set "star-image=%rcfi%\images\star.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================


setlocal
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
call :LAYER-LOGO
call :LAYER-CLEARART
call :LAYER-FOLDER_NAME
 "%Converter%"             ^
  %CODE-BACKGROUND%        ^
  %CODE-FOLDER-NAME-SHORT% ^
  %CODE-FOLDER-NAME-LONG%  ^
  %CODE-LOGO-IMAGE%        ^
  %CODE-CLEARART-IMAGE%    ^
  %CODE-PICTURE%           ^
  %CODE-STAR-IMAGE%        ^
  %CODE-RATING%            ^
  %CODE-GENRE%             ^
  %CODE-ICON-SIZE%         ^
 "%OutputFile%"
  %deltemp%
endlocal
exit /b



:::::::::::::::::::::::::::   CODE START   :::::::::::::::::::::::::::::::::

:LAYER-BASE
if /i "%use-GlobalConfig%"=="Yes" (
	for /f "usebackq tokens=1,2 delims==" %%A in ("%RCFI.templates.ini%") do (
		if /i not "%%B"=="" if /i not %%B EQU ^" %%A=%%B
	)
)

set CODE-BACKGROUND= ( ^
	"%canvas%" ^
	-scale      512x512! ^
	-background  none ^
	-extent     512x512 ^
	) -compose Over ( "%Win11Cover-BG%" ) -compose over -composite

:: Creating mask to carve the picture
set "Win11CoverMask=Win11CoverMask(%FI-ID%).png"

"%Converter%" ^
	( "%canvas%" ^
	  -scale      512x512! ^
	  -background  none ^
	  -extent     512x512 ^
	) -compose   Over ^
	( "%InputFile%" ^
	  -scale    %Picture-Width%x%Picture-Height%! ^
	  -gravity  %Picture-Gravity% ^
	  -geometry %Picture-Position-X%%Picture-Position-Y% ^
	  "%Win11Cover-Front%" ^
	) -compose over -composite "%Win11CoverMask%"
	 
"%Converter%" "%Win11CoverMask%" ^
	-brightness-contrast 0x10 ^
	-modulate    95,70 ^
	-background  white ^
	-channel     a ^
	-alpha      remove ^
	-channel    rgb ^
	-negate     ^
	-alpha      shape ^
	"%Win11CoverMask%"
	 
set /a "PicOp=255*%Picture-Opacity%/100"
set "Picture-Opacity=-alpha set -channel A -evaluate set %PicOp% +channel"

set CODE-PICTURE=	( ^
	 "%Win11Cover-BG%" ^
	 -scale 512x512! ^
	 -modulate %Picture-Drawing-Exposure%,%Picture-Drawing-Saturation% ^
	 -brightness-contrast %Picture-Drawing-Brightness%x%Picture-Drawing-Contrast% ^
	 -blur 0x%Picture-Drawing-Smoothness% ^
	 %Picture-Opacity% "%Win11CoverMask%" ) -compose Over  -composite 
	  
set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"

set deltemp=del "Win11CoverMask(%FI-ID%).png" "Win11CoverLogoMask(%FI-ID%).png" 2>nul
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set CODE-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x88! ^
	 -gravity Northwest ^
	 -geometry +0+356 ^
	 ( +clone -background BLACK% ^
	 -shadow 40x1.2+1.8+3 ) ^
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
	 -geometry +13+383 ^
	 ( +clone -background ORANGE -shadow 30x1.2+2+2 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 30x1.2-2-2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2-2+2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2+2-2 ) +swap -background none -layers merge ^
	 ) -compose Over -composite  
exit /b

:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined genre exit /b

set CODE-GENRE= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill BLACK ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 -gravity Northwest ^
	 -geometry +76+395 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:LAYER-LOGO
if /i not "%use-Logo-instead-folderName%"=="yes" exit /b

if exist "*logo.png" (
	for %%D in (*logo.png) do set "Logo=%%~fD"&set "LogoName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Logo        :%LogoName%%ESC%
:: Creating mask to carve the logo
set "Win11CoverLogoMask=Win11CoverLogoMask(%FI-ID%).png"

"%Converter%" ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over ^
	( "%Logo%" -trim +repage ^
	 ( +clone -background BLACK -shadow 40x0.9+8.0+5.5 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x0.9-2.7-2.7 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x0.9-2.7+2.7 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x0.9+2.7-2.7 ) +swap -background none -layers merge ^
	 -modulate 95,70 -brightness-contrast 0x10 -background white -channel a -alpha remove -channel rgb -negate -alpha shape ^
	 -scale 160x68^ ^
	 -gravity center ^
	 -geometry -138-150 ^
	) -compose over -composite "%Win11CoverLogoMask%"
	
set CODE-LOGO-IMAGE= ( ^
	 "%Win11Cover-BG%" ^
	 -scale 512x512! ^
	 -modulate 60,120 -brightness-contrast -5x30 -blur 0x1 ^
	 "%Win11CoverLogoMask%" ) -compose Over  -composite
exit /b

:LAYER-CLEARART
if /i not "%display-clearArt%"=="yes" exit /b

if exist "*clearart.png" (
	for %%D in (*clearart.png) do set "ClearArt=%%~fD"&set "ClearArtName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Clear Art   :%ClearArtName%%ESC%

set CODE-CLEARART-IMAGE= ( "%clearart%" ^
	 -trim +repage ^
	 -scale 230x125^ ^
	 -background none ^
	 -gravity South ^
	 -geometry +90+388 ^
	 ) -compose Over -composite
exit /b


:LAYER-FOLDER_NAME
if not defined FolderName exit /b
if /i not "%display-FolderName%"=="yes" exit /b
if defined CODE-LOGO-IMAGE exit /b

for %%F in ("%cd%") do set "foldername=%%~nxF"
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


set "FolNamCenter=-gravity %FolderNameShort-Pos-Center-Gravity% -geometry %FolderNameShort-Pos-Center-X%%FolderNameShort-Pos-Center-Y%"
set "FolNamLeft=-gravity %FolderNameShort-Pos-Left-Gravity% -geometry %FolderNameShort-Pos-Left-X%%FolderNameShort-Pos-Left-Y%"
if %FolNamShortCount% LEQ %FolNamShortLimiter% (set "FolNamPos=%FolNamLeft%") else (set "FolNamPos=%FolNamCenter%")
if /i "%FolderName-Center%"=="yes" set "FolNamPos=%FolNamCenter%"
if /i "%FolderName-Center%"=="no"  set "FolNamPos=%FolNamLeft%"

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
	 -font "%FolderNameShort-font%" ^
	 -fill rgba(255,255,255,0.85) ^
	 -density 400 ^
	 -pointsize %FolderNameShort-size% ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 6x1+0.3+0.3 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x1-0.3-0.3 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x1-0.3+0.3 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x1+0.3-0.3 ) +swap -background none -layers merge ^
	 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b

set CODE-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%FolderNameLong-font%" ^
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize %FolderNameLong-size% ^
	 -kerning -0.5 ^
	 -gravity %FolderNameLong-Pos-Gravity% ^
	 -geometry %FolderNameLong-Pos-X%%FolderNameLong-Pos-Y% ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 3x4.5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x4.5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x4.5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x4.5+0.2-0.2 ) +swap -background none -layers merge ^
	 ) -composite
	 
if "%FolderNameLong-characters-limit%"=="0" set "CODE-FOLDER-NAME-LONG="
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::