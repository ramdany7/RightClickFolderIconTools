:: Template-Version=v1.0

::                Template Info
::========================================================
::`  Template style by Jonathan Brimer
::`  https://beoriginal.com/blog/free-folder-icon-photoshop-template
::` ------------------------------------------------------


::                Template Config
::========================================================
::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderNameShort-characters-limit=11"
set "FolderNameShort-font=Arial-Bold"
set "FolderNameLong-characters-limit=38"
set "FolderNameLong-font=Arial"
set "FolderName-Center=Auto"


::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "show-Genre=yes"
set "genre-characters-limit=31"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=yes"

::--------- Additional Config --------------
set "Picture-Opacity=100%"
set "Background-Brightness=-5"
set "Background-Exposure=80"
set "Background-Contrast=27"
set "Background-Saturation=150"
set "Background-Blur=200"
set "Background-AmbientColor=2"
::========================================================


::                Images Source
::========================================================
set "BeOriginal-Back=%rcfi%\images\BeOriginal-Back.png"
set "BeOriginal-BackFx=%rcfi%\images\BeOriginal-BackFx.png"
set "BeOriginal-Front=%rcfi%\images\BeOriginal-Front.png"
set "BeOriginal-FrontFx=%rcfi%\images\BeOriginal-FrontFx.png"
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
set CODE-BACKGROUND= ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over

set /a "PicOp=255*%Picture-Opacity%/100"
set "Picture-Opacity=-alpha set -channel A -evaluate set %PicOp% +channel"

set CODE-FRONT= ( ^
	 "%inputfile%" ^
	 -scale 480x318! ^
	 -gravity Northwest ^
	 -geometry +18+124 ^
	 %Picture-Opacity% "%BeOriginal-Front%" )   -compose over -composite ^
	 ( "%BeOriginal-FrontFx%" -scale 512x512! ) -compose over -composite
	 
if /i "%Background-AmbientColor%"=="0" set CODE-BACK= ( "%inputfile%" -scale 512x512! ) -compose over -composite

if /i not "%Background-AmbientColor%"=="0" set CODE-BACK= ( ^
	 "%inputfile%" ^
	 -modulate 100x%Background-Saturation% ^
	 -modulate %Background-Exposure%x100 ^
	 -brightness-contrast 0x5 ^
	 -modulate 100x130 ^
	 -resize %Background-AmbientColor%x%Background-AmbientColor%! ^
	 -resize 1000x1000! ^
	 -scale 512x512! ^
	 -gravity Center ^
	 -blur 0x%Background-Blur% ^
	 -brightness-contrast %Background-Brightness%x0 ^
	 -brightness-contrast 0x%Background-Contrast% ^
	 -blur 0x20 ^
	 "%BeOriginal-Back%" ) -compose over -composite ^
	 ( "%BeOriginal-BackFx%" -scale 512x512! ) -compose over -composite
	 
set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Rating%" EQU "yes" exit /b
call :GetInfo-nfo_file

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
	 -scale 145x45^ ^
	 -background none ^
	 -gravity center ^
	 -geometry -155-157 ^
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
	 -scale 295x123^ ^
	 -background none ^
	 -gravity South ^
	 -geometry +90+383 ^
	 ) -compose Over -composite
exit /b


:LAYER-FOLDER_NAME
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


set "FolNamCenter=-gravity center -geometry -155-165"
set "FolNamLeft=-gravity Northwest -geometry -5+35"
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
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize 4.5 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 10x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.6-0.6 ) +swap -background none -layers merge ^
	 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b

set CODE-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%FolderNameLong-font%" ^
	 -fill rgba(255,255,255,0.9) ^
	 -density 400 ^
	 -pointsize 2.5 ^
	 -kerning 2 ^
	 -gravity Northwest ^
	 -geometry +1+68 ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 10x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.2-0.2 ) +swap -background none -layers merge ^
	 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "CODE-FOLDER-NAME-LONG="
exit /b


:GetInfo-nfo_file
if not exist "*.nfo" (
	rem echo %TAB% %g_%No ".nfo" detected.%r_% 
	exit /b
)

for %%N in (*.nfo) do (
	set "nfoName=%%~nxN"
	echo %TAB%%ESC%%g_%Movie info  :%%~nxN%ESC%
	for /f "usebackq tokens=1,2,3,4 delims=<>" %%C in ("%%N") do (
		if /i not "%%D"=="" (
			if /i not "%%D"=="genre" (set "%%D=%%E") else (
				set "genre=%%E" 
				call :GetInfo-Collect
			)
		)
	)
)

if not defined value if defined userrating if not "%userrating%"=="0" set "value=%userrating%"
if defined value (
	set "rating=%value:~0,3%"
) else echo %TAB% %r_%%i_% %_%%g_% Error: No rating value provided in "%nfoName%"%r_%

if "%rating%"=="0.0" echo %TAB% %r_%%i_% %_%%g_% Error: No rating value provided in "%nfoName%"%r_%&set "rating="
if "%rating%"=="10." set "rating=10"

if not defined genre (
	echo %TAB% %r_%%i_% %_%%g_% Error: No genre provided in "%nfoName%"%r_%
	exit /b
)
set "genre=__%_genre%"
set "genre=%genre:__, =%"
set "genre=%genre:Science Fiction=SciFi%"
set "GenreLimit=%genre-characters-limit%"
set /a "GenreLimit=%GenreLimit%+1"

:GetInfo-Genre
set /a GenreCount+=1
if not "%_genre%"=="%genre%" (
	call set "_genre=%%genre:~0,%GenreCount%%%"
	goto GetInfo-Genre
)
set /A "GenreLimiter=%GenreLimit%-4"
if %GenreCount% GTR %GenreLimit% call set "genre=%%genre:~0,%GenreLimiter%%%..."
exit /b

:GetInfo-Collect
set "_genre=%_genre%, %genre%"
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::