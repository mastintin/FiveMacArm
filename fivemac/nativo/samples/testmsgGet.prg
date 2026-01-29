#include "FiveMac.ch"

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "Main Test Window" 
   
   ACTIVATE WINDOW oWnd ON INIT RunTest( oWnd )

return nil

function RunTest( oWnd )

   local cName := Space( 20 )
   
   MsgInfo( "Start" )
   
   if MsgGet( "Test", "Name:", @cName )
      MsgInfo( "Result: " + cName )
   else
      MsgInfo( "Cancelled" )
   endif
   
   oWnd:End()

return nil
