#include "FiveMac.ch"

function Main()

    local oWnd, oSplitV
    local oMemo, oBrw
    local cMemo := "This is a MultiGet inside the left view of a splitter." + CRLF + ;
        "With the new SetPane() method, it automatically fills the pane."
    local aData := { { "Alice", 30 }, { "Bob", 25 }, { "Charlie", 35 } }
    local oPanel1, oPanel2
    local oView1, oView2

    DEFINE WINDOW oWnd TITLE "Vertical Splitter Advanced Test (New API)"  NOFLIPPED ;
        FROM 100, 100 TO 700, 900 FLIPPED

    //   @ 50, 0 SPLITTER oSplitV OF oWnd SIZE 800, 600 VERTICAL

    @ 50, 0 SPLITBOX oSplitV OF oWnd SIZE 800, 600 VERTICAL ;
        AUTORESIZE 18 VIEWS 2

    oView1 := oSplitV:aViews[ 1 ]
    oView2 := oSplitV:aViews[ 2 ]

    oPanel1 := TPanel():New( 0, 0, oView1:nWidth, oView1:nHeight, oView1 )
    oPanel1:SetBkColor( 255, 200, 200, 100 ) // Light Red
    oPanel1:nAutoResize := 18
    oPanel2 := TPanel():New( 0, 0, oView2:nWidth, oView2:nHeight, oView2 )
    oPanel2:SetBkColor( 200, 255, 200, 100 ) // Light Green
    oPanel2:nAutoResize := 18
    
    
    // Left View: a MultiGet
    @ 0, 0 MULTIGET oMemo VAR cMemo SIZE oView1:nWidth-20 , oView1:nHeight OF oPanel1
    oMemo:nAutoResize := 18

    // Right View: a Browse
    @ 0, 0 BROWSE oBrw SIZE oView2:nWidth-20, oView2:nHeight OF oPanel2 ;
        FIELDS aData[ oBrw:nArrayAt ][ 1 ], Str( aData[ oBrw:nArrayAt ][ 2 ] ) ;
        HEADERS "Name", "Age" ;
        COLSIZES 150, 50 
   
    oBrw:SetArray( aData )
    oBrw:nAutoResize := 18

    oSplitV:SetPosition( 1, oMemo:nWidth )

    ACTIVATE WINDOW oWnd

return nil
