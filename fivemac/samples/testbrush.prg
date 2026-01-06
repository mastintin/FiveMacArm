#include "Fivemac.ch"

static oDlg

//----------------------------------------------------------------------------//

function Main()

   local oBrush

   DEFINE BRUSH oBrush COLOR {220,220,220,200}


   DEFINE DIALOG oDlg TITLE "Dialog designer" ;
      FROM  35, 128 TO  355, 692 ;
      BRUSH oBrush

  
oDlg:SetBrush(oBrush)

   @ 116, 72 BUTTON "&Ok" SIZE 140, 12 PIXEL OF oDlg ;
      ACTION hablame()

   @ 116, 232 BUTTON "&Cancel" SIZE 140, 12 PIXEL OF oDlg ;
      ACTION MsgInfo( "Not defined yet!" )

   @  88, 208 SAY "Label:" SIZE 184,  16 PIXEL OF oDlg

   ACTIVATE DIALOG oDlg

return nil


Function hablame()
local cString := "hola ¿como estas?, esto es un intento de ver como hablo"
speak( cString, 100 )
return nil