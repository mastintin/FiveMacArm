#include "FiveMac.ch"

function Main()

   local oDlg

LOCALESETLANGUAGE( "ru" )


msginfo( LOCALEGETLANGUAGE( LOCALECURRENT() ) )


   DEFINE DIALOG oDlg TITLE "Dialog"
   
   @ 40, 40 BUTTON "Grabar" OF oDlg ACTION SaveForm( oDlg )
   DEFINE MSGBAR OF oDlg
   
   ACTIVATE DIALOG oDlg
   
return nil   


function SaveForm( oDlg )


local cFileName


cFileName := SaveFile( "Grabar archivo", "hola.txt" )


if ! Empty( cFileName )
MemoWrit( cFileName, "Hola" )
endif

return nil
