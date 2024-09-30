::      Template Info
::===================================
::` kometa style media display.
::` -------------------------------------------------------------------

::                Template Config
::========================================================
set "use-GlobalConfig=Yes"

::--------- Movie Info ---------------------
set "display-MovieInfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=21"


::--------- Poster -------------------------
set "poster-size=343x492"
set "poster-gravity=center"
set "poster-X-position=-2"
set "poster-Y-position=+0"

::--------- Rating -------------------------
set "rating-font-style=Arial-Bold"
set "rating-font-color=rgba(255,255,255,0.9)"
set "rating-font-size=3.6"
set "rating-gravity=Southwest"
set "rating-X-position=+21"
set "rating-Y-position=+151"

set "BG-rating-size=84x30"
set "BG-rating-gravity=Southwest"
set "BG-rating-X-position=+19"
set "BG-rating-Y-position=+100"

::--------- Genre --------------------------
set "genre-font-style=Arial-Bold"
set "genre-font-color=rgba(255,255,255,0.9)"
set "genre-font-size=3.6"
set "genre-gravity=Southwest"
set "genre-X-position=+21"
set "genre-Y-position=+194"

set "BG-genre-size=224x30"
set "BG-genre-gravity=Southwest"
set "BG-genre-X-position=+19"
set "BG-genre-Y-position=+190"
::========================================================
 
::                Images Source
::========================================================
set "Kometa-shape=%rcfi%\images\Kometa-shape.png"
set "Kometa-shadow=%rcfi%\images\Kometa-shadow.png"
set "rating-background=%rcfi%\images\Kometa-rating.png"
set "genre-background=%rcfi%\images\Kometa-genre.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================
setlocal
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
 "%Converter%"         ^
  %CODE-BACKGROUND%    ^
  %CODE-POSTER%        ^
  %CODE-RATING-BG%     ^
  %CODE-RATING%        ^
  %CODE-GENRE-BG%      ^
  %CODE-GENRE%         ^
  %CODE-ICON-SIZE%     ^
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

set CODE-BACKGROUND= ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over

set CODE-POSTER= ( "%inputfile%" ^
	 -scale %poster-size%! ^
	 -background none ^
	 -gravity %poster-gravity% ^
	 -geometry %poster-Y-position%%poster-X-position% ^
	 "%Kometa-shape%" ) -compose Over -composite ^
	 ( "%Kometa-shadow%" -scale 512x512! ) -compose over -composite
set CODE-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b


:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set CODE-RATING-BG= ( "%rating-background%" ^
	 -scale %BG-rating-size%! ^
	 -gravity %BG-rating-gravity% ^
	 -geometry %BG-rating-Y-position%%BG-rating-X-position% ^
	 ) -compose Over -composite
	 if not defined rating exit /b

set CODE-RATING= ( ^
	 -font %rating-font-style% ^
	 -fill %rating-font-color% ^
	 -density 400 ^
	 -pointsize %rating-font-size% ^
	 -kerning 0 ^
	 -gravity %rating-gravity% ^
	 -geometry %rating-Y-position%%rating-X-position% ^
	 label:"%rating%" ^
	) -compose Over -composite 
exit /b


:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined GENRE exit /b

set CODE-GENRE-BG= ( ^
	 "%genre-background%" ^
	 -scale %BG-genre-size%! ^
	 -gravity %BG-genre-gravity% ^
	 -geometry %BG-genre-Y-position%%BG-genre-X-position% ^
	 ) -compose Over -composite
	 if not defined rating exit /b
	 
set CODE-GENRE= ( ^
	 -font %genre-font-style% ^
	 -fill %genre-font-color% ^
	 -density 400 ^
	 -pointsize %genre-font-size% ^
	 -kerning 0 ^
	 -gravity %genre-gravity% ^
	 -geometry %genre-Y-position%%genre-X-position% ^
	 label:"%genre%" ^
	 ) -compose Over -composite 
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::