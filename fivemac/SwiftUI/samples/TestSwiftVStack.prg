#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oVStack
    local lInvert := .T.

    DEFINE WINDOW oWnd TITLE "SwiftUI VStack Demo" SIZE 600, 600

    @ 50, 50 SWIFTVSTACK oVStack SIZE 300, 400 OF oWnd
    oVStack:SetScroll( .T. )
    
    // Handle Item Click
    oVStack:bAction := {|nIndex| MsgAlert( "Clicked Item: " + Str(nIndex) ) }

    // Initial State: Inverted Color (Smart Contrast)
    oVStack:SetInvertedColor( lInvert )

    // Just to show we can control alpha on inverted too
    oVStack:SetBackgroundColor( 0, 0, 0, 0.75 ) 
    
    // Set Text Color to White
    oVStack:SetForegroundColor( 255, 255, 255, 1.0 )

    @ 500, 50 BUTTON "Add Item" SIZE 120, 40 OF oWnd ;
        ACTION oVStack:AddItem( "Item " + Time() )
        
    @ 450, 50 BUTTON "Add Image" SIZE 120, 40 OF oWnd ;
        ACTION oVStack:AddImage( "star.fill" )
        
    @ 450, 200 BUTTON "Add Row" SIZE 120, 40 OF oWnd ;
        ACTION oVStack:AddRow( "gear", "Settings" )

    @ 500, 200 BUTTON "Toggle Invert" SIZE 120, 40 OF oWnd ;
        ACTION ( lInvert := !lInvert, oVStack:SetInvertedColor( lInvert ) )

    @ 550, 50 BUTTON "Leading" SIZE 100, 40 OF oWnd ;
        ACTION oVStack:SetAlignment( 1 )

    @ 550, 160 BUTTON "Center" SIZE 100, 40 OF oWnd ;
        ACTION oVStack:SetAlignment( 0 )
        
    @ 550, 270 BUTTON "Spacing +" SIZE 100, 40 OF oWnd ;
        ACTION oVStack:SetSpacing( 50 )

    @ 500, 350 BUTTON "Exit" SIZE 120, 40 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil
