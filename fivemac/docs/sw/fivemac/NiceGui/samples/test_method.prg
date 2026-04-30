#include "FiveMac.ch"

FUNCTION Main()
    local oWnd, oWeb
   
    DEFINE WINDOW oWnd TITLE "Test WebView Method" NOFLIPPED 
   
    @ 20, 20 WEBVIEW oWeb SIZE 200, 200 OF oWnd
   
    if __ObjHasMsg( oWeb, "SAVETOPDF" )
    MsgInfo( "Method SAVETOPDF exists!" )
    else
    MsgAlert( "Method SAVETOPDF NOT FOUND!" )
    endif
   
    ACTIVATE WINDOW oWnd
RETURN NIL
