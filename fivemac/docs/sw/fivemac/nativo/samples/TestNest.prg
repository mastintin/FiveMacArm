#include "FiveMac.ch"

function Main()

    local oWnd, oWeb
   
    DEFINE WINDOW oWnd TITLE "Harbour <-> JS Bridge" SIZE 800, 600 NOFLIPPED 
   
    @ 0, 0 WEBVIEW oWeb SIZE 800, 600 OF oWnd
   
    // Bridge Handler
    oWeb:bOnMessage = { | cBody, cName, oWebView | MsgInfo( "JS: " + cBody, "From: " + cName ) }
   
    // HTML with Bridge Call using 'fivemac' handler name
    // window.webkit.messageHandlers.fivemac.postMessage( message )
    oWeb:SetHtml( '<html><head><style>body{font-family:system-ui;padding:50px;text-align:center;background:#f0f0f0;}' + ;
        'button{font-size:18px;padding:12px 24px;border-radius:8px;border:none;background:#007aff;color:white;cursor:pointer;}' + ;
        'button:hover{background:#0051a8;}</style></head>' + ;
        '<body><h1>Harbour Bridge Test</h1>' + ;
        '<p>Click the button below to send a message to Harbour.</p>' + ;
        '<button onclick="sendMessage()">Send Message to Harbour</button>' + ;
        '<script>' + ;
        'function sendMessage() {' + ;
        '  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {' + ;
        '      window.webkit.messageHandlers.fivemac.postMessage("Hello from JavaScript! Time: " + new Date().toLocaleTimeString());' + ;
        '  } else {' + ;
        '      alert("Bridge not found!");' + ;
        '  }' + ;
        '}' + ;
        '</script>' + ;
        '</body></html>' )
   
    ACTIVATE WINDOW oWnd

return nil
