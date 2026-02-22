#include "FiveMac.ch"

function Main()

    local oWnd, oImg, oBtn1, oBtn2, oBrw
    local cFile := ""
    local aResults := {}
   
    DEFINE WINDOW oWnd TITLE "Image Classification Test" ;
        FROM 50, 50 TO 600, 800
      
    @ 20, 20 IMAGE oImg SIZE 300, 400 OF oWnd
   
    @ 20, 340 BROWSE oBrw ;
        FIELDS If( Len( aResults ) >= oBrw:nArrayAt .and. oBrw:nArrayAt > 0, aResults[ oBrw:nArrayAt ][ 1 ], "" ), ;
        If( Len( aResults ) >= oBrw:nArrayAt .and. oBrw:nArrayAt > 0, Str( aResults[ oBrw:nArrayAt ][ 2 ] * 100, 5, 2 ) + "%", "" ) ;
        HEADERS "Label", "Conf." ;
        COLSIZES 300, 100 ;
        SIZE 440, 400 OF oWnd 
    
    oBrw:SetArray( aResults )
   
    @ 440, 20 BUTTON oBtn1 PROMPT "Load Image..." OF oWnd ;
        ACTION ( cFile := cGetFile( "Select Image", "Image Files (*.png;*.jpg)|*.png;*.jpg;*.jpeg;*.tiff;*.bmp" ), ;
        If( ! Empty( cFile ), ( oImg:SetFile( cFile ), aResults := {}, oBrw:SetArray( aResults ), oBrw:Refresh() ), nil ) )

    @ 440, 160 BUTTON oBtn2 PROMPT "Classify Image" OF oWnd ;
        ACTION DoClassify( oImg, oBrw, @aResults )
   
    ACTIVATE WINDOW oWnd CENTERED
   
return nil

function DoClassify( oImg, oBrw, aResults )

    ? "Classifying..."
    aResults := NSIMGCLASSIFY( oImg:GetImage() )
    ? "Results received, count: " + AllTrim( Str( Len( aResults ) ) )
    
    oBrw:SetArray( aResults )
    ? "Array set in browse"
    
    oBrw:Refresh()
    ? "Browse refreshed"

return nil
