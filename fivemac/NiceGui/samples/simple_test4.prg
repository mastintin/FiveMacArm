#include "FiveMac.ch"

FUNCTION Main()
    local oWnd, oWeb
    local cHtml

    DEFINE WINDOW oWnd TITLE "Test Static IFrame" SIZE 1000, 800

    @ 50, 50 WEBVIEW oWeb OF oWnd SIZE 900, 700

    cHtml := '<!DOCTYPE html>' + ;
        '<html>' + ;
        '<body style="background-color: #f0f0f0;">' + ;
        '  <h1 style="color: blue;">Static HTML IFrame Test</h1>' + ;
        '  <div style="border: 2px solid red; padding: 10px;">' + ;
        '    <iframe src="https://harbour.github.io/" width="100%" height="500" style="border: 1px solid black;"></iframe>' + ;
        '  </div>' + ;
        '</body>' + ;
        '</html>'

    // Load the HTML string with Base URL
    oWeb:SetHtml( cHtml, hb_DirBase() )

    ACTIVATE WINDOW oWnd
RETURN NIL
