#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oBtn, oSlider, oToggle, oProgress, oImg

   DEFINE WINDOW oWnd TITLE "Fivemac Semantic Colors Normal Test" SIZE 400, 500
   
   @ 20, 20 BUTTON oBtn PROMPT "I am .blue" OF oWnd SIZE 200, 40
   oBtn:Apply( "backcolor", ".blue" )
   oBtn:Apply( "color", ".white" )

   @ 80, 20 SLIDER oSlider VALUE 50 OF oWnd SIZE 200, 40
   oSlider:Apply( "color", ".red" )

   @ 140, 20 TOGGLE oToggle PROMPT "Toggle .green" OF oWnd SIZE 200, 40
   oToggle:Apply( "color", ".green" )

   @ 200, 20 PROGRESS oProgress VALUE 60 OF oWnd SIZE 200, 40
   oProgress:Apply( "color", ".purple" )

   @ 260, 20 IMAGE oImg SYMBOL "heart.fill" OF oWnd SIZE 100, 100
   oImg:Apply( "color", ".red" )

   @ 380, 20 BUTTON oBtn2 PROMPT "I am .orange" OF oWnd SIZE 200, 40
   oBtn2:Apply( "backcolor", ".orange" )

   ACTIVATE WINDOW oWnd CENTERED

return nil
