#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oVStack, oZStack, oImg, oLabel
   local oSlider, oToggle, oProgress, oBtn

   DEFINE WINDOW oWnd TITLE "Fivemac Semantic Colors Showcase" SIZE 500, 600
   
   @ 20, 20 VSTACK oVStack OF oWnd SIZE 460, 560
   oVStack:Apply( "backcolor", ".gray" )
   oVStack:Apply( "corner", 10 )

   // ZStack Section
   @ 0, 0 ZSTACK oZStack OF oVStack SIZE 440, 150
   oZStack:Apply( "backcolor", ".blue" )
   oZStack:Apply( "corner", 15 )

   @ 0, 0 IMAGE oImg SYMBOL "star.fill" OF oZStack SIZE 100, 100
   oImg:Apply( "color", ".yellow" )

   @ 0, 0 SAY oLabel PROMPT "ZSTACK LAYER" OF oZStack SIZE 200, 40
   oLabel:Apply( "color", ".white" )
   oLabel:SetFontSize( 20 )
   oLabel:Apply( "alignment", 1 )

   // Slider Section
   @ 0, 0 SAY PROMPT "Slider with .red tint:" OF oVStack
   @ 0, 0 SLIDER oSlider VALUE 50 OF oVStack 
   oSlider:Apply( "color", ".red" )

   // Toggle Section
   @ 0, 0 SAY PROMPT "Toggle with .green tint:" OF oVStack
   @ 0, 0 TOGGLE oToggle VALUE .T. PROMPT "Status" OF oVStack
   oToggle:Apply( "color", ".green" )
   oToggle:Apply( "textcolor", ".white" )

   // Progress Section
   @ 0, 0 SAY PROMPT "Progress with .purple tint:" OF oVStack
   @ 0, 0 PROGRESS oProgress VALUE 75 OF oVStack 
   oProgress:Apply( "color", ".purple" )

   // Button Section
   @ 0, 0 BUTTON oBtn PROMPT "Action Button (.orange)" OF oVStack
   oBtn:Apply( "backcolor", ".orange" )
   oBtn:Apply( "color", ".white" )

   ACTIVATE WINDOW oWnd CENTERED

return nil
