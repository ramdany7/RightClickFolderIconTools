::      Template Info
::===================================
::# "dvdbox-disc.png" Edit by Ramdany, Design by em1l (www.deviantart.com/em1l)
::#  Convert and edit using ImageMagick. 
::# -------------------------------------------------------------------

::                Template Config
::========================================================
:: Note: 
:: - To see a list of fonts available in this system, you 
::   can check it in the "RCFI Tools\magick\font_list.bat" file.
::--------- Test Mode -------
set "testmode=no"
set "testmode-auto-execute=yes"

::--------- Show Info -------
set "display-discimage=yes"
set "display-movieinfo=yesh"
set "Show-Rating=yes"
set "Show-Genre=yes"
set "genre-characters-limit=33"

set "frame-image=%rcfi%\img\dvdbox-shine.png"
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
set BACKGROUND-CODE= ( "%background-image%" ^
	-scale 256x256! ^
	-background none ^
	-extent 256x256 ^
 ) -compose Over

:LAYER-DISC_IMAGE
if exist "*discart.png" (
	for %%D in (*discart.png) do set "discart=%%~fD"
) else set "discart=%disc-image%"
set DISC-IMAGE-CODE= ( "%discart%" ^
	 -scale 170x170! ^
	 -background none ^
	 -extent 256x256-82-42 ^
	 ( +clone -background BLACK -shadow 100x1.3+2+2 ) ^
	 +swap -background none -layers merge -extent 256x256 ^
	 ) -compose Over -composite

if /i not "%display-discimage%"=="yes" set "DISC-IMAGE-CODE="


:LAYER-POSTER_IMAGE
set POSTER-IMAGE-CODE= ( "%inputfile%" ^
	 -scale 170x242! ^
	 -background none ^
	 -gravity Northwest ^
	 -geometry +3+5 ^
	 ) -compose Over -composite


:LAYER-TEMPLATE_FRAME
set FRAME-IMAGE-CODE= ( "%frame-image%" ^
	 -resize 256x256! ^
	 ) -compose Over -composite


:LAYER-STAR_IMAGE
if defined rating set STAR-IMAGE-CODE= ( ^
	 "%star-image%" ^
	 -scale 44x43! ^
	 -extent 256x256-0-208 ^
	 ( +clone -background BLACK% ^
	 -shadow 40x1.2+1.8+3 ) ^
	 +swap -background none -layers merge -extent 256x256 ^
	 ) -compose Over -composite

if /i not "%Show-Rating%" EQU "yes" set "STAR-IMAGE-CODE="
if /i not "%display-movieinfo%" EQU "yes" set "STAR-IMAGE-CODE="


:LAYER-RATING_TEXT
if /i not "%Show-Rating%" EQU "yes" goto LAYER-5
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
 
 
:LAYER-GENRE_TEXT
if /i not "%Show-Genre%" EQU "yes" goto TemplateCommand
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