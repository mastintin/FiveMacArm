#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oBar

   DEFINE WINDOW oWnd TITLE "SwiftUI Toolbar Test" SIZE 600, 400
   
   DEFINE TOOLBAR oBar OF oWnd
   
      TOOLBARITEM PROMPT "Add" IMAGE "plus" TOOLTIP "Add new item" OF oBar ;
         ACTION MsgInfo( "Adding..." )
         
      TOOLBARITEM PROMPT "Search" IMAGE "magnifyingglass" OF oBar ;
         ACTION MsgInfo( "Searching..." )
         
      TOOLBARITEM PROMPT "Settings" IMAGE "gear" PLACEMENT "primaryAction" OF oBar ;
         ACTION MsgInfo( "Settings..." )

   @ 100, 100 SAY "Check the window toolbar!" OF oWnd SIZE 300, 20
   
   ACTIVATE WINDOW oWnd CENTER

return nil
