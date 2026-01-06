#include "FiveMac.ch"

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "Test SF Symbols in Menu" ;
      FROM 200, 200 TO 500, 600

   MENU oWnd
      MENUITEM "File"
      MENU
         MENUITEM "New" ACTION MsgInfo( "New" ) IMAGE ImgSymbols( "doc.badge.plus" )
         MENUITEM "Open" ACTION MsgInfo( "Open" ) IMAGE ImgSymbols( "folder" )
         SEPARATOR
         MENUITEM "Exit" ACTION oWnd:End() IMAGE ImgSymbols( "power" )
      ENDMENU

      MENUITEM "Settings"
      MENU
         MENUITEM "Preferences" ACTION MsgInfo( "Prefs" ) IMAGE ImgSymbols( "gearshape" )
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oWnd

return nil
