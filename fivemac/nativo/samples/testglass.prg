#include "FiveMac.ch"

function Main()

    local oWnd, oPanel, oGet, oGroup, oBtn
    local cText := "Testing glass effects"

    DEFINE WINDOW oWnd TITLE "Glass Test" ;
        FROM 50, 50 TO 500, 800 FLIPPED GLASS

    @ 20, 20 PANEL oPanel SIZE 300, 300 OF oWnd GLASS

    @ 20, 340 GROUP oGroup SIZE 200, 100 OF oWnd GLASS

    @ 140, 340 MULTIGET oGet VAR cText SIZE 400, 200 OF oWnd GLASS

    @ 350, 340 BUTTON oBtn PROMPT "Click me" SIZE 100, 40 OF oWnd ACTION MsgInfo( "Ok" ) GLASS

    ACTIVATE WINDOW oWnd CENTERED

return nil
