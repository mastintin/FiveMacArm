#include "FiveMac.ch"

function Main()

    local oWnd, oSay, oBtn, oBrush

    DEFINE WINDOW oWnd TITLE "FiveMac Tahoe Window Glass" ;
        FROM 100, 100 TO 600, 700 ;
        GLASS

    @ 50, 50 SAY oSay PROMPT "Full Window Glass Effect" ;
        SIZE 400, 50 ;
        LIQUID GLASS ;
        OF oWnd
    oSay:SetFont( "Inter", 32 )
    oSay:SetColor( CLR_WHITE )

    @ 300, 50 BUTTON oBtn PROMPT "Pro Glass Button" ;
        SIZE 200, 50 ;
        LIQUID GLASS ;
        ACTION MsgInfo( "Perfect Glass!" ) ;
        OF oWnd
    oBtn:SetColor( CLR_WHITE )

    ACTIVATE WINDOW oWnd CENTERED

return nil
