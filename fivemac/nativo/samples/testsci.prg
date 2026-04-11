#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oSci

   DEFINE WINDOW oWnd TITLE "FiveMac Scintilla Test" ;
      FROM 100, 100 TO 700, 900

   oSci = TScintilla():New( 60, 20, 560, 760, oWnd )

   @ 15, 20 BUTTON "Themes" OF oWnd SIZE 100, 30 ACTION SelectScintillaTheme( oSci )

   oSci:AddText( "// Welcome to Scintilla 5 on FiveMac Silicon ARM64" + hb_eol() )
   oSci:AddText( "function Test()" + hb_eol() )
   oSci:AddText( "   MsgInfo( 'It works!' )" + hb_eol() )
   oSci:AddText( "return nil" )

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
