#include "swfive.ch"

function Main()
   local oStp
   oStp := TSwStepper():New( 10, 10, 100, 30, 10, 0, 100, 1, "Test" )
   MsgInfo( "Stepper created" )
return nil
