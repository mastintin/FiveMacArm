#include "FiveMac.ch"

FUNCTION Main()
    local oWnd, oWeb

    DEFINE WINDOW oWnd TITLE "Test Native WebView" SIZE 1000, 800

    @ 50, 50 WEBVIEW oWeb OF oWnd SIZE 900, 700

    oWeb:SetURL( "https://harbour.github.io/" )

    ACTIVATE WINDOW oWnd
RETURN NIL
