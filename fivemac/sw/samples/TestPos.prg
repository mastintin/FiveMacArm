#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBtn1, oBtn2, oSay1, oSay2
   
   DEFINE WINDOW oWnd TITLE "Test Posicionamiento Original" SIZE 600, 400
   
   @ 20, 20 SAY oSay1 PROMPT "Esquina Superior Izquierda (20, 20)" OF oWnd SIZE 300, 20
   
   @ 100, 200 SAY oSay2 PROMPT "Centro aproximado (100, 200)" OF oWnd SIZE 300, 20
   
   @ 300, 20 BUTTON oBtn1 PROMPT "Abajo Izquierda (300, 20)" OF oWnd SIZE 200, 30 ;
      ACTION MsgInfo( "Botón 1 pulsado" )
      
   @ 300, 380 BUTTON oBtn2 PROMPT "Abajo Derecha (300, 380)" OF oWnd SIZE 200, 30 ;
      ACTION MsgInfo( "Botón 2 pulsado" )

   ACTIVATE WINDOW oWnd CENTER
   
return nil
