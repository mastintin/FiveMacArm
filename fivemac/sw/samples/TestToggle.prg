#include "SwFive.ch"

function Main()

    local oWnd, oTgl1, oTgl2, oTgl3

    DEFINE WINDOW oWnd TITLE "Test: Swift Island Premium" SIZE 400, 300

    @ 20, 20 TOGGLE oTgl1 PROMPT "Modern Switch" VALUE .T. SWITCH OF oWnd
    
    @ 60, 20 TOGGLE oTgl2 PROMPT "Neon Pink Switch" VALUE .T. SWITCH OF oWnd
    
    @ 100, 20 TOGGLE oTgl3 PROMPT "Classic Checkbox" VALUE .F. OF oWnd

    @ 160, 20 BUTTON "Set Premium Styles" OF oWnd SIZE 200, 40 ;
        ACTION ( oTgl2:SetColor( "#FF1493" ), ;   // Rosa Neón
                 oTgl1:SetTextColor( "#0000FF" ), ; // Azul
                 oTgl1:SetColor( "#32CD32" ) )     // Verde Lima

    ACTIVATE WINDOW oWnd CENTER

return nil
