#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oSidebar, oItem1, oItem2, oItem3, oPanel
   
   DEFINE WINDOW oWnd TITLE "Premium SwiftUI Sidebar" SIZE 800, 550
   
   @ 0, 0 SIDEBAR oSidebar OF oWnd SIZE 220, 550
   
   @ 20, 0 SIDEBAR ITEM oItem1 PROMPT "Principal" SYMBOL "house.fill" OF oSidebar 
   @ 55, 0 SIDEBAR ITEM oItem2 PROMPT "Mensajes" SYMBOL "bubble.left.and.bubble.right.fill" OF oSidebar
   @ 90, 0 SIDEBAR ITEM oItem3 PROMPT "Ajustes" SYMBOL "gearshape.fill" OF oSidebar 

    oItem2:bAction := {|| msgInfo( "Mensajes" ) }
    oItem1:bAction := {|| msgInfo( "Principal" ) }
    oItem3:bAction := {|| msgInfo( "Ajustes" ) }
      

   @ 40, 260 PANEL oPanel TITLE "VISTA DE DETALLE" OF oWnd SIZE 500, 450
   oPanel:SetBorderColor( ".gray" )
   oPanel:SetBorderWidth( 0.5 )
   oPanel:SetShadow( 15 )
   
   ACTIVATE WINDOW oWnd CENTERED

return nil
