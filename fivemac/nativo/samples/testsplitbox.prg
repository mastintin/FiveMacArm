#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oSplit, oView1, oView2, oView3

    DEFINE WINDOW oWnd TITLE "SplitBox 3 Panels Test" ;
        FROM 100, 100 TO 600, 800 FLIPPED

    oSplit := TSplitBox():New( 0, 0, oWnd:nWidth, oWnd:nHeight, oWnd, .T. )
   
    // Create first view
    oView1 := oSplit:AddView()
    oView1:SetBkColor( 255, 200, 200, 100 ) // Light Red
    @ 20, 20 SAY "Panel 1" OF oView1
    @ 60, 20 BUTTON "Test 1" ACTION MsgInfo( "Panel 1" ) OF oView1
   
    // Create second view
    oView2 := oSplit:AddView()
    oView2:SetBkColor( 200, 255, 200, 100 ) // Light Green
    @ 20, 20 SAY "Panel 2" OF oView2
    @ 60, 20 BUTTON "Test 2" ACTION MsgInfo( "Panel 2" ) OF oView2

    // Create third view
    oView3 := oSplit:AddView()
    oView3:SetBkColor( 200, 200, 255, 100 ) // Light Blue
    @ 20, 20 SAY "Panel 3" OF oView3
    @ 60, 20 BUTTON "Test 3" ACTION MsgInfo( "Panel 3" ) OF oView3

    ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
