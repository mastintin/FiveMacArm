#include "FiveMac.ch"

function Main()
    local oWnd, oBtnFile, oBtnDir, nColor := 0
    local cFile := "", cDir := ""

    DEFINE WINDOW oWnd TITLE "Swift System Functions Test" ;
        SIZE 400, 200 GLASS

    @ 30, 20 BUTTON oBtnFile PROMPT "Import Source (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION (  cFile := CSWGETFILE( "Select a Source File", "prg,txt,m4a", "Import" ), ;
        if( !Empty( cFile ), MsgInfo( "Selected File: " + cFile ), ) )

    @ 30, 210 BUTTON "Pick Image (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION (  cFile := CSWGETIMAGEFILE( "Choose an Image", "Select" ), ;
        if( !Empty( cFile ), MsgInfo( "Selected Image: " + cFile ), ) )

    @ 70, 20 BUTTON oBtnDir PROMPT "Select Folder (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION (  cDir := CSWGETDIR( "Choose a destination folder", "Select Fold" ), ;
        if( !Empty( cDir ), MsgInfo( "Selected Directory: " + cDir ), ) )

    @ 110, 20 BUTTON "MsgInfo (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION SW_MSGINFO( "This is a native Swift alert!", "Swift Power" )

    @ 110, 210 BUTTON "MsgYesNo (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION ( if( SW_MSGYESNO( "Do you like Swift?", "Question" ), ;
        SW_MSGINFO( "Awesome!", "Result" ), ;
        SW_MSGINFO( "Oh no...", "Result" ) ) )

    @ 150, 20 BUTTON "Get Color (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION ( nColor := CSWGETCOLOR(), ;
        if( nColor != 0, MsgInfo( "Selected Color: " + AllTrim(Str(nColor)) ), ) )

    @ 150, 210 BUTTON "Show App Paths (Swift)" SIZE 180, 30 OF oWnd ;
        ACTION SW_MSGINFO( "Path: " + CSWPATH() + hb_EOL() + ;
        "App: " + CSWAPPPATH() + hb_EOL() + ;
        "Res: " + CSWRESPATH(), "System Paths" )

    @ 190, 20 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd CENTERED

return nil
