#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oVStack, oBtn1, oBtn2
    local nW := 500, nH := 600

    DEFINE WINDOW oWnd TITLE "New SwiftUI Stack Action Test" SIZE nW, nH

    @ 50, 50 SWIFTVSTACK oVStack SIZE 400, 500 OF oWnd
    oVStack:SetBackgroundColor( 240, 240, 240, 1.0 )
    
    // Test 1: Add a button with inline block action
    oVStack:AddButton( "Inline Action Button", { |cId| MsgInfo( "Inline Action Triggered! ID: " + cId ) } )
    
    oVStack:AddSpacer()
    
    // Test 2: Add text
    oVStack:AddText( "The buttons above/below use the NEW ID system" )
    
    oVStack:AddSpacer()
    
    // Test 3: Add another button
    oVStack:AddButton( "Another Button", { |cId| MsgAlert( "Another Button Clicked! ID: " + cId ) } )

    @ 10, 200 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil
