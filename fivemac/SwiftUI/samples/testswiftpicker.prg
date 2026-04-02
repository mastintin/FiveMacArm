#include "FiveMac.ch"
#include "SwiftControls.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oPick
    local aItems := { "Option 1", "Option 2", "Option 3", "Option 4" }
    local cVar   := "Option 1"

    DEFINE WINDOW oWnd TITLE "Testing Swift Picker"  NOFLIPPED ;
        FROM 200, 200 TO 500, 600

    @ 100, 100 SWIFTPICKER oPick VAR cVar ITEMS aItems OF oWnd ;
        SIZE 200, 30 ;
        ON CHANGE MsgInfo( "Selected: " + cVar )

    oPick:SetGlass( .T. )

    @ 50, 100 BUTTON "Check Selection" OF oWnd ACTION MsgInfo( cVar ) SIZE 150, 30

    ACTIVATE WINDOW oWnd

return nil

//----------------------------------------------------------------------------//
