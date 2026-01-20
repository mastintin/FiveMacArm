#include "FiveMac.ch"

function Main()
    local oWnd, oVStack

    DEFINE WINDOW oWnd TITLE "Simple SwiftUI Test" SIZE 400, 400

    // Create VStack
    oVStack := TSwiftVStack():New( 50, 50, 300, 300, oWnd )
    
    // Add Label
    oVStack:AddText( "Hello World from SwiftUI!" )
    
    // Add Button
    oVStack:AddButton( "Click Me", {|| MsgInfo( "Hello from Fivemac!" ) } )

    ACTIVATE WINDOW oWnd
return nil
