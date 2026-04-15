#include "SwFive.ch"

function Main()

   local oWnd, oBtn, oLabel
   local nClicks := 0

   // Usamos las macros de SwFive.ch que mapean a TSwWindow, TSwLabel y TSwButton
   // Estas clases están integradas en la nueva arquitectura modular de Isla.
   
   DEFINE WINDOW oWnd TITLE "Isla Modern UI - Interaction Example" FROM 100, 100 TO 500, 600

   @ 180, 150 LABEL oLabel PROMPT "Esperando interacción del usuario..." OF oWnd SIZE 300, 40
   
   // El botón llamará a la acción que actualiza el Label mediante el Dispatcher
   @ 120, 240 BUTTON oBtn PROMPT "¡Actualizar Label!" OF oWnd SIZE 140, 40 ;
      ACTION ( nClicks++, ;
               oLabel:SetText( "¡Hola! Has pulsado el botón " + AllTrim(Str(nClicks)) + " veces." ),;
               SwMsgInfo( "El label ha sido actualizado satisfactoriamente desdeSwift.", "Isla Bridge" ) )

   ACTIVATE WINDOW oWnd CENTERED

return nil
