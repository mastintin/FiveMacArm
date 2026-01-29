#include "FiveMac.ch"

function Main()

    local oWnd, oBtn1, oBtn2, oBtn3

    DEFINE WINDOW oWnd TITLE "Test Button Styles" ;
        FROM 100, 100 TO 400, 600 GLASS

    @ 20, 20 BUTTON oBtn1 PROMPT "Normal" OF oWnd SIZE 150, 40

    @ 80, 20 BUTTON oBtn2 PROMPT "Glass Native" OF oWnd SIZE 150, 40 GLASS

    @ 140, 20 BUTTON oBtn3 PROMPT "Liquid Glass" OF oWnd SIZE 150, 40 LIQUID GLASS

    @ 200, 20 BUTTON oBtn4 PROMPT "Custom Bezel Color" OF oWnd SIZE 150, 40 GLASS ;
        ACTION ( oBtn4:SetBezelColor( 255, 100, 100, 0.9 ) ) // Reddish

    ACTIVATE WINDOW oWnd CENTERED

return nil
