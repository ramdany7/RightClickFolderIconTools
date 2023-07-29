:: Template-Version=v1.0

::                Template Info
::========================================================
::`  Image template by em1l (www.deviantart.com/em1l)
::`  Convert and edit using ImageMagick.
::` ----------------------------------------------------------------


::                Template Config
::========================================================
set "display-discimage=yes"
set "display-movieinfo=yes"
set "show-Rating=yes"
set "show-Genre=yes"
set "genre-characters-limit=32"
::========================================================


::                Images Source
::========================================================
set "frame-image=%rcfi%\img\dvdbox-dark.png"
set "star-image=%rcfi%\img\star.png"
set "disc-image=%rcfi%\img\disc-vinyl.png"
set "background-image=%rcfi%\img\- background.png"
::========================================================

setlocal
call :LAYER-BASE
call :LAYER-DISC
call :LAYER-RATING
call :LAYER-GENRE
 "%Converter%" ^
  %CODE-BACKGROUND% ^
  %CODE-DISC-IMAGE% ^
  %CODE-POSTER-IMAGE% ^
  %CODE-FRAME-IMAGE% ^
  %CODE-STAR-IMAGE% ^
  %CODE-RATING% ^
  %CODE-GENRE% ^
  %CODE-ICON-SIZE% ^
 "%outputfile%"
endlocal



:::::::::::::::::::::::::::   CODE START   ::::::::::::::::::::::::::::::::

:LAYER-BASE
set CODE-BACKGROUND= ( "%background-image%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
	) -compose Over

set CODE-POSTER-IMAGE= ( "%inputfile%" ^
	 -scale 348x486! ^
	 -background none ^
	 -gravity Northwest ^
	 -geometry +14+10 ^
	 ) -compose Over -composite

set CODE-FRAME-IMAGE= ( "%frame-image%" ^
	 -resize 512x512! ^
	 ) -compose Over -composite

set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b

:LAYER-DISC
if /i not "%display-discimage%"=="yes" exit /b

if exist "*discart.png" (
	for %%D in (*discart.png) do set "discart=%%~fD"
) else set "discart=%disc-image%"

set CODE-DISC-IMAGE= ( "%discart%" ^
	 -scale 340x340! ^
	 -background none ^
	 -extent 512x512-160-84 ^
	 ( +clone -background BLACK -shadow 100x1.3+2+2 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
call :GetInfo-nfo_file
if /i not "%Show-Rating%" EQU "yes" exit /b
if not defined rating exit /b

set CODE-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x88! ^
	 -extent 512x512-0-416 ^
	 ( +clone -background BLACK -shadow 40x1.2+1.8+3 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite

set CODE-RATING= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill rgba(0,0,0,0.9) ^
	 -density 400 ^
	 -pointsize 6 ^
	 label:"%rating%" ^
	 -gravity Northwest ^
	 -geometry +13+443  ^
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
	 -gravity NorthWest ^
	 -geometry +74+460 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.7+2.7 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.7-2.7 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.7+2.7 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.7-2.7 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:GetInfo-nfo_file
if not exist "*.nfo" (
	rem echo %TAB% %g_%No ".nfo" detected.%r_% 
	exit /b
)

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

if defined value (
	set "rating=%value:~0,3%"
) else echo %TAB%%r_%%i_% %_%%g_% Error: No rating value provided in "%nfoName%"%r_%

if not defined genre (
	echo %TAB%%r_%%i_% %_%%g_% Error: No genre provided in "%nfoName%"%r_%
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