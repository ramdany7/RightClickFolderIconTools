::      Template Info
::===================================
::# "bluray-case.png" Template design by Saikuro (www.deviantart.com/saikuro)
::#  Convert and edit using ImageMagick. 
::# -------------------------------------------------------------------

::                Template Config
::========================================================
:: Note: 
:: - To see a list of fonts available in this system, you 
::   can check it in the "RCFI Tools\magick\font_list.bat" file.
::
::--------- Test Mode ------- 
set "testmode=no"
set "testmode-auto-execute=yes"
::--------- Display ---------
set "display-discimage=yes"
set "display-movieinfo=no"
set "show-Rating=yes"
set "show-Genre=yes"
set "genre-characters-limit=33"
::------ Image Source -------
set "frame-image=%rcfi%\img\dvdbox-dark.png"
set "star-image=%rcfi%\img\star.png"
set "disc-image=%rcfi%\img\disc-vinyl.png"
set "background-image=%rcfi%\img\- background.png"
::========================================================




:: Get Movie info from .nfo file
:GetInfo
setlocal
if "%display-movieinfo%"=="yes" (
	if not exist "*.nfo" (
		echo %TAB% %g_%No ".nfo" detected.%r_% 
		goto Layer
	)
) else (goto Layer)
if exist "*.nfo" (
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
) else goto Layer
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
:: Get background image
set BACKGROUND-CODE= ( "%background-image%" ^
	-scale 256x256! ^
	-background none ^
	-extent 256x256 ^
	) -compose Over


:LAYER-DISCART
:: Get disc art image
if exist "*discart.png" (
	for %%D in (*discart.png) do set "discart=%%~fD"
) else set "discart=%disc-image%"

:: Configure disc art image size, position, and shadows
set DISC-IMAGE-CODE= ( "%discart%" ^
	 -scale 170x170! ^
	 -background none ^
	 -extent 256x256-80-42 ^
	 ( +clone -background BLACK -shadow 100x1.3+2+2 ) ^
	 +swap -background none -layers merge -extent 256x256 ^
	 ) -compose Over -composite

if /i not "%display-discimage%"=="yes" set "DISC-IMAGE-CODE="


:LAYER-POSTER
set POSTER-IMAGE-CODE= ( "%inputfile%" ^
	 -scale 174x243! ^
	 -background none ^
	 -gravity Northwest ^
	 -geometry +7+5 ^
	 ) -compose Over -composite


:LAYER-TEMPLATE_FRAME
set FRAME-IMAGE-CODE= ( "%frame-image%" ^
	 -resize 256x256! ^
	 ) -compose Over -composite


:LAYER-RATING-STAR_IMAGE
if defined rating set STAR-IMAGE-CODE= ( ^
	 "%star-image%" ^
	 -scale 44x43! ^
	 -extent 256x256-0-208 ^
	 ( +clone -background BLACK -shadow 40x1.2+1.8+3 ) ^
	 +swap -background none -layers merge -extent 256x256 ^
	 ) -compose Over -composite
	 
if /i not "%Show-Rating%" EQU "yes" set "STAR-IMAGE-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "STAR-IMAGE-CODE="

:LAYER-RATING-TEXT
if defined RATING set RATING-CODE= ( ^
	 -font Arial-Bold ^
	 -fill BLACK ^
	 -pointsize 17 ^
	 label:"%rating%" ^
	 -extent 256x256-9-223 ^
	 ( +clone -background black -shadow 0x1.3+2+3.5 ) ^
	 +swap -background none -layers merge -extent 256x256 ^
	 ) -compose Over -composite 

if /i not "%Show-Rating%" EQU "yes" set "RATING-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "RATING-CODE="

:LAYER-GENRE
if defined GENRE set GENRE-CODE= ( ^
	 -font Arial-Bold ^
	 -fill BLACK ^
	 -pointsize 13 ^
	 -gravity Northwest ^
	 -geometry +37+225 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1+0.6-0.6 ) +swap -background none -layers merge ^
	 ) -composite 

if /i not "%Show-Genre%" EQU "yes" set "GENRE-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "GENRE-CODE="




::      Template Command
::===================================
:EXECUTE-TEMPLATE
 "%Converter%" ^
  %BACKGROUND-CODE% ^
  %DISC-IMAGE-CODE% ^
  %POSTER-IMAGE-CODE% ^
  %FRAME-IMAGE-CODE% ^
  %STAR-IMAGE-CODE% ^
  %RATING-CODE% ^
  %GENRE-CODE% ^
 "%outputfile%"
endlocal