#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oVStack

    DEFINE WINDOW oWnd TITLE "Simple SwiftUI Test" SIZE 400, 400 NOFLIPPED 

    // Using modern .ch command
    @ 50, 50 SWIFTVSTACK oVStack SIZE 300, 300 OF oWnd
    
    // Modern internal calls using Stack-based classes
    oVStack:AddText( "Hello World from SwiftUI!" )
    
    oVStack:AddButton( "Click Me", {|| MsgInfo( "Hello from Fivemac!" ) } )

    ACTIVATE WINDOW oWnd
return nil
