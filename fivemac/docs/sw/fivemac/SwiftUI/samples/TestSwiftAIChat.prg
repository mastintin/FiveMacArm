#include "fivemac.ch"
#include "SwiftControls.ch"

function Main()

   local oWnd
   local cApiKey := "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"

   DEFINE WINDOW oWnd TITLE "SwiftUI AI Chat: Embedded vs Window" ;
      SIZE 800, 600

   // 1. CHAT INCRUSTADO (A la izquierda)
   // Ahora pasamos la Key directamente en el comando para mas comodidad
   @ 20, 20 SWIFTAICHAT SIZE 400, 500 OF oWnd APIKEY cApiKey 

   // 2. CONTROLES ADICIONALES (A la derecha)
   @ 50, 450 SAY "Este es un chat totalmente nativo" SIZE 300, 20 OF oWnd
   @ 80, 450 SAY "incrustado como un control más." SIZE 300, 20 OF oWnd
   
   @ 150, 450 BUTTON "Abrir otro en Ventana" SIZE 200, 40 OF oWnd ;
      ACTION SD_SW_AICHAT_OPEN( cApiKey )

   @ 540, 450 BUTTON "Salir" SIZE 100, 30 OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil
