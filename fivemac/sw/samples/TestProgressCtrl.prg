#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oProg

   DEFINE WINDOW oWnd TITLE "Progreso HSW: Swift Island" SIZE 400, 200

   @ 50, 50 PROGRESS oProg SIZE 300, 20 OF oWnd
   
   oProg:SetRange( 0, 100 )
   oProg:SetValue( 0 )

   // Lanzamos el proceso en cuanto la ventana esté lista
   oWnd:bOnInit := { || DoProcess( oProg ) }

   ACTIVATE WINDOW oWnd CENTERED

return nil

function DoProcess( oProg )
   local i
   
   for i := 1 to 100
      oProg:SetValue( i )
      
      // En HSW, SysRefresh bombea eventos del Hilo 0 (Swift) al Hilo 1 (Harbour)
      SysRefresh() 
      
      hb_idleSleep( 0.05 )
   next
   
   MsgInfo( "Proceso completado con éxito en la Isla HSW!" )
   
return nil
