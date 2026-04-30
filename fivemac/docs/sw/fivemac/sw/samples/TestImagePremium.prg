#include "SwFive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "mainApp" )
return nil

//----------------------------------------------------------------------------//

function mainApp()

   local oWnd, oImg1, oImg2, oImg3, oImg4, oImgQR, oImgSym
   local nTop := 50

   DEFINE WINDOW oWnd TITLE "SwiftUI Image Premium Showcase" SIZE 900, 700

   // --- FILA 1: MARCOS DE SISTEMA (FRAMES) ---
   @ 20, 20 SAY "Native System Frames:" OF oWnd
   
   @ nTop, 20 IMAGE oImg1 PROMPT "photo" SIZE 120, 120 OF oWnd
   oImg1:SetFrame( 1 ) // Photo style
   @ nTop + 130, 20 SAY "Frame: Photo" OF oWnd SIZE 120, 20

   @ nTop, 160 IMAGE oImg2 PROMPT "cpu" SIZE 120, 120 OF oWnd
   oImg2:SetFrame( 2 ) // GrayBezel
   @ nTop + 130, 160 SAY "Frame: Bezel" OF oWnd SIZE 120, 20

   @ nTop, 300 IMAGE oImg3 PROMPT "externaldrive.fill" SIZE 120, 120 OF oWnd
   oImg3:SetFrame( 3 ) // Groove
   @ nTop + 130, 300 SAY "Frame: Groove" OF oWnd SIZE 120, 20

   @ nTop, 440 IMAGE oImg4 PROMPT "gearshape.fill" SIZE 120, 120 OF oWnd
   oImg4:SetFrame( 4 ) // Button style
   @ nTop + 130, 440 SAY "Frame: Button" OF oWnd SIZE 120, 20

   // --- FILA 2: QR Y SYMBOLS CON ESTILOS ---
   nTop += 200
   @ nTop - 30, 20 SAY "Premium Features (QR & Styled Symbols):" OF oWnd

   @ nTop, 20 IMAGE oImgQR SIZE 180, 180 OF oWnd
   oImgQR:SetQr( "https://harbour.github.io/", 20 )
   oImgQR:Apply( { "corner" => 15, "shadow" => 10, "shadowcolor" => "#FF0000" } )
   @ nTop + 190, 20 SAY "Native QR + Shadow" OF oWnd SIZE 180, 20

   @ nTop, 220 IMAGE oImgSym PROMPT "heart.fill" SIZE 180, 180 OF oWnd
   oImgSym:SetColor( CLR_HRED )
   oImgSym:Apply( { "corner" => 90, "borderwidth" => 4, "bordercolor" => "#FF0000" } )
   oImgSym:bOnDrop := { | aFiles | if( "http" $ aFiles[1], oImgSym:SetUrl( aFiles[1] ), oImgSym:SetFile( aFiles[1] ) ) }
   @ nTop + 190, 220 SAY "Styled Symbol (DROP HERE!)" OF oWnd SIZE 180, 20

   // --- FILA 3: SCALING MODES ---
   nTop += 250
   @ nTop - 30, 20 SAY "Scaling Modes (Native Parity):" OF oWnd
   
   @ nTop, 20 IMAGE oImg1 PROMPT "desktopcomputer" SIZE 200, 100 OF oWnd
   oImg1:SetScaling( 0 ) // Proportional
   oImg1:Apply( { "borderwidth" => 1, "bordercolor" => "#AAAAAA" } )
   @ nTop + 110, 20 SAY "Scaling: Proportional" OF oWnd SIZE 200, 20

   @ nTop, 240 IMAGE oImg2 PROMPT "desktopcomputer" SIZE 200, 100 OF oWnd
   oImg2:SetScaling( 1 ) // Stretch (AxesIndependently)
   oImg2:Apply( { "borderwidth" => 1, "bordercolor" => "#AAAAAA" } )
   @ nTop + 110, 240 SAY "Scaling: Stretch" OF oWnd SIZE 200, 20

   @ 650, 780 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End() ;
      AUTORESIZE AnclaBottom + AnclaRight

   ACTIVATE WINDOW oWnd CENTER

return nil
