#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oLabel1, oBtn

   DEFINE WINDOW oWnd TITLE "SwiftUI Label Test" SIZE 500, 400
   oWnd:cBackColor := ".gradient(.blue, .pink)"

   @ 300, 50 SAY oLabel1 PROMPT "Texto de Prueba" OF oWnd SIZE 400, 40
   oLabel1:cIcon := "star.fill"
 
    @ 240, 150 BUTTON "Aplicar Diseño" OF oWnd SIZE 200, 35 ;
       ACTION ( oLabel1:uFontSize := 40, ;
                oLabel1:cFontStyle := ".bold.italic.underline", ;
                oLabel1:cColor := ".gradient(.red, .yellow)", ;
                oLabel1:nAlignment := 1, ;
                oLabel1:cBackColor := ".gradient(.black, .gray, .white)", ;
                oLabel1:cVibrance := "", ;
                oLabel1:nShadow := 0 )
 
    @ 140, 150 BUTTON "Aplicar Vibrance" OF oWnd SIZE 200, 35 ;
       ACTION ( oLabel1:uFontSize := 30, ;
                oLabel1:cFontStyle := ".bold", ;
                oLabel1:cColor := ".primary", ;
                oLabel1:nAlignment := 1, ;
                oLabel1:cBackColor := "", ;
                oLabel1:cVibrance := ".regular", ;
                oLabel1:nShadow := 0 )
 
    @ 90, 150 BUTTON "Transparencia Total" OF oWnd SIZE 200, 35 ;
       ACTION ( oLabel1:cBackColor := "", oLabel1:cVibrance := "" )

    @ 40, 150 BUTTON "Alternar Sombra Texto" OF oWnd SIZE 200, 35 ;
       ACTION ( oLabel1:nTextShadow := IIf( oLabel1:nTextShadow == 0, 3, 0 ) )

    @ 5, 80 BUTTON "Ocultar" OF oWnd SIZE 150, 30 ACTION oLabel1:Hide()
    @ 5, 260 BUTTON "Mostrar" OF oWnd SIZE 150, 30 ACTION oLabel1:Show()

   ACTIVATE WINDOW oWnd CENTERED

return nil
