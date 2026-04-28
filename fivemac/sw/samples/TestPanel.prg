#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oPanel, oBtn, oLabel
   
   DEFINE WINDOW oWnd TITLE "SwiftUI Panel Test" SIZE 500, 400
   
   // Creamos el Panel
   @ 50, 50 PANEL oPanel TITLE "DATOS DE USUARIO" OF oWnd SIZE 400, 250
   
   oPanel:SetBorderColor( ".blue" )
   oPanel:SetBorderWidth( 2 )
   oPanel:SetShadow( 10 )
   
   // Añadimos controles DENTRO del panel
   @ 20, 20 SAY oLabel PROMPT "Este texto está dentro del Panel" OF oPanel SIZE 350, 30
   
   @ 80, 20 BUTTON oBtn PROMPT "Botón en Panel" OF oPanel SIZE 200, 40 ;
      ACTION MsgInfo( "¡Hola desde el Panel!" )
   
   ACTIVATE WINDOW oWnd CENTERED

return nil
