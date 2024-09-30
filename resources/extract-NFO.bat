for %%N in (*.nfo) do (
	set "nfoName=%%~nxN"
	echo %TAB%%ESC%%g_%Movie info  :%%~nxN%ESC%
	for /f "usebackq tokens=1,2,3,4 delims=<>" %%C in ("%%N") do (
		if /i not "%%D"=="" (
			if /i "%%D"=="value" (set "%%D=%%E"&call :GetInfo-Rating) else set parameter=%%D
			if /i not "%%D"=="genre" (set "%%D=%%E") else (
				set "genre=%%E" 
				call :GetInfo-Collect
			)
		)
	)
)

if /i "%preferred-rating%"=="imdb" (
	if defined imdb-rating (
		set "value=%imdb-rating%"
	) else  echo %TAB%%G_% Rating name :IMDB, is not provided in "%nfoName%"%r_%
)

if /i "%preferred-rating%"=="tmdb" (
	if defined themoviedb-rating (
		set "value=%themoviedb-rating%"
	) else echo %TAB%%G_% Rating name :TMDB, is not provided in "%nfoName%"%r_%
)

if /i "%preferred-rating%"=="tvdb" (
	if defined tvdb-rating (
		set "value=%tvdb-rating%"
	) else echo %TAB%%G_% Rating name :TVDB, is not provided in "%nfoName%"%r_%
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

:GetInfo-Rating
if not defined parameter exit /b
if /i not "%parameter%"=="%parameter:rating name=%" (
	if /i not "%parameter%"=="%parameter:imdb=%" set "imdb-rating=%value%"
	if /i not "%parameter%"=="%parameter:themoviedb=%" set "themoviedb-rating=%value%"
	if /i not "%parameter%"=="%parameter:tvdb=%" set "tvdb-rating=%value%"
)
exit /b