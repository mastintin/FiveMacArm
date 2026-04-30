#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oMenu
   
   oMenu := BuildMenu()
   SET MENU TO oMenu

   DEFINE WINDOW oWnd TITLE "Test App Menu" SIZE 400, 300
   oWnd:cBackColor := ".gradient(.blue, .black)"

   @ 150, 100 SAY "Mira el menú superior de macOS" OF oWnd SIZE 300, 30
   
   ACTIVATE WINDOW oWnd CENTERED

return nil

function BuildMenu()
   local oMenu
   
   MENU oMenu
      MENUITEM "Archivo"
         MENU
            MENUITEM "Nuevo" ACTION MsgInfo( "Nuevo archivo" ) SHORTCUT "n"
            MENUITEM "Abrir..." ACTION MsgInfo( "Abriendo..." ) SHORTCUT "o"
            SEPARATOR
            MENUITEM "Salir" ACTION sw_Quit() SHORTCUT "q"
         ENDMENU
      
      MENUITEM "Editar"
         MENU
            MENUITEM "Deshacer" ACTION MsgInfo( "Deshacer" ) SHORTCUT "z"
            MENUITEM "Rehacer" ACTION MsgInfo( "Rehacer" ) SHORTCUT "Z"
            SEPARATOR
            MENUITEM "Cortar" ACTION MsgInfo( "Cortar" ) SHORTCUT "x"
            MENUITEM "Copiar" ACTION MsgInfo( "Copiar" ) SHORTCUT "c"
            MENUITEM "Pegar" ACTION MsgInfo( "Pegar" ) SHORTCUT "v"
         ENDMENU

      MENUITEM "Ayuda"
         MENU
            MENUITEM "Acerca de..." ACTION MsgInfo( "Fivemac SwiftUI App Menu" )
         ENDMENU
   ENDMENU

return oMenu

function sw_Quit()
   // Podríamos cerrar la ventana o salir de la app
   MsgInfo( "Saliendo..." )
   __Quit()
return nil
