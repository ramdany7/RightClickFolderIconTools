:: Template-Version=v1.2
:: 2024-06-22 Fix: The star image was rendered in the generated folder icon even when the “.nfo” file didn’t exist.
:: 2024-06-24 Adding Global Config to override template config using RCFI.template.ini.
:: 2024-06-24 Adding gradient brightness, gradient shadow and bevel shadow. 


::                Template Info
::========================================================
::` Windows 11 style folder icon.
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

::--------- Folder Name --------------------
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
	set "FolderNameShort-Pos-Left-Direction=SouthWest"
	set "FolderNameShort-Pos-Left-X=-18"
	set "FolderNameShort-Pos-Left-Y=+360"
	
	:: Folder name position when it's on the center
	set "FolderNameShort-Pos-Center-Direction=Center"
	set "FolderNameShort-Pos-Center-X=-148"
	set "FolderNameShort-Pos-Center-Y=-167"
	
	set "FolderNameLong-characters-limit=20"
	set "FolderNameLong-font=Microsoft-PhagsPa"
	set "FolderNameLong-size=3.5"
	set "FolderNameLong-Pos-Direction=Northwest"
	set "FolderNameLong-Pos-X=-15"
	set "FolderNameLong-Pos-Y=+75"

::--------- Additional Config --------------
set "Picture-Opacity=100%"

set "Background-Brightness=5"
set "Background-Contrast=20"
set "Background-Exposure=105"
set "Background-Saturation=150"
set "Background-Blur=200"
set "Background-AmbientColor=2"

set "Bevel-Brightness=25"
set "Bevel-Contrast=10"
set "Bevel-Exposure=110"
set "Bevel-Saturation=110"

set "Gradient-Brightness=20"
set "Gradient-Contrast=10"
set "Gradient-Exposure=110"
set "Gradient-Saturation=110"
::========================================================


::                Images Source
::========================================================
set "Win11-Back=%rcfi%\images\Win11A-Back.png"
set "Win11-Back-Gradient=%rcfi%\images\Win11A-Back-Gradient.png"
set "Win11-Front=%rcfi%\images\Win11A-Front.png"
set "Win11-Front-Gradient=%rcfi%\images\Win11A-Front-Gradient.png"
set "Win11-Front-GradientShadow=%rcfi%\images\Win11A-Front-GradientShadow.png"
set "Win11-Front-Bevel=%rcfi%\images\Win11A-Front-Bevel.png"
set "Win11-Front-BevelShadow=%rcfi%\images\Win11A-Front-BevelShadow.png"
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
  %CODE-BACK%              ^
  %CODE-FOLDER-NAME-SHORT% ^
  %CODE-FOLDER-NAME-LONG%  ^
  %CODE-LOGO-IMAGE%        ^
  %CODE-CLEARART-IMAGE%    ^
  %CODE-FRONT%             ^
  %CODE-STAR-IMAGE%        ^
  %CODE-RATING%            ^
  %CODE-GENRE%             ^
  %CODE-ICON-SIZE%         ^
 "%OutputFile%"
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

set /a "PicOp=255*%Picture-Opacity%/100"
set "Picture-Opacity=-alpha set -channel A -evaluate set %PicOp% +channel"
set /a "PicOpBevel=%PicOp%+30"
set "Picture-Opacity-Bevel=-alpha set -channel A -evaluate set %PicOpBevel% +channel"

set CODE-FRONT= ( ^
	 "%inputfile%" ^
	 -scale 498x320! ^
	 -gravity Northwest ^
	 -geometry +5+117 ^
	 %Picture-Opacity% "%Win11-Front%" ) -compose over -composite ^
	 ( ^
	 "%inputfile%" ^
	 -scale 498x320! ^
	 -gravity Northwest ^
	 -geometry +5+117 ^
	 -brightness-contrast -9x10 ^
	 %Picture-Opacity-Bevel% "%Win11-Front-BevelShadow%" ) -compose over -composite ^
	 ( ^
	 "%inputfile%" ^
	 -scale 498x320! ^
	 -gravity Northwest ^
	 -geometry +5+117 ^
	 -modulate %Bevel-Exposure%,%Bevel-Saturation% ^
	 -brightness-contrast %Bevel-Brightness%x%Bevel-Contrast% ^
	 %Picture-Opacity-Bevel% "%Win11-Front-Bevel%" ) -compose over -composite ^
	 ( ^
	 "%inputfile%" ^
	 -scale 498x320! ^
	 -gravity Northwest ^
	 -geometry +5+117 ^
	 -brightness-contrast %Gradient-Brightness%x%Gradient-Contrast% ^
	 -modulate %Gradient-Exposure%,%Gradient-Saturation% ^
	 %Picture-Opacity% "%Win11-Front-Gradient%" ) -compose over -composite ^
	 ( ^
	 "%inputfile%" ^
	 -scale 498x320! ^
	 -gravity Northwest ^
	 -geometry +5+117 ^
	 -brightness-contrast -6x10^
	 -modulate 94,100 ^
	 %Picture-Opacity% "%Win11-Front-GradientShadow%" ) -compose over -composite
	 
if /i "%Background-AmbientColor%"=="0" set CODE-BACK= ( "%Win11-Back%" -scale 512x512! ) -compose over -composite

if /i not "%Background-AmbientColor%"=="0" set CODE-BACK= ( ^
	 "%inputfile%" ^
	 -resize %Background-AmbientColor%x%Background-AmbientColor%! ^
	 -resize 1000x1000! ^
	 -scale 390x390! ^
	 -gravity Center ^
	 -modulate %Background-Exposure%,%Background-Saturation% ^
	 -brightness-contrast -10x0 ^
	 -blur 0x%Background-Blur% ^
	 -brightness-contrast %Background-Brightness%x%Background-Contrast% ^
	 -modulate 95,100 ^
	 "%Win11-Back%" -scale 512x512! ) -compose over -composite ^
	 ( "%inputfile%" ^
	 -resize %Background-AmbientColor%x%Background-AmbientColor%! ^
	 -resize 1000x1000! ^
	 -scale 390x390! ^
	 -gravity Center ^
	 -modulate 100,%Background-Saturation% ^
	 -blur 0x%Background-Blur% ^
	 -brightness-contrast %Background-Brightness%x%Background-Contrast% ^
	 -brightness-contrast -50x10 ^
	  "%Win11-Back-Gradient%" -scale 512x512! ) -compose over -composite
	  
set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
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
	 -geometry +79+400 ^
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

set CODE-LOGO-IMAGE= ( "%Logo%" ^
	 -trim +repage ^
	 -scale 168x64^ ^
	 -background none ^
	 -gravity center ^
	 -geometry -147-155 ^
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
	 -scale 260x117^ ^
	 -background none ^
	 -gravity South ^
	 -geometry +90+392 ^
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


set "FolNamCenter=-gravity %FolderNameShort-Pos-Center-Direction% -geometry %FolderNameShort-Pos-Center-X%%FolderNameShort-Pos-Center-Y%"
set "FolNamLeft=-gravity %FolderNameShort-Pos-Left-Direction% -geometry %FolderNameShort-Pos-Left-X%%FolderNameShort-Pos-Left-Y%"
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
	 ( +clone -background BLACK -shadow 6x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 6x5+0.6-0.6 ) +swap -background none -layers merge ^
	 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b

set CODE-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%FolderNameLong-font%" ^
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize %FolderNameLong-size% ^
	 -kerning -0.5 ^
	 -gravity %FolderNameLong-Pos-Direction% ^
	 -geometry %FolderNameLong-Pos-X%%FolderNameLong-Pos-Y% ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 3x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 3x5+0.2-0.2 ) +swap -background none -layers merge ^
	 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "CODE-FOLDER-NAME-LONG="
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::