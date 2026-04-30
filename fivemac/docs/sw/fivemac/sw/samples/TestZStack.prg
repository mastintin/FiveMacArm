#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oZStack, oImg, oLabel

   DEFINE WINDOW oWnd TITLE "ZStack Test" SIZE 400, 400
   
   @ 50, 50 ZSTACK oZStack OF oWnd SIZE 300, 300
   oZStack:cColor := ".blue" 

   @ 0, 0 IMAGE oImg SYMBOL "star.fill" OF oZStack SIZE 250, 250
   oImg:Apply( "color", ".yellow" )

   @ 0, 0 SAY oLabel PROMPT "HELLO" OF oZStack SIZE 300, 100
   oLabel:Apply( "color", ".white" )
   oLabel:SetFontSize( 60 )
   oLabel:Apply( "alignment", 1 )

   ACTIVATE WINDOW oWnd CENTERED

return nil
