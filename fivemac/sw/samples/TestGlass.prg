#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBtn

   DEFINE WINDOW oWnd TITLE "Test Glass" SIZE 400, 300
   
   @ 100, 100 BUTTON oBtn PROMPT "Botón con Cristal" OF oWnd SIZE 200, 50 ;
      ACTION MsgInfo( "¡Funciona!" )
   
   oBtn:cGlassEffect := ".regular.tint(.orange)"

return nil
