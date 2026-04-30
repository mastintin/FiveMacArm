#include "FiveMac.ch"

function Main()

  local oWnd, oImg, oFile, cFile := "                                     "

  DEFINE WINDOW oWnd TITLE "SImage Migration Test (NSImageView)"  NOFLIPPED ;
    SIZE 800, 620 FLIPPED 

  @ 50, 20 SIMAGE oImg FILENAME "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns" ;
    OF oWnd SIZE 760, 450

  @ 520, 20 BUTTON "Open..." OF oWnd ACTION ( cFile := cGetFile( "Select Image", "Image Files|*.png;*.jpg;*.tiff;*.icns" ), ;
    If( !Empty( cFile ), oImg:Open( cFile ), nil ) ) AUTORESIZE 32
   
  @ 520, 140 BUTTON "Rotate Left" OF oWnd ACTION oImg:RotateLeft() AUTORESIZE 32
  @ 520, 260 BUTTON "Rotate Right" OF oWnd ACTION oImg:RotateRight() AUTORESIZE 32
  @ 520, 380 BUTTON "Fit" OF oWnd ACTION oImg:Fit() AUTORESIZE 32
  @ 520, 460 BUTTON "Flip V" OF oWnd ACTION oImg:VerticalFlip() AUTORESIZE 32

  @ 520, 560 BUTTON "Save As..." OF oWnd ACTION oImg:SaveAs() AUTORESIZE 32

  @ 550, 140 BUTTON "Zoom In" OF oWnd ACTION oImg:ZoomIn() AUTORESIZE 32
  @ 550, 260 BUTTON "Zoom Out" OF oWnd ACTION oImg:ZoomOut() AUTORESIZE 32
  @ 10, 290 BUTTON "Flip Vert" OF oWnd ACTION SImageVFlip( oImg ) SIZE 100, 24 AUTORESIZE 32
   
  @ 10, 400 BUTTON "Filters..." OF oWnd ACTION ShowFilters( oImg ) SIZE 100, 24 AUTORESIZE 32

  @ 550, 380 BUTTON "Crop Toggle" OF oWnd ACTION oImg:Crop() AUTORESIZE 32

  ACTIVATE WINDOW oWnd ;
    VALID MsgYesNo( "Want to end ?" )

return nil

function ShowFilters( oImg )
  local oDlg, oSldBri, oSldCon, oSldSat
  local nBri := 50, nCon := 25, nSat := 50
  local oFilter := TCIFilter():New( "CIColorControls" )
   
  DEFINE DIALOG oDlg TITLE "Image Filters (Layer Based)" SIZE 300, 280 FLIPPED

  oImg:SetWantsLayer( .T. )

  @ 20, 20 SAY "Brightness" OF oDlg
  @ 20, 100 SLIDER oSldBri VALUE 50 OF oDlg SIZE 150, 20

  @ 50, 20 SAY "Contrast" OF oDlg
  @ 50, 100 SLIDER oSldCon VALUE 25 OF oDlg SIZE 150, 20

  @ 80, 20 SAY "Saturation" OF oDlg
  @ 80, 100 SLIDER oSldSat VALUE 50 OF oDlg SIZE 150, 20

  oSldBri:bChange := { |n| nBri := n, UpdateFilters( oImg, oFilter, nBri, nCon, nSat ) }
  oSldCon:bChange := { |n| nCon := n, UpdateFilters( oImg, oFilter, nBri, nCon, nSat ) }
  oSldSat:bChange := { |n| nSat := n, UpdateFilters( oImg, oFilter, nBri, nCon, nSat ) }

  @ 120, 20 BUTTON "Black & White" OF oDlg SIZE 120, 24 ;
    ACTION ( nBri:=50, nCon:=27.5, nSat:=0, ;
    oSldBri:SetValue(50), oSldCon:SetValue(27.5), oSldSat:SetValue(0), ;
    UpdateFilters( oImg, oFilter, nBri, nCon, nSat ) )

  @ 120, 150 BUTTON "Reset Values" OF oDlg SIZE 120, 24 ;
    ACTION ( nBri:=50, nCon:=25, nSat:=50, ;
    oSldBri:SetValue(50), oSldCon:SetValue(25), oSldSat:SetValue(50), ;
    UpdateFilters( oImg, oFilter, nBri, nCon, nSat ) )

  @ 160, 20 BUTTON "Add Comic" OF oDlg SIZE 120, 24 ;
    ACTION ( oFilter:Add( "CIComicEffect" ), oFilter:Apply( oImg ) )

  @ 160, 150 BUTTON "Add Sepia" OF oDlg SIZE 120, 24 ;
    ACTION ( oFilter:Add( "CISepiaTone" ), oFilter:Apply( oImg ) )



  @ 200, 100 BUTTON "Close" OF oDlg SIZE 100, 24 ACTION oDlg:End()

  oSldBri:SetMinMaxValue( 0, 100 )
  oSldCon:SetMinMaxValue( 0, 100 )
  oSldSat:SetMinMaxValue( 0, 100 )

  ACTIVATE DIALOG oDlg CENTERED
  
  oFilter:Release()
return nil

function UpdateFilters( oImg, oFilter, nBri, nCon, nSat )
  local fBri := ( nBri - 50 ) / 100.0   
  local fCon := nCon / 25.0            
  local fSat := nSat / 50.0   
   


  oFilter:SetValue( 1, "inputBrightness", fBri )
  oFilter:SetValue( 1, "inputContrast", fCon )
  oFilter:SetValue( 1, "inputSaturation", fSat )

  oFilter:Apply( oImg )
return nil
