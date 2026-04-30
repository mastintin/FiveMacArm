#include "FiveMac.ch"

function Main()

    local oWnd, oBtn, oBtn2, oGet, cText := "Test Inspector", oRad, nRad := 1
    local oPanel

    DEFINE WINDOW oWnd TITLE "Testing Real-Time Inspector"  NOFLIPPED ;
        FROM 200, 200 TO 600, 800

    @ 350, 40 BUTTON oBtn PROMPT "Launch Inspector" OF oWnd ;
        ACTION Inspector() SIZE 150, 40

    @ 300, 40 GET oGet VAR cText OF oWnd SIZE 200, 24

    @ 250, 40 RADIO oRad VAR nRad PROMPTS { "One", "Two" } OF oWnd SIZE 80, 50

    @ 50, 300 PANEL oPanel OF oWnd SIZE 250, 300
    oPanel:SetColor( CLR_WHITE, CLR_CYAN )

    @ 250, 20 BUTTON oBtn2 PROMPT "Inside Panel" OF oPanel ACTION MsgInfo("Hi") SIZE 120, 30

    ACTIVATE WINDOW oWnd

return nil
