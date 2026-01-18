#include "FiveMac.ch"

#define SWIFT_TYPE_TEXT          0
#define SWIFT_TYPE_BUTTON        9

function Main()

    local oWnd, oZStack, oGrid
    local aColumns

    DEFINE WINDOW oWnd TITLE "SwiftUI Batch Registration (OO Style)" SIZE 500, 600

    oZStack := TSwiftZStack():New( 0, 0, 500, 600, oWnd )
    oZStack:SetBackgroundColor( 100, 150, 255, 0.2 )

    aColumns := { { "flexible", 150 }, { "flexible", 150 } }
    oGrid := oZStack:AddGrid( aColumns )
    oGrid:SetColor( 255, 255, 255, 0.5 )

    // Fill Grid using the NEW "Enqueue and Flush" style (OO Style)
    // This style is much easier to wrap in commands!
    
    oGrid:AddItem( SWIFT_TYPE_TEXT,   "OO Item 1" )
    oGrid:AddItem( SWIFT_TYPE_BUTTON, "OO Button 2", {|| MsgInfo( "Fired from OO Batch 2" ) } )
    oGrid:AddItem( SWIFT_TYPE_TEXT,   "OO Item 3" )
    oGrid:AddItem( SWIFT_TYPE_BUTTON, "OO Button 4", {|| MsgInfo( "Fired from OO Batch 4" ) } )
    
    // Add many more to see performance
    oGrid:AddItem( SWIFT_TYPE_TEXT,   "OO Item 5" )
    oGrid:AddItem( SWIFT_TYPE_BUTTON, "OO Button 6", {|| MsgInfo( "Fired from OO Batch 6" ) } )
    
    oGrid:AddBatch() // Flush all items at once

    // Floating button (Standard individual addition)
    oZStack:AddButton( "Floating Button", {|| MsgInfo( "Floating Clic!" ) } )

    ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
