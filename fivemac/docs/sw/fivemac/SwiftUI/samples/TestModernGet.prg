#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

   local oWnd, oGet1, oGet2, oEdit, oSay

   DEFINE WINDOW oWnd TITLE "SwiftUI Modern GET Test (Flipped)" ;
      SIZE 500, 600

   @ 50, 50 SWIFTSAY oSay PROMPT "Real-time sync: " OF oWnd SIZE 400, 30
   oSay:SetTextColor( "red" )
   oSay:SetBold( .T. )

   @ 100, 50 SWIFTGET oGet1 VAR "Hello Fivemac" ;
      OF oWnd SIZE 400, 50 ;
      PLACEHOLDER "Type something..." ;
      ON CHANGE { |c| oSay:SetText( "Sync: " + c ) }
   
   oGet1:SetTextColor( "blue" )
   oGet1:SetFontSize( 18 )

   // Test SECURE field (Password)
   @ 180, 50 SWIFTGET oGet2 VAR "" ;
      OF oWnd SIZE 400, 50 ;
      PLACEHOLDER "Enter password..." ;
      ON CHANGE { |c| oSay:SetText( "Sync (Pass): " + c ) }
   
   // No hay comando CH directo para lSecure, lo asignamos vía hState previa
   // o podríamos añadirlo al CH. De momento, test de un solo GET normal.

   // Multi-line Editor
   @ 260, 50 SWIFTEDITOR oEdit VAR "This is an editor." + hb_EOL() + "Supports multiple lines." ;
      OF oWnd SIZE 400, 150 ;
      ON CHANGE { |c| oSay:SetText( "Sync (Edit): " + AllTrim(Str(Len(c))) + " chars" ) }
   
   oEdit:SetAccentColor( "gray", 10 ) // Fondo gris tenue
   oEdit:SetFontSize( 14 )

   @ 450, 200 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil
