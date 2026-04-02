#include "FiveMac.ch"

function Main()

    local oWnd, oWeb, oBtn
    local cPdf := GetEnv( "TMPDIR" ) + "/web_native.pdf"
    local cHtml := "<html><body><h1>Hello PDF from WebView!</h1><p>This is a native PDF export.</p><div style='width:100px;height:100px;background:red;'></div></body></html>"

    DEFINE WINDOW oWnd TITLE "WebView PDF Test" SIZE 800, 600 NOFLIPPED 

    @ 50, 20 WEBVIEW oWeb SIZE 760, 450 OF oWnd
    oWeb:SetHtml( cHtml )
   
    @ 520, 350 BUTTON oBtn PROMPT "Save to PDF" ;
        ACTION ( oWeb:SaveToPDF( cPdf ), MsgInfo( "PDF saving triggered to: " + cPdf ) ) ;
        OF oWnd

    ACTIVATE WINDOW oWnd

return nil
