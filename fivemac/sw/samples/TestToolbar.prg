#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

//----------------------------------------------------------------------------//

function AppMain()

   local oWin, oBtn

   DEFINE WINDOW oWin TITLE "FiveMac Swift - AddButton Toolbar Test" ;
          SIZE 600, 400

   // Añadimos los botones directamente a la ventana uno a uno
   oWin:AddButtonBar( "btn_nuevo", "Nuevo",   "plus.circle.fill",      { || MsgInfo( "Creando nuevo..." ) } )
   oWin:AddButtonBar( "btn_save",  "Guardar", "square.and.arrow.down", { || MsgInfo( "Guardado!" ) } )
   oWin:AddButtonBar( "btn_print", "Imprimir","printer.fill",          { || MsgInfo( "Imprimiendo..." ) } )
   
   // También podemos añadir botones dinámicamente después de definir la ventana
   oWin:AddButtonBar( "btn_chat",  "IA Chat",  "sparkles",             { || MsgInfo( "Hola, soy tu IA" ) } )

   @ 100, 200 BUTTON oBtn PROMPT "Cerrar Ventana" OF oWin ;
              ACTION oWin:End()

   ACTIVATE WINDOW oWin CENTER

return nil

//----------------------------------------------------------------------------//
