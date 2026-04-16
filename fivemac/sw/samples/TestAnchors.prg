#include "SwFive.ch"

function Main()

    local oWnd, oBtn, oLabel, oSlider
    
    DEFINE WINDOW oWnd TITLE "Swift Island: Anchors Test" SIZE 600, 400

    @ 20, 20 SAY "Anclaje Superior-Izquierda (Default)" OF oWnd SIZE 300, 25 

    @ 20, 400 BUTTON "Fijo Derecha" OF oWnd SIZE 150, 40 ;
        AUTORESIZE SW_ANCHOR_RIGHT

    @ 300, 20 SLIDER oSlider VALUE 50 OF oWnd SIZE 560, 40 ;
        AUTORESIZE SW_RESIZE_WIDTH

    @ 340, 400 BUTTON oBtn PROMPT "Fijo Bottom-Right" OF oWnd SIZE 150, 40 ;
        AUTORESIZE SW_ANCHOR_RIGHT + SW_ANCHOR_BOTTOM ;
        ACTION MsgInfo( "Mi posición actual: " + AllTrim(Str(oBtn:nTop)) + "," + AllTrim(Str(oBtn:nLeft)) )

    ACTIVATE WINDOW oWnd CENTER

return nil
