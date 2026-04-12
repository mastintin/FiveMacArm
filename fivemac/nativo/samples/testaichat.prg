#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "FiveMac AI Chat Test" ;
      FROM 100, 100 TO 400, 500

   @ 50, 50 BUTTON "Abrir Chat IA" ;
      ACTION AICREATECHAT( "PONER_TU_API_KEY_AQUI", "llama-3.3-70b-versatile" ) ;
      SIZE 200, 30 OF oWnd
   
   @ 100, 50 BUTTON "Salir" ACTION oWnd:End() SIZE 200, 30 OF oWnd

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
