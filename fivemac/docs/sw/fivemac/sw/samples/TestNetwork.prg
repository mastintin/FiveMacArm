#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()

   LOCAL oNet := TSwNetwork():New()
   
   MsgInfo( "IP Local: " + oNet:GetIP(), "Swift Network" )
   
   IF oNet:IsConnected()
      MsgInfo( "Estado: Conectado a Internet", "Swift Network" )
   ELSE
      MsgInfo( "Estado: Sin conexión", "Swift Network" )
   ENDIF

   // Prueba de descarga asíncrona con Callback
   MsgInfo( "Iniciando descarga de prueba de Google logo...", "Descarga" )

   oNet:Download( "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png", ;
                  "~/Desktop/google_logo.png", ;
                  { | lSuccess | MsgInfo( IF( lSuccess, "¡Descarga completada!", "Error en la descarga" ), "Resultado" ) } )

return nil
