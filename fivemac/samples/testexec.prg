#include "FiveMac.ch"

function Main()

   local oWnd
   local cprg := Path()+"/testbtn.prg"

   ? cprg

   DEFINE WINDOW oWnd TITLE "Testing MacExec()"

   @ 200, 40 BUTTON "Calculator" ACTION MacExec( "calculator" )

@ 150, 40 BUTTON "TextEdit" ACTION OPENFILEWITHAPP( Path()+"/testbtn.prg", "Textedit.app")



   ACTIVATE WINDOW oWnd

return nil
