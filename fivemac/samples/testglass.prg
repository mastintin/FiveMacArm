#include "FiveMac.ch"

function Main()

    local oWnd, oSay, oSay2, oBtn, oGet, oBtnBmp, oBrush, cVar := "Liquid Glass Text"
    local cResPath := resPath()+"/bitmaps/"+( "glass_bg.png" )


    DEFINE WINDOW oWnd TITLE "Liquid Glass Aesthetic - Pro Mode" ;
        FROM 100, 100 TO 600, 700 ;
        PANELED

    // Use the generated background to make glass pop
    // DEFINE BRUSH oBrush IMAGE cResPath
    // oWnd:SetBrush( oBrush )

    @ 50, 50 SAY oSay PROMPT "Modern Liquid Glass" ;
        SIZE 400, 50 ;
        LIQUID GLASS ;
        OF oWnd
    oSay:SetFont( "Inter", 32 )
    oSay:SetColor( CLR_WHITE )

    @ 130, 50 SAY oSay2 PROMPT "Glassmorphism in FiveMac" ;
        SIZE 350, 30 ;
        LIQUID GLASS ;
        OF oWnd
    oSay2:SetColor( CLR_WHITE )

    @ 200, 50 GET oGet VAR cVar ;
        SIZE 350, 40 ;
        LIQUID GLASS ;
        OF oWnd
    oGet:SetColor( CLR_WHITE )

    @ 300, 50 BUTTON oBtn PROMPT "Pro Action Button" ;
        SIZE 200, 50 ;
        LIQUID GLASS ;
        ACTION MsgInfo( "Liquid Glass Clicked!" ) ;
        OF oWnd GLASS
    oBtn:SetColor( CLR_WHITE )

    @ 420, 50 BTNBMP oBtnBmp ;
        FILENAME cResPath ;
        SIZE 80, 80 ;
        LIQUID GLASS ;
        OF oWnd

    ACTIVATE WINDOW oWnd CENTERED

return nil
