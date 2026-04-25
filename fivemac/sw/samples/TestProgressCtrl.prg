#include "SwFive.ch"

function Main()

   local oWnd, oProg, oBtn

   DEFINE WINDOW oWnd TITLE "Prueba de Control de Progreso Directo" ;
      SIZE 400, 200

   oProg := SwProgress():New( 150, 50, 300, 40, oWnd )
   
   oProg:SetRange( 0, 100 )
   oProg:SetValue( 0 )

   oWnd:bOnInit := { || DoProcess( oProg ), oWnd:End() }

   ACTIVATE WINDOW oWnd CENTERED

return nil

function DoProcess( oProg )

   local i
   
   for i := 1 to 100
      oProg:SetValue( i )
      
      // MUY IMPORTANTE: Forzar refresco del sistema para que Cocoa dibuje
      SysRefresh() 
      
      hb_idleSleep( 0.1 )
   next
   
   MsgInfo( "Proceso completado" )

return nil
