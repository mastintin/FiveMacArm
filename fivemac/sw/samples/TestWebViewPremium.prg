#include "SwFive.ch"

static oWebView

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "mainApp" )
return nil

//----------------------------------------------------------------------------//

function mainApp()
   local oWnd, oBtn, oBtnPdf
   local cHtml := GetTestHtml()

   // Ventana de 800x600
   DEFINE WINDOW oWnd TITLE "SwiftFive - Premium WebView & JS Bridge" SIZE 800, 600

   // WebView: Alto de la ventana (600) - 30px = 570. Pero le daremos un poco más de margen
   // para que los botones quepan abajo. Ajustamos a 530 para dejar 70px abajo.
   @ 0, 0 WEBVIEW oWebView OF oWnd SIZE 800, 400 ;
      AUTORESIZE SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT
   
   oWebView:bAction := { | cMsg | MsgInfo( "Mensaje desde JS: " + cMsg, "Harbour Bridge" ) }

   // Carga inicial
   oWebView:LoadHtml( cHtml )

   // Botones situados en la franja inferior (entre 540 y 600)
   @ 550, 20 BUTTON "Ir a Google" OF oWnd SIZE 120, 30 ;
      ACTION oWebView:Load( "https://www.google.com" ) ;
      AUTORESIZE AnclaBottom

   @ 550, 150 BUTTON "Inyectar JS" OF oWnd SIZE 120, 30 ;
      ACTION oWebView:Eval( "document.body.style.backgroundColor = 'lightblue'; alert('JS Inyectado desde Harbour');" ) ;
      AUTORESIZE AnclaBottom

   @ 550, 280 BUTTON oBtnPdf PROMPT "Exportar a PDF" OF oWnd SIZE 120, 30 ;
      ACTION ( oBtnPdf:Disable(), oWebView:SaveToPDF( hb_GetEnv( "HOME" ) + "/Desktop/FiveMac_Export.pdf" ), ;
      MsgInfo( "Exportación iniciada al Escritorio..." ) ) ;
      AUTORESIZE AnclaBottom

   @ 550, 410 BUTTON "Reload" OF oWnd SIZE 100, 30 ;
      ACTION oWebView:Reload() ;
      AUTORESIZE AnclaBottom

   ACTIVATE WINDOW oWnd CENTER

return nil

//----------------------------------------------------------------------------//

function GetTestHtml()
   local cHtml := ""

   cHtml += "<html>"
   cHtml += "<head><style>"
   cHtml += "body { font-family: -apple-system; padding: 40px; text-align: center; background: #f5f5f7; }"
   cHtml += ".card { background: white; padding: 20px; border-radius: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }"
   cHtml += "button { background: #007AFF; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }"
   cHtml += "</style></head>"
   cHtml += "<body>"
   cHtml += "<div class='card'>"
   cHtml += "<h1>Island Sw WebView</h1>"
   cHtml += "<p>Este es un HTML cargado localmente con soporte de <b>JS Bridge</b>.</p>"
   cHtml += "<button onclick='sendMessage()'>Enviar Mensaje a Harbour</button>"
   cHtml += "</div>"
   cHtml += "<script>"
   cHtml += "function sendMessage() {"
   cHtml += "  window.webkit.messageHandlers.harbour.postMessage('¡Hola Manuel! Soy el JavaScript de la página.');"
   cHtml += "}"
   cHtml += "</script>"
   cHtml += "</body>"
   cHtml += "</html>"

return cHtml

//----------------------------------------------------------------------------//
