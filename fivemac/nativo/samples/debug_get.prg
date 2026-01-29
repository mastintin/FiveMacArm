#include "FiveMac.ch"

function Main()
   local oWnd, oGet, cVar := "Hello"

   DEFINE WINDOW oWnd TITLE "Debug GET" SIZE 400, 400 FLIPPED

   // Bottom-Up: 350 is near top
   @ 200, 50 GET oGet VAR cVar OF oWnd SIZE 200, 30

   // Add debug action
   oGet:bLButtonDown := {|| MsgInfo( "Clicked!" ) }

   ACTIVATE WINDOW oWnd CENTERED
return nil
