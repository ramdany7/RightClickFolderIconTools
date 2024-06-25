:: Template-Version=v1.0

::                Template Info
::========================================================
::`  This template will also be used to automatically
::`  generate DiscArt for "DVD Box" templates.
::` ------------------------------------------------------


::                Template Config
::========================================================
::--------- Label --------------------------
set "display-label=yes"
set "display-logo=yes"
::========================================================


::                Images Source
::========================================================
set "discArt-main=%RCFI%\images\DiscArt-Main.png"
set "discArt-border=%RCFI%\images\DiscArt-Border.png"
set "discArt-transparent=%RCFI%\images\DiscArt-Transparent.png"
set "discArt-label=%RCFI%\images\DiscArt-Label.png"
set "discArt-logo=%RCFI%\images\DiscArt-Logo.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================


::                Code
::========================================================
if /i not "%display-label%"=="yes" set "discArt-label=%canvas%"
if /i not "%display-logo%"=="yes" set "discArt-logo=%canvas%"
if /i "%Template%"=="%~f0" if /i "%Context%"=="IMG.Generate.PNG" for %%D in ("%OutputFile%") do set "DiscArtName=%%~dpnD"&Call :DiscArt-Add_Suffix
if /i "%referrer%"=="DVDcase" (
	set "inDiscArt=%gen_disc%"
	set "outDiscArt=%cd%\DiscArt(%FI-ID%).png"
	set "DiscArt=%cd%\DiscArt(%FI-ID%).png"
	set deltempfile=del "%cd%\DiscArt(%FI-ID%).png"
) else set "outDiscArt=%OutputFile%"&set "inDiscArt=%inputfile%"
 "%Converter%" ^
  ( "%canvas%" -scale 512x512! -background none -extent 512x512 ) -compose Over ^
  ( "%inDiscArt%" -scale 485x485! -gravity center "%discArt-main%" ) -compose over -composite ^
  ( "%discArt-transparent%" -scale 512x512! ) -compose over -composite ^
  ( "%discArt-label%" -scale 512x512! ) -compose over -composite ^
  ( "%discArt-logo%" -scale 512x512! ) -compose over -composite ^
  ( "%inDiscArt%" -scale 900x900! -blur 0x30 -brightness-contrast 0x30 "%discArt-border%" ) -compose over -composite ^
  -define icon:auto-resize="%TemplateIconSize%" ^
 "%outDiscArt%"
exit /b

:DiscArt-Add_Suffix
set "OutputFile=%DiscArtName%-discart%NumName%.png"
if exist "%OutputFile%" (set /a NumNameCount+=1) else exit /b
set "NumName=(%NumNameCount%)"
goto DiscArt-Add_Suffix