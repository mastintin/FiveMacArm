#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oZStack
    local oVStack, oGrid
    local nW := 600
    local nH := 600
    local i

    DEFINE WINDOW oWnd TITLE "Testing SwiftUI Grid" SIZE nW, nH FLIPPED

    @ 20, 20 SWIFTZSTACK oZStack SIZE 560, 560 OF oWnd
    oZStack:SetBackgroundColor( 240, 240, 240, 1.0 )

    // Root VStack
    oVStack := oZStack:AddVStack()
    
    oVStack:AddText( "LazyVGrid Example" )
    
    // Create Grid with 3 Flexible Columns
    // Array structure: { { type, min, max }, ... }
    oGrid := oVStack:AddGrid( { ;
        { "flexible", 50 }, ;
        { "flexible", 50 }, ;
        { "flexible", 50 } ;
        } )
    
    oGrid:SetColor( 255, 255, 255, 1.0 ) // White background for grid
    
    oGrid:bAction := { |n| MsgAlert( "Clicked Item: " + Str(n) ) }
    
    // Add Items to Grid
    for i := 1 to 30
    oGrid:AddText( "Item " + AllTrim( Str( i ) ) )
    next

    @ 550, 480 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil
