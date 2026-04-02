#include "FiveMac.ch"

function Main()

   local oWnd

   // New default: Flipped!
   DEFINE WINDOW oWnd TITLE "Flipped by default" SIZE 400, 400

   @ 20, 20 BUTTON "Top Left (20,20)" ACTION MsgInfo( "Perfect!" ) SIZE 150, 30

   @ 350, 20 BUTTON "Close" ACTION oWnd:End() SIZE 150, 30 

   ACTIVATE WINDOW oWnd

return nil
