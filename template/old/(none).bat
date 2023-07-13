::      Template Info
::===================================
::# The output image will be identical to the source image, without a frame or shadow.
::# Additionally, the image will be positioned at the center of a 1:1 image ratio.
::#   
::# Convert and edit using ImageMagick.
::# -------------------------------------------------------------------

::      Template Command
::===================================
"%Converter%" "%inputfile%" -resize 256x256 -background none -gravity CENTER -extent 256x256 "%outputfile%"