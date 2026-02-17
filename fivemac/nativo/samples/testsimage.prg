#include "FiveMac.ch"

function Main()

  local oWnd, oImg, oFile, cFile := "                                     "

  DEFINE WINDOW oWnd TITLE "SImage Migration Test (NSImageView)" ;
    SIZE 800, 600

  @ 50, 20 SIMAGE oImg FILENAME "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns" ;
    OF oWnd SIZE 760, 450

  @ 520, 20 BUTTON "Open..." OF oWnd ACTION ( cFile := cGetFile( "Select Image", "Image Files|*.png;*.jpg;*.tiff;*.icns" ), ;
    If( !Empty( cFile ), oImg:Open( cFile ), nil ) )
   
  @ 520, 140 BUTTON "Rotate Left" OF oWnd ACTION oImg:RotateLeft()
  @ 520, 260 BUTTON "Rotate Right" OF oWnd ACTION oImg:RotateRight()
  @ 520, 380 BUTTON "Fit" OF oWnd ACTION oImg:Fit()
  @ 520, 460 BUTTON "Flip V" OF oWnd ACTION oImg:VerticalFlip()

  @ 520, 560 BUTTON "Save As..." OF oWnd ACTION oImg:SaveAs()

  ACTIVATE WINDOW oWnd

return nil
