::      Template Info
::===================================
::` Output image will be the same as source image, without frame or anything
::` but with added shadow and image posisition will be in the center.
::` Convert and edit using ImageMagick.
::` -------------------------------------------------------------------

::      Template Config
::===================================
set "image-position=CENTER"

:: |----------------------------------|
:: |          image-position          |
:: | Northwest   North    Northeast   |
:: | West        Center   East        |
:: | SouthWest   South    SouthEast   |
:: |----------------------------------|

set "shadow-color=BLACK"
set "shadow-opacity=60"
set "shadow-blur=5"
set "shadow-X-position=+5"
set "shadow-Y-position=+6.5"


::      Template Command
::===================================
"%Converter%" "%inputfile%" -resize 490x490 ^( +clone -background %shadow-color% -shadow %shadow-opacity%x%shadow-blur%%shadow-x-position%%shadow-y-position% ^) +swap -background none -layers merge -gravity %image-position% -extent 512x512 -define icon:auto-resize="%TemplateIconSize%" "%outputfile%"