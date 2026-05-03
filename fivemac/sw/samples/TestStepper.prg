#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oStp1, oStp2, oLabel
   local nVal1 := 10
   local nVal2 := 50

   DEFINE WINDOW oWnd TITLE "SwiftUI Stepper Test" SIZE 400, 300

      @ 20, 20 SAY "Modern Stepper Controls" SIZE 300, 30 OF oWnd
      
      @ 60, 20 SAY oLabel PROMPT "Value 1: " + hb_ValToStr( nVal1 ) SIZE 200, 20 OF oWnd

      @ 90, 20 STEPPER oStp1 VAR nVal1 RANGE 0, 20 STEP 1 ;
         PROMPT "Quantity" ;
         ACTION {|n| oLabel:Value := "Value 1: " + hb_ValToStr( n ) } ;
         SIZE 200, 40 OF oWnd

      @ 150, 20 STEPPER oStp2 VAR nVal2 RANGE 0, 100 STEP 5 ;
         PROMPT "Percentage" ;
         ACTION {|n| MsgInfo( "New value: " + hb_ValToStr( n ) ) } ;
         SIZE 200, 40 OF oWnd

      @ 220, 20 BUTTON "Close" ACTION oWnd:End() SIZE 100, 30 OF oWnd

   ACTIVATE WINDOW oWnd CENTER

return nil
