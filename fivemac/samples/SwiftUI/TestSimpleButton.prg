#include "FiveMac.ch"

function Main()
    local oWnd, oZStack, oGrid, aColumns

    DEFINE WINDOW oWnd TITLE "Simple ZStack Test" SIZE 400, 400

    // Create ZStack
    oZStack := TSwiftZStack():New( 0, 0, 400, 400, oWnd )
   
    // Define Grid Columns
    aColumns := { ;
        { "type" => "flexible", "min" => 80 }, ;
        { "type" => "flexible", "min" => 80 }, ;
        { "type" => "flexible", "min" => 80 } ;
        }

    // Add Grid (Background layer)
    oGrid := oZStack:AddGrid( aColumns )
    
    // Add Items to Grid
    oGrid:AddText( "Item 1" )
    oGrid:AddText( "Item 2" )
    oGrid:AddText( "Item 3" )
    oGrid:AddButton( "Button 4", {|| MsgInfo("Grid Btn 4") } )
    oGrid:AddText( "Item 5" )
    oGrid:AddButton( "Button 6", {|| MsgInfo("Grid Btn 6") } )

    // Add Button to ZStack (Floating layer)
    oZStack:AddButton( "Click Me (ZStack)!", {|| MsgInfo( "ZStack Button Clicked!" ) } )

    ACTIVATE WINDOW oWnd
return nil
