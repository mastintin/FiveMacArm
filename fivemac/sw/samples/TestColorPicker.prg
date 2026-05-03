#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oCp, oLabel
   local cColor := "#FF0000"

   DEFINE WINDOW oWnd TITLE "SwiftUI ColorPicker Demo" SIZE 400, 300

      @ 20, 20 SAY "Selecciona un color" SIZE 300, 30 OF oWnd
      
      @ 60, 20 COLORPICKER oCp VALUE cColor PROMPT "Color de fondo:" ;
         ACTION {|c| oLabel:Value := "Hex: " + c, oWnd:SetColor( c ) } ;
         SIZE 250, 40 OF oWnd

      @ 120, 20 SAY oLabel PROMPT "Hex: " + cColor SIZE 200, 20 OF oWnd

      @ 200, 20 BUTTON "Cerrar" ACTION oWnd:End() SIZE 100, 30 OF oWnd

   ACTIVATE WINDOW oWnd CENTER

return nil
