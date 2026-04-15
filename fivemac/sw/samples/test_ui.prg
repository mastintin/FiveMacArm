#include "FiveMac.ch"

function Main()

   local oWnd, oLabel, oBtn, nCounter := 0

   oWnd := TSwWindow():New( 100, 100, 400, 300, "Isla UI Test" )

   oLabel := TSwLabel():New( 100, 100, 300, 40, "Esperando interacción...", oWnd )
   
   oBtn := TSwButton():New( 180, 100, 200, 40, "Pulsa aquí", oWnd, ;
      { || nCounter++, ;
           oLabel:SetText( "Botón pulsado " + AllTrim( Str( nCounter ) ) + " veces" ), ;
           SDS:SwMsgInfo( "El label ha sido actualizado desde el botón!" ) ;
      } )

   oWnd:Run()

return nil
