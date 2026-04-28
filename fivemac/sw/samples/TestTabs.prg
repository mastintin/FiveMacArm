#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oTabs, oPnl1, oPnl2, oPnl3

   DEFINE WINDOW oWnd TITLE "SwiftUI TabView Demo" SIZE 600, 450

   @ 10, 10 TABVIEW oTabs OF oWnd SIZE 580, 430 STYLE 1

      // Primera Pestaña
      @ 0, 0 PANEL oPnl1 TITLE "Home" SYMBOL "house.fill" OF oTabs 
         @ 40, 20 SAY "Bienvenido a la pestaña de inicio" OF oPnl1
         @ 80, 20 BUTTON "Saludar" ACTION msgInfo( "¡Hola!" ) OF oPnl1
      
      // Segunda Pestaña
      @ 0, 0 PANEL oPnl2 TITLE "Ajustes" SYMBOL "gear" OF oTabs
         @ 40, 20 SAY "Configuración del sistema" OF oPnl2
         @ 80, 20 TOGGLE VALUE .T. PROMPT "Modo Oscuro" OF oPnl2

      // Tercera Pestaña
      @ 0, 0 PANEL oPnl3 TITLE "Perfil" SYMBOL "person.circle" OF oTabs
         @ 40, 20 SAY "Información del usuario" OF oPnl3
         @ 80, 20 IMAGE SYMBOL "person.fill" SIZE 100, 100 OF oPnl3

   oPnl2:SetBadge( 3 )
   oPnl3:SetBadge( "!" )

   ACTIVATE WINDOW oWnd CENTERED

return nil
