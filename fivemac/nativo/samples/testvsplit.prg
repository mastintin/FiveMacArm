#include "FiveMac.ch"

function Main()

    local oWnd, oSplit
    local oMemo, oBrw
    local cMemo := "This is a MultiGet inside the left view of a splitter." + CRLF + ;
        "With the new SetPane() method, it automatically fills the pane."
    local aData := { { "Alice", 30 }, { "Bob", 25 }, { "Charlie", 35 } }

    DEFINE WINDOW oWnd TITLE "Vertical Splitter Advanced Test (New API)" ;
        FROM 100, 100 TO 700, 900

    @ 50, 0 SPLITTER oSplit OF oWnd SIZE 800, 600 VERTICAL

    // Left View: a MultiGet
    @ 0, 0 MULTIGET oMemo VAR cMemo OF oWnd
    oSplit:SetPane( 1, oMemo )

    // Right View: a Browse
    @ 0, 0 BROWSE oBrw OF oWnd ;
        FIELDS aData[ oBrw:nArrayAt ][ 1 ], Str( aData[ oBrw:nArrayAt ][ 2 ] ) ;
        HEADERS "Name", "Age" ;
        COLSIZES 150, 50 
   
    oBrw:SetArray( aData )
    oSplit:SetPane( 2, oBrw )

    oSplit:SetPosition( 1, 300 )

    ACTIVATE WINDOW oWnd

return nil
