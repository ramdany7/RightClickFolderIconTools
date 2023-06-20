::      Template Info
::===================================
::#  "Folder - Vertical" PSD Template by 90scomics.com
::#  Convert and Edit using ImageMagick.
::# -------------------------------------------------------------------

::                Template Config
::========================================================
::--------- Test Mode -------
set "testmode=no"
set "testmode-auto-execute=yes"
::--------- Display ---------
set "display-discimage=no"
set "display-movieinfo=no"
set "Show-Rating=yes"
set "Show-Genre=yes"
set "genre-characters-limit=26"
set "FolderNameShort-characters-limit=11"
set "FolderNameLong-characters-limit=40"
::------ Image source -------
set "foldervertical-side=%rcfi%\img\foldervertical-side.png"
set "foldervertical-sidefx=%rcfi%\img\foldervertical-sidefx.png"
set "foldervertical-sideshadow=%rcfi%\img\foldervertical-sideshadow.png"
set "foldervertical-main=%rcfi%\img\foldervertical-main.png"
set "foldervertical-mainfx=%rcfi%\img\foldervertical-mainfx.png"
set "star-image=%rcfi%\img\star.png"
set "disc-image=%rcfi%\img\disc-vinyl.png"
set "background-image=%rcfi%\img\- background.png"
::========================================================



:: Get Movie info from .nfo file
:GetInfo
setlocal
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
:GetInfo-FolderName-Long
set /a FolNamLongCount+=1
if not "%_FolNamLong%"=="%FolderName%" (
	call set "_FolNamLong=%%FolderName:~0,%FolNamLongCount%%%"
	goto GetInfo-FolderName-Long
)
set /A "FolNamLongLimiter=%FolNamLongLimit%-4"
if %FolNamLongCount% GTR %FolNamLongLimit% call set "FolNamLong=%%FolderName:~0,%FolNamLongLimiter%%%..."

if "%display-movieinfo%"=="yes" (
	if not exist "*.nfo" (
		echo %TAB% %g_%No ".nfo" detected.%r_% 
		goto Layer
	)
) else (goto Layer)
for %%N in (*.nfo) do (
	set "nfoName=%%~nxN"
	for /f "usebackq tokens=1,2,3,4 delims=<>" %%C in ("%%N") do (
		if /i not "%%D"=="" (
			if /i not "%%D"=="genre" (set "%%D=%%E") else (
				set "genre=%%E" 
				call :GetInfo-Collect
			)
		)
	)
)
if not defined value		echo %TAB%%r_%%i_% %_%%g_% Error: No rating value provided in "%nfoName%"%r_%
if not defined genre		echo %TAB%%r_%%i_% %_%%g_% Error: No genre provided in "%nfoName%"%r_%
set "rating=%value:~0,3%"
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
goto Layer
:GetInfo-Collect
set "_genre=%_genre%, %genre%"
exit /b




:: Proceed to edit and convert the image using ImageMagick
:Layer
:LAYER-BACKGROUND
set BACKGROUND-CODE= ( "%background-image%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over

:LAYER-DISC_IMAGE
if exist "*discart.png" (
	for %%D in (*discart.png) do set "discart=%%~fD"
) else set "discart=%disc-image%"
set DISC-IMAGE-CODE= ( "%discart%" ^
	 -scale 300x300! ^
	 -background none ^
	 -extent 512x512-205-120 ^
	 ( +clone -background BLACK -shadow 100x1.3+2+2 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite

if /i not "%display-discimage%"=="yes" set "DISC-IMAGE-CODE="


:LAYER-STAR_IMAGE
if defined rating set STAR-IMAGE-CODE= ( ^
	 "%star-image%" ^
	 -scale 75x75! ^
	 -extent 512x512-44-428 ^
	 ( +clone -background BLACK% ^
	 -shadow 40x1.2+1.8+3 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite

if /i not "%Show-Rating%" EQU "yes" set "STAR-IMAGE-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "STAR-IMAGE-CODE="


:LAYER-RATING_TEXT
if defined RATING set RATING-CODE= ( ^
	 -font Arial-Bold ^
	 -fill BLACK ^
	 -pointsize 26 ^
	 label:"%rating%" ^
	 -extent 512x512-61-457 ^
	 ( +clone -background black -shadow 0x1.3+2+3.5 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite 
 
if /i not "%Show-Rating%" EQU "yes" set "RATING-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "RATING-CODE="


:LAYER-GENRE_TEXT
if defined GENRE set GENRE-CODE= ( ^
	 -font Arial-Bold ^
	 -fill BLACK ^
	 -pointsize 25 ^
	 -gravity Northwest ^
	 -geometry +110+465 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1+0.6-0.6 ) +swap -background none -layers merge ^
	 ) -composite 

if /i not "%Show-Genre%" EQU "yes" set "GENRE-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "GENRE-CODE="
 
 
:LAYER-POSTER_SIDE
set POSTER-SIDE-CODE= ( ^
	 "%inputfile%" ^
	 -scale 512x512! ^
	 -blur 0x19 ^
	 "%foldervertical-side%" ) -compose over -composite ^
	 ( "%foldervertical-sidefx%" -scale 512x512! ) -compose over -composite
   

:LAYER-FOLDER_NAME
set FOLDER-NAME-SHORT-CODE= ^
	 ( ^
	 -font Arial-Bold ^
	 -fill white ^
	 -pointsize 27 ^
	 -gravity Northwest ^
	 -geometry +398+30 ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 10x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.6-0.6 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

set FOLDER-NAME-LONG-CODE= ^
	 ( ^
	 -font Arial-Bold  ^
	 -fill white ^
	 -pointsize 17 ^
	 -kerning 2 ^
	 -gravity Northwest ^
	 -geometry +416+45 ^
	 label:"%FolNamLong%" ^
	 -rotate 90 ) -composite
if %FolNamShortCount% LEQ %FolNamShortLimit% set "FOLDER-NAME-LONG-CODE="


:LAYER-SIDE-POSTER-SHADOW
set POSTER-SIDE-SHADOW-CODE= ( "%foldervertical-sideshadow%" -scale 512x512! ) -compose over -composite

:LAYER-POSTER-MAIN
set POSTER-MAIN-CODE= ( ^
	 "%inputfile%" ^
	 -scale 346x490! ^
	 -gravity Northwest ^
	 -geometry +70+14 ^
	 "%foldervertical-main%" ) -compose over -composite ^
	 ( "%foldervertical-mainfx%" -scale 512x512! ) -compose over -composite




::      Template Command
::===================================
:EXECUTE-TEMPLATE
 "%Converter%" ^
  %BACKGROUND-CODE% ^
  %POSTER-SIDE-CODE% ^
  %FOLDER-NAME-SHORT-CODE% ^
  %FOLDER-NAME-LONG-CODE% ^
  %DISC-IMAGE-CODE% ^
  %POSTER-SIDE-SHADOW-CODE% ^
  %POSTER-MAIN-CODE% ^
  %STAR-IMAGE-CODE% ^
  %RATING-CODE% ^
  %GENRE-CODE% ^
  -scale 256x256! ^
 "%outputfile%"
endlocal