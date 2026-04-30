#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oGet0, oGet1, oGet2, oGet3, oGet4
   local oLabel0
   local cName := "MANUEL"
   local nAmount := 1234.56
   local cPass := ""
   local cSearch := ""
   local cId := "DOC-2026-X99"

   DEFINE WINDOW oWnd TITLE "SwiftUI Labeled Gets" SIZE 500, 650
   // oWnd:cBackColor := ".gradient(#1a1a2e, #16213e)" 

   @ 570, 50 SAY oLabel0 PROMPT "Formulario Labeled" OF oWnd SIZE 400, 40
   oLabel0:uFontSize := 28
   oLabel0:cColor := ".black"
   oLabel0:nAlignment := 1

   // 0. Get READ ONLY
   @ 480, 50 GET oGet0 VAR cId OF oWnd SIZE 400, 38 ;
      PROMPT "ID DE DOCUMENTO"
   oGet0:lReadOnly := .T.
   oGet0:cIcon := "doc.text.fill"
   oGet0:cColor := ".gray"

   // 1. Get con PROMPT integrado
   @ 390, 50 GET oGet1 VAR cName OF oWnd SIZE 400, 38 ;
      PROMPT "NOMBRE COMPLETO" ;
      PICTURE "@!" PLACEHOLDER "Introduce tu nombre..."
   oGet1:cIcon := "person.fill"
   oGet1:cIconColor := ".blue"
   oGet1:cVibrance := ".thin"
   oGet1:cColor := ".black"
   oGet1:cPromptColor := ".black"

   // 2. Get con PROMPT integrado y Picture Numérica (CENTRADO + VALID)
   @ 290, 50 GET oGet2 VAR nAmount OF oWnd SIZE 400, 38 ;
      PROMPT "IMPORTE A FACTURAR (VALID > 100)" ;
      PICTURE "9,999.99" PLACEHOLDER "0.00" ;
      VALID { |o| Val( o:Value ) > 100 }
   oGet2:cIcon := "dollarsign.circle.fill"
   oGet2:cIconColor := ".green"
   oGet2:cVibrance := ".regular"
   oGet2:cColor := ".black"
   oGet2:cPromptColor := ".black"
   oGet2:nAlignment := 1 // Centrado
   oGet2:nShadow := 10
   oGet2:nShadowColor := "#00ff00"

   // 3. Get Password con PROMPT integrado (VALID len >= 8)
   @ 190, 50 GET oGet3 VAR cPass OF oWnd SIZE 400, 38 PASSWORD ;
      PROMPT "CONTRASEÑA SEGURA (Mín. 8)" ;
      PLACEHOLDER "Escribe tu clave..." ;
      VALID { |o| Len( AllTrim( o:Value ) ) >= 8 }
   oGet3:cIcon := "lock.fill"
   oGet3:cIconColor := ".orange"
   oGet3:cVibrance := ".thick"
   oGet3:cColor := ".black"
   oGet3:cPromptColor := ".black"

   // 4. Buscador Estilo Moderno
   @ 90, 50 GET oGet4 VAR cSearch OF oWnd SIZE 400, 38 ;
      PROMPT "BÚSQUEDA GLOBAL" ;
      PLACEHOLDER "Buscar en la base de datos..."
   oGet4:cIcon := "magnifyingglass"
   oGet4:cIconColor := ".cyan"
   oGet4:cBackColor := ".white"
   oGet4:cColor := ".black"
   oGet4:cPromptColor := ".black"
   oGet4:nCornerRadius := 19

   // Botones de Prueba de Selección y Foco
   @ 60, 50 BUTTON "Select All" OF oWnd SIZE 100, 30 ACTION oGet1:SelectAll()
   @ 60, 160 BUTTON "Go Start" OF oWnd SIZE 100, 30 ACTION oGet1:GoToStart()
   @ 60, 270 BUTTON "Go End" OF oWnd SIZE 100, 30 ACTION oGet1:GoToEnd()
   @ 20, 50 BUTTON "Go Pos 5" OF oWnd SIZE 100, 30 ACTION oGet1:GoToPos(5)
   @ 20, 160 BUTTON "Focus" OF oWnd SIZE 100, 30 ACTION oGet1:SetFocus()

   ACTIVATE WINDOW oWnd CENTERED

return nil
