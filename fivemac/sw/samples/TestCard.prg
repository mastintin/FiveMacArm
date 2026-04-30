#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oCard, oPanel
   
   DEFINE WINDOW oWnd TITLE "Dashboard Premium - Versión Final" SIZE 500, 600
   
   @ 50, 50 CARD oCard TITLE "Dashboard Personalizado" SYMBOL "chart.bar.fill" ;
      OF oWnd SIZE 400, 450
      
      // CONFIGURACIÓN PREMIUM 16:25
      oCard:cAccentColor := ".gradient(.purple, .blue)"
      oCard:cIconColor   := ".orange"
      oCard:cTitleColor  := ".gradient(.blue, .purple)"
      oCard:cBackColor   := ".white"
      
      @ 0, 0 PANEL oPanel OF oCard SIZE 360, 350
         @ 150, 100 SAY "DISEÑO PREMIUM COMPLETADO" OF oPanel SIZE 300, 30
            
   ACTIVATE WINDOW oWnd CENTER
   
return nil
