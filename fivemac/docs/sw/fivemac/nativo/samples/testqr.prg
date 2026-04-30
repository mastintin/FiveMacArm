#include "FiveMac.ch"

function Main()

    local oWnd, oImg
    local cText := "https://github.com/FiveTechSoft/FiveMac"

    DEFINE WINDOW oWnd TITLE "CoreImage QR Code Generator"  NOFLIPPED ;
        SIZE 400, 500 FLIPPED

    @ 20, 20 SAY "Enter text to encode:" OF oWnd SIZE 360, 20

    @ 45, 20 GET cText OF oWnd SIZE 250, 24

    @ 45, 280 BUTTON "Generate" OF oWnd SIZE 100, 24 ;
        ACTION oImg:SetQr( cText, 10.0 ) 

    // Image placeholder

    @ 90, 50 SIMAGE oImg FILENAME "" OF oWnd SIZE 300, 300
    //@ 90, 50 IMAGE oImg FILENAME "" OF oWnd SIZE 300, 300



    // oImg:SetWantsLayer( .T. ) // Good practice for Core Animation

    ACTIVATE WINDOW oWnd ;
        VALID MsgYesNo( "Want to end ?" )

return nil
