#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oVStack, oHStack, oZStack
   local oBtn1, oBtn2, oBtn3
   local oImg, oLabel

   DEFINE WINDOW oWnd TITLE "Fivemac Stacks Layout Test" SIZE 600, 600
   
   // --- VStack Test ---
   @ 20, 20 VSTACK oVStack OF oWnd SIZE 200, 250
   oVStack:Apply( "backcolor", ".gray" )
   oVStack:nSpacing := 15
   oVStack:nAlignment := 1 // Leading

   @ 0, 0 BUTTON oBtn1 PROMPT "VStack Btn 1" OF oVStack SIZE 150, 40
   @ 0, 0 BUTTON oBtn2 PROMPT "VStack Btn 2" OF oVStack SIZE 150, 40
   @ 0, 0 BUTTON oBtn3 PROMPT "VStack Btn 3" OF oVStack SIZE 150, 40

   // --- HStack Test ---
   @ 20, 240 HSTACK oHStack OF oWnd SIZE 300, 150
   oHStack:Apply( "backcolor", ".blue" )
   oHStack:nSpacing := 20
   oHStack:nAlignment := 2 // Bottom

   @ 0, 0 IMAGE oImg SYMBOL "star.fill" OF oHStack SIZE 60, 60
   oImg:Apply( "color", ".yellow" )

   @ 0, 0 SAY oLabel PROMPT "HStack" OF oHStack SIZE 100, 40
   oLabel:Apply( "color", ".white" )
   oLabel:SetFontSize( 20 )

   // --- ZStack Test ---
   @ 300, 20 ZSTACK oZStack OF oWnd SIZE 250, 250
   oZStack:Apply( "backcolor", ".orange" )
   oZStack:nAlignment := 8 // BottomTrailing

   @ 0, 0 IMAGE oImg SYMBOL "heart.fill" OF oZStack SIZE 200, 200
   oImg:Apply( "color", ".red" )

   @ 0, 0 SAY oLabel PROMPT "ZStack Corner" OF oZStack SIZE 150, 40
   oLabel:Apply( "color", ".white" )
   oLabel:SetFontSize( 18 )

   ACTIVATE WINDOW oWnd CENTERED

return nil
