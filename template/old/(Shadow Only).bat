::      Template Info
::===================================
::# Output image will be the same as source image, without frame or anything
::# but with added shadow and image posisition will be in the center.
::# Convert and edit using ImageMagick.
::# -------------------------------------------------------------------

::      Template Config
::===================================
set "testmode=no"

set "image-size=245x245"
set "image-position=CENTER"
:: |----------------------------------|
:: |          image-position          |
:: | Northwest   North    Northeast   |
:: | West        Center   East        |
:: | SouthWest   South    SouthEast   |
:: |----------------------------------|

set "shadow-color=BLACK"
set "shadow-opacity=70"
set "shadow-blur=1.3"
set "shadow-x-position=+2"
set "shadow-y-position=+3.5"


::      Template Command
::===================================
"%Converter%" "%inputfile%" -resize %image-size% ^( +clone -background %shadow-color% -shadow %shadow-opacity%x%shadow-blur%%shadow-x-position%%shadow-y-position% ^) +swap -background none -layers merge -gravity %image-position% -extent 256x256 "%outputfile%"



