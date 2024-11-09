:: Template-Version=v1.2
:: 2024-06-22 Fix: The star image was rendered in the generated folder icon even when the “.nfo” file didn’t exist.
:: 2024-06-24 Added "Global Config" to override template config using 'RCFI.template.ini'.
:: 2024-10-20 Removed "Picture-opacity" option because it caused transparency to render as black. 
::            (Might fix and add it back later if anyone needs it?)
:: 2024-10-20 Added config "Picture-Drawing=original" to display the picture as is.
:: 2024-10-20 Added config to change the shadow.


::                Template Info
::========================================================
::` This template was inspired by Folderify 
::` https://github.com/lgarron/folderify
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

	set "FolderNameShort-characters-limit=7"
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
	set "FolderNameLong-Pos-Gravity=SouthWest"
	set "FolderNameLong-Pos-X=+3"
	set "FolderNameLong-Pos-Y=+333"

::--------- Picture Config -----------------
set "Picture-Drawing=yes"
   :: Options: original = display the picture as is.
   ::               yes = display as a grayscale picture.
   ::               no  = convert everything to black, except for transparency.
   
set "Picture-TrimTransparentSpace=yes"
set "Picture-Width=400"
set "Picture-Height=230"
set "Picture-Gravity=center"
set "Picture-Position-X=-0"
set "Picture-Position-Y=+20"

	::--------- if "Picture Drawing=YES"
	  set "Picture-Drawing-ON-Brightness=-8"
	  set "Picture-Drawing-ON-Contrast=40"
	  set "Picture-Drawing-ON-Exposure=55"
	  set "Picture-Drawing-ON-Saturation=80"
	  set "Picture-Drawing-ON-Smoothness=0"

	::--------- if "Picture Drawing=NO"
	  set "Picture-Drawing-OFF-Brightness=-5"
	  set "Picture-Drawing-OFF-Contrast=15"
	  set "Picture-Drawing-OFF-Exposure=60"
	  set "Picture-Drawing-OFF-Saturation=100"
	  set "Picture-Drawing-OFF-Smoothness=15"

set "Picture-Shadow=yes"
set "Shadow-Color=BLACK"
set "Shadow-Opacity=20%"
set "Shadow-Blur=0.6"

set "ReAdjust-BG-position=yes"
::========================================================


::                Images Source
::========================================================
set "Win11Folderify-BG=%rcfi%\images\Win11Folderify.png"
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
  %CODE-FOLDERIFY%         ^
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

set CODE-BACKGROUND= ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over

if /i not "%ReAdjust-BG-position%"=="yes" (
	set ReAdjust-Position=-resize 512x512^ -gravity center -extent 512x512!
) else (
	set ReAdjust-Position= ^
	 -trim +repage ^
	 -resize x352 ^
	 -gravity South ^
	 -geometry -0+92 ^
	 -extent 512x512!
)

rem need to fix "Picture-Transparency" option, cant render "Picture-Drawing".
rem set /a "PicOp=255*%Picture-Transparency%/100"
rem set "Picture-Transparency=-alpha set -channel RGB -evaluate set %PicOp% +channel"

set CODE-FOLDERIFY= ( "%Win11Folderify-BG%" %ReAdjust-Position% ) -compose over -composite

if /i "%Picture-TrimTransparentSpace%"=="yes"	(set "TrimPNG=-trim +repage") else (set "TrimPNG=")

:: Creating mask to carve the picture
set "Win11FolderifyMask=Win11FolderifyMask(%FI-ID%).png"

if /i "%Picture-Drawing%"=="yes" (
	set "PictureIntensity=-modulate %Picture-Drawing-ON-Exposure%,%Picture-Drawing-ON-Saturation% -brightness-contrast %Picture-Drawing-ON-Brightness%x%Picture-Drawing-ON-Contrast% -blur 0x%Picture-Drawing-ON-Smoothness%"
	set "Picture-Drawing=-modulate 95,70 -brightness-contrast 0x10 -background white -channel a -alpha remove -channel rgb -negate -alpha shape"
) else if /i not "%Picture-Drawing%"=="original" (
	set "Picture-Drawing="
	set "PictureIntensity=-modulate %Picture-Drawing-OFF-Exposure%,%Picture-Drawing-OFF-Saturation% -brightness-contrast %Picture-Drawing-OFF-Brightness%x%Picture-Drawing-OFF-Contrast% -blur 0x%Picture-Drawing-OFF-Smoothness%"	
	)

if /i not "%Picture-Shadow%"=="no" set Picture-Shadow-Code= ^
	 ( +clone -background %Shadow-Color% -shadow %Shadow-Opacity%x%Shadow-Blur%+4.5+2.0 ) +swap -background none -layers merge ^
	 ( +clone -background %Shadow-Color% -shadow %Shadow-Opacity%x%Shadow-Blur%-0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background %Shadow-Color% -shadow %Shadow-Opacity%x%Shadow-Blur%-0.1+0.1 ) +swap -background none -layers merge ^
	 ( +clone -background %Shadow-Color% -shadow %Shadow-Opacity%x%Shadow-Blur%+0.1-0.1 ) +swap -background none -layers merge
	 
if /i "%Picture-Shadow%"=="no" set "Picture-Shadow-Code="


if /i not "%Picture-Drawing%"=="original" "%Converter%" ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over ^
	( "%InputFile%" %Picture-Transparency% %TrimPNG% ^
	 %Picture-Drawing% ^
	 -scale %Picture-Width%x%Picture-Height%^ ^
	 -gravity %Picture-Gravity% ^
	 -geometry %Picture-Position-X%%Picture-Position-Y% ^
	 %Picture-Shadow-Code% ^
	) -compose over -composite "%Win11FolderifyMask%"
	 
set CODE-PICTURE=	( ^
	"%Win11Folderify-BG%" %ReAdjust-Position% ^
	-scale 512x512! ^
	%PictureIntensity% ^
	"%Win11FolderifyMask%" ) -compose Over  -composite

if /i "%Picture-Drawing%"=="original" set CODE-PICTURE= ( ^
	"%InputFile%" ^
	-scale %Picture-Width%x%Picture-Height%^ ^
	-gravity %Picture-Gravity% ^
	-geometry %Picture-Position-X%%Picture-Position-Y% ^
	%Picture-Shadow-Code% ^
	) -compose Over -composite

set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"

if /i not "%Picture-Drawing%"=="original" set deltemp=del "Win11FolderifyMask(%FI-ID%).png" "Win11FolderifyLogoMask(%FI-ID%).png" >nul
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
set "Win11FolderifyLogoMask=Win11FolderifyLogoMask(%FI-ID%).png"

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
	 -scale 165x68^ ^
	 -gravity center ^
	 -geometry -134-150 ^
	) -compose over -composite "%Win11FolderifyLogoMask%"
	
set CODE-LOGO-IMAGE= ( ^
	 "%Win11Folderify-BG%" %ReAdjust-Position% ^
	 -scale 512x512! ^
	 -modulate 60,120 -brightness-contrast -5x30 -blur 0x1 ^
	 "%Win11FolderifyLogoMask%" ) -compose Over  -composite
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
if /i not "%display-FolderName%"=="yes" exit /b
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