#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBtn1, oBtn2, oBtn3, oBtn4, oBtnPlus, oLabelVal, oBtnInfo
   local oLabel, nVal := 0

   DEFINE WINDOW oWnd TITLE "SwiftUI Premium Buttons" SIZE 500, 600
   oWnd:cBackColor := ".gradient(#2c3e50, #000000)" 

   @ 500, 50 SAY oLabel PROMPT "Prueba de Botones" OF oWnd SIZE 400, 40
   oLabel:uFontSize := 24
   oLabel:cColor := ".white"
   oLabel:nAlignment := 1

   // 1. Botón Cápsula con Degradado
   @ 420, 100 BUTTON oBtn1 PROMPT "Enviar" OF oWnd SIZE 200, 45 ACTION MsgInfo( "Botón Cápsula pulsado" )
   oBtn1:cBackColor := ".gradient(.orange, .red)"
   oBtn1:cColor := ".white"
   oBtn1:uFontSize := 18
   oBtn1:cFontStyle := ".bold"
   oBtn1:nShadow := 5
   oBtn1:cIcon := "paperplane.fill"
   oBtn1:cBorderShape := ".capsule"

   // 2. Botón Circular de Info
   @ 420, 320 BUTTON oBtnInfo PROMPT "" OF oWnd SIZE 50, 50 ACTION MsgInfo( "Botón Circular pulsado" )
   oBtnInfo:cIcon := "info"
   oBtnInfo:cBorderShape := ".circle"
   oBtnInfo:cBackColor := ".gradient(.blue, .cyan)"
   oBtnInfo:cColor := ".white"

   // 3. Botón con Vibrance (Cristal)
   @ 350, 150 BUTTON oBtn2 PROMPT "Ajustes" OF oWnd SIZE 200, 45 ACTION MsgInfo( "Botón cristal pulsado" )
   oBtn2:cVibrance := ".thin"
   oBtn2:cBackColor := "" 
   oBtn2:cColor := ".white"
   oBtn2:uFontSize := 18
   oBtn2:cIcon := "gearshape.fill"
   oBtn2:cIconColor := ".yellow"

   // 4. Botón Destructivo (ROLE asignado manualmente)
   @ 280, 150 BUTTON oBtn3 PROMPT "Borrar" OF oWnd SIZE 200, 45 ACTION MsgInfo( "Botón Peligro pulsado" )
   oBtn3:nRole := SW_ROLE_DESTRUCTIVE
   oBtn3:cVibrance := ".regular"
   oBtn3:cBackColor := ""
   oBtn3:cColor := ".red"
   oBtn3:uFontSize := 18
   oBtn3:cFontStyle := ".bold"
   oBtn3:cIcon := "trash.fill"
   oBtn3:nShadow := 10

   // 5. Contador con Repeat
   @ 150, 150 SAY oLabelVal PROMPT "Valor: 0" OF oWnd SIZE 200, 30
   oLabelVal:cColor := ".yellow"
   oLabelVal:uFontSize := 20
   oLabelVal:nAlignment := 1

   @ 100, 175 BUTTON oBtnPlus PROMPT "Auto-Incrementar" OF oWnd SIZE 150, 40 ACTION ( nVal++, oLabelVal:SetText( "Valor: " + AllTrim( Str( nVal ) ) ) )
   oBtnPlus:cIcon := "plus.circle.fill"
   oBtnPlus:lRepeat := .t.
   oBtnPlus:cBackColor := ".gradient(.green, .darkgreen)"
   oBtnPlus:cColor := ".white"

   // 6. Controles de Visibilidad y Activación
   @ 40, 50 BUTTON "Ocultar" OF oWnd SIZE 80, 30 ACTION oBtn3:Hide()
   @ 40, 140 BUTTON "Mostrar" OF oWnd SIZE 80, 30 ACTION oBtn3:Show()
   @ 40, 230 BUTTON "Act/Des" OF oWnd SIZE 80, 30 ACTION IIf( oBtn1:isEnabled, oBtn1:Disable(), oBtn1:Enable() )

   ACTIVATE WINDOW oWnd CENTERED

return nil
