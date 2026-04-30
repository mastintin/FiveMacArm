#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oMenu1, oMenu2
   
   DEFINE WINDOW oWnd TITLE "SwiftUI Menu Test" SIZE 400, 300
   oWnd:cBackColor := ".gradient(.purple, .black)"

   @ 250, 100 SAY "Prueba de Menús SwiftUI" OF oWnd SIZE 200, 30
   
   // Menú Principal
   @ 150, 100 CONTROL MENU oMenu1 PROMPT "Acciones" OF oWnd SIZE 200, 40
   oMenu1:cIcon := "ellipsis.circle"
   
   CONTROL MENUITEM PROMPT "Saludar" OF oMenu1 ACTION MsgInfo( "¡Hola desde SwiftUI Menu!" ) ICON "hand.wave"
   CONTROL MENUITEM PROMPT "Información" OF oMenu1 ACTION MsgInfo( "Este es un control Menu nativo" ) ICON "info.circle"
   
   // Submenú
   @ 150, 100 CONTROL MENU oMenu2 PROMPT "Opciones" OF oMenu1
   oMenu2:cIcon := "gear"
   
   CONTROL MENUITEM PROMPT "Opción A" OF oMenu2 ACTION MsgInfo( "Elegiste A" )
   CONTROL MENUITEM PROMPT "Opción B" OF oMenu2 ACTION MsgInfo( "Elegiste B" )
   
   CONTROL MENUITEM PROMPT "Salir" OF oMenu1 ACTION oWnd:End() ICON "power"

   ACTIVATE WINDOW oWnd CENTERED

return nil
