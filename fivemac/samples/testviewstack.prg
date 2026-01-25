#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oSegment, oViewStack
    local oView1, oView2, oSay1, oSay2

    DEFINE WINDOW oWnd TITLE "Testing TViewStack" SIZE 600, 400 FLIPPED

    // 2. ViewStack (The Container)
    oViewStack := TViewStack():New( oWnd, 20, 20, 560, 360 )
    
    // Test Dynamic Configuration:
    oViewStack:SetButtonSize( 50, 50 )
    oViewStack:oBar:SetColor( CLR_YELLOW )
    
    // 3. Add Views (Stack automatically adds them to its internal Segment Bar)
    oView1 := oViewStack:AddView( "First View", "person.fill" )
    oView1:SetColor( CLR_WHITE, CLR_GREEN ) // Green Background
   
    @ 100, 100 SAY oSay1 PROMPT "This is View 1 (Green)" OF oView1 SIZE 300, 40
   
    oView2 := oViewStack:AddView( "Second View", "gear" )
    oView2:SetColor( CLR_WHITE, CLR_RED )   // Red Background
   
    @ 100, 100 SAY oSay2 PROMPT "This is View 2 (Red)" OF oView2 SIZE 300, 40

    ACTIVATE WINDOW oWnd CENTERED ;
        ON RIGHT CLICK ShowPopup( nRow, nCol, oWnd )

return nil

//----------------------------------------------------------------------------//

function ShowPopup( nRow, nCol, oWnd )

    local oMenu
   
    MENU oMenu POPUP

    MENUITEM "Close App" ACTION oWnd:End()
    ENDMENU
   
    ACTIVATE POPUP oMenu OF oWnd AT nRow, nCol

return nil
