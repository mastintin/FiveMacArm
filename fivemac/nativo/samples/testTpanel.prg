#include "FiveMac.ch"

function Main()

    local oWnd, oPanel, oBtn

    DEFINE WINDOW oWnd TITLE "Testing TPanel" ;
        SIZE 600, 400 FLIPPED GLASS

    // Create a Panel at (50, 50) with size 300x200
    // Explicitly Flipped = .T.
    // oPanel = TPanel():New( 50, 50, 300, 200, oWnd, .f. )
    
    // Set background color of panel to Dark Blue (RGB: 0, 0, 139) with White text
    // oPanel:SetColor( CLR_WHITE, ARGB( 0, 0, 139 , 100) ) 

    // Test Anchors: Resize Width (2) + Height (16) = 18? Or use constants. 
    // Standard Cocoa masks: MinX=1, Width=2, MaxX=4, MinY=8, Height=16, MaxY=32
    // To resize with window: Width + Height
    // oPanel:nAutoResize = 18 

    // @ 50, 50 PANEL oPanel OF oWnd SIZE 300, 200 AUTORESIZE 18
    // oPanel:SetColor( CLR_WHITE, ARGB( 0, 0, 139 , 100) ) 

    @ 250 SIDEBAR oPanel OF oWnd


    @ 20, 20 BUTTON oBtn PROMPT "Click Me inside Panel" OF oPanel ;
        SIZE 200, 40 ACTION MsgInfo( "Hello from Button inside TPanel!" )

    ACTIVATE WINDOW oWnd

return nil

//----------------------------------------------------------------------------//
