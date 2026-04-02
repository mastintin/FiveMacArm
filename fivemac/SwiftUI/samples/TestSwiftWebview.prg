#include "FiveMac.ch"
#include "SwiftControls.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oWeb, oProg
   local cHtml := "<html><head><style>" + ;
      "body { font-family: -apple-system; padding: 40px; text-align: center; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); height: 100vh; margin: 0; }" + ;
      "h1 { color: #2d3436; font-size: 48px; }" + ;
      "button { padding: 15px 30px; font-size: 18px; cursor: pointer; background: #0984e3; color: white; border: none; border-radius: 8px; transition: transform 0.2s; }" + ;
      "button:hover { transform: scale(1.05); }" + ;
      "</style></head><body>" + ;
      "<h1>SwiftUI <br>WebView</h1>" + ;
      "<p style='font-size: 20px; color: #636e72;'>Este es un componente nativo <b>WKWebView</b> integrado mediante <b>SwiftUI</b>.</p>" + ;
      "<br><br>" + ;
      [<button onclick='window.webkit.messageHandlers.fivemac.postMessage("Hola desde el Navegador!")'>Enviar Mensaje a Harbour</button>] + ;
      [</body></html>]

   DEFINE WINDOW oWnd TITLE "FiveMac: SwiftUI WebView Standalone" SIZE 900, 700 FLIPPED

   // Usando el nuevo comando SWIFTWEBVIEW o la clase TSwiftWebview directamente
   @ 70, 20 SWIFTWEBVIEW oWeb SIZE 860, 610 OF oWnd
   
   // Definir el manejador de mensajes de JS -> Harbour
   oWeb:bOnMessage := { | cBody, cName | MsgInfo( "Harbour ha recibido: " + CRLF + CRLF + cBody, "Bridge JS -> Swift -> Harbour" ) }

   // Cargar el HTML inicial
   oWeb:LoadHtml( cHtml )

   // Barra de herramientas superior
   @ 15, 20  BUTTON "Google"  SIZE 100, 30 ACTION oWeb:Load( "https://www.google.com" ) OF oWnd
   @ 15, 130 BUTTON "Apple"   SIZE 100, 30 ACTION oWeb:Load( "https://www.apple.com" )  OF oWnd
   @ 15, 240 BUTTON "Eval JS" SIZE 100, 30 ACTION oWeb:Eval( "document.body.style.background = 'orange'" ) OF oWnd
   
   @ 15, 360 BUTTON "Zoom +"  SIZE 100, 30 ACTION ( oWeb:nMagnification += 0.2, oWeb:SetZoom( oWeb:nMagnification ) ) OF oWnd
   @ 15, 470 BUTTON "Zoom -"  SIZE 100, 30 ACTION ( oWeb:nMagnification -= 0.2, oWeb:SetZoom( oWeb:nMagnification ) ) OF oWnd
   
   @ 15, 580 BUTTON "PDF"     SIZE 100, 30 ACTION SaveWebToPDF( oWeb ) OF oWnd
   @ 15, 690 BUTTON "Refresh" SIZE 100, 30 ACTION oWeb:Reload() OF oWnd

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

function SaveWebToPDF( oWeb )

   local cPdf := "/tmp/swift_webview_capture.pdf"
   
   oWeb:SaveToPDF( cPdf )
   
   if File( cPdf )
      MsgInfo( "PDF generado correctamente en:" + CRLF + cPdf )
      WaitRun( "open " + cPdf )
   else
      MsgAlert( "Error al generar el PDF" )
   endif
   
return nil

//----------------------------------------------------------------------------//
