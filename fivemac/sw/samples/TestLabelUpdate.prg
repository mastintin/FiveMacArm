#include "SwFive.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oBtn, oLabel

   DEFINE WINDOW oWnd TITLE "Modern Isla Bridge - Label Update" SIZE 400, 300

   @ 150, 100 LABEL oLabel PROMPT "Texto Original" OF oWnd SIZE 200, 24
   
   // Personalizamos un poco el estilo (si SwLabel lo soporta)
   //oLabel:SetColor( "Blue" )

   @ 100, 100 BUTTON oBtn PROMPT "Actualizar Label (Sync)" OF oWnd ;
      ACTION oLabel:SetText( "Update: " + Time(), .F. )

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
