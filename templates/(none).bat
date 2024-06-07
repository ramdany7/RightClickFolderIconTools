::      Template Info
::===================================
::` The output image will be identical to the source image, without a frame or shadow.
::` Additionally, the image will be positioned at the center of a 1:1 image ratio.
::`   
::` Convert and edit using ImageMagick.
::` -------------------------------------------------------------------

::      Template Command
::===================================
if /i "%fileExt%"==".ico" copy "%inputfile%" "%outputfile%" >nul&exit /b
"%Converter%" "%inputfile%" -resize 512x512 -background none -gravity CENTER -extent 512x512 -define icon:auto-resize="%TemplateIconSize%" "%outputfile%"