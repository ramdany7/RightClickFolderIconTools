:: Template-Version=v1.2
:: 2024-06-22 Fix: The star image was rendered in the generated folder icon even when the “.nfo” file didn’t exist.
:: 2024-06-24 Adding Global Config to override template config using RCFI.template.ini.

::                Template Info
::========================================================
::`  Image template by em1l (www.deviantart.com/em1l)
::`  Convert and edit using ImageMagick. 
::` ----------------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=Yes"

set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=26"
::========================================================


::                Images Source
::========================================================
set "frame-image=%rcfi%\images\dvdcase-plastic.png"
set "frame-image-mask=%rcfi%\images\dvdcase-plastic-mask.png"
set "star-image=%rcfi%\images\star.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================

setlocal
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
 "%Converter%"        ^
  %CODE-BACKGROUND%   ^
  %CODE-POSTER-IMAGE% ^
  %CODE-FRAME-IMAGE%  ^
  %CODE-STAR-IMAGE%   ^
  %CODE-RATING%       ^
  %CODE-GENRE%        ^
  %CODE-ICON-SIZE%    ^
 "%OutputFile%"
endlocal



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

set CODE-POSTER-IMAGE= ( ^
	 "%inputfile%" ^
	 -scale 336x474! ^
	 -gravity Northwest ^
	 -geometry +108+14 ^
	 "%frame-image-mask%" ) -compose over -composite

set CODE-FRAME-IMAGE= ( "%frame-image%" ^
	 -resize 512x512! ^
	 ) -compose Over -composite
	 
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
	 -geometry +370+405  ^
	 ( +clone -background BLACK -shadow 40x1.2+1.8+3 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite
	 if not defined rating exit /b
	 
set CODE-RATING= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill rgba(0,0,0,0.9) ^
	 -density 400 ^
	 -pointsize 6 ^
	 label:"%rating%" ^
	 -gravity Northwest ^
	 -geometry +383+432  ^
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
	 -gravity SouthEast ^
	 -geometry +123+15 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.7+2.7 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.7-2.7 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.7+2.7 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.7-2.7 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::
