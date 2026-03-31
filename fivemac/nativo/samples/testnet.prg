#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oNet := TNetwork():New()
   local oGetUrl, cUrl := "https://api.ipify.org"
   local oSayIp, cIp := "Pulsar para obtener IP"
   local cResponse := ""

   DEFINE WINDOW oWnd TITLE "Test de Red FiveMac" ;
      FROM 200, 200 TO 500, 700

   @ 20, 20 SAY "Estado de Red:" OF oWnd
   @ 20, 150 SAY if( oNet:IsConnected(), "CONECTADO", "DESCONECTADO" ) OF oWnd

   @ 50, 20 SAY "IP Pública:" OF oWnd
   @ 50, 150 SAY oSayIp PROMPT cIp OF oWnd SIZE 200, 20

   @ 80, 20 SAY "URL Test:" OF oWnd
   @ 80, 150 GET oGetUrl VAR cUrl OF oWnd SIZE 300, 24

   @ 120, 20 BUTTON "Obtener IP Pública" OF oWnd ;
      ACTION ( cIp := oNet:GetPublicIP(), oSayIp:SetText( cIp ) )

   @ 120, 180 BUTTON "Test HTTP GET" OF oWnd ;
      ACTION ( cResponse := oNet:Get( cUrl ), MsgInfo( cResponse ) )

   @ 160, 20 BUTTON "Descargar Test" OF oWnd ;
      ACTION ( if( oNet:Download( "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", Path() + "/google_logo.png" ), ;
                   MsgInfo( "Descarga completada en: " + Path() + "/google_logo.png" ), ;
                   MsgAlert( "Fallo en la descarga. Revisa la consola" ) ) )

   @ 160, 180 BUTTON "Dirección MAC" OF oWnd ;
      ACTION MsgInfo( "Tu MAC es: " + oNet:GetMac() )

   @ 220, 150 BUTTON "Salir" OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
