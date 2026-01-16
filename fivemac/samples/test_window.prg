#include "FiveMac.ch"

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "Test Window" SIZE 400, 400

   @ 100, 100 BUTTON "Close" ACTION oWnd:End()

   ACTIVATE WINDOW oWnd

return nil
