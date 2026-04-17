#include "FiveMac.ch"
#include "SwFive.ch"

function Main()
   local oWnd, oImg1, oImg2, oImg3
   local oBtn
   
   DEFINE WINDOW oWnd TITLE "La Isla: SF Symbols" SIZE 500, 400
   
   @ 20, 20 SAY "Galería de SF Symbols Dinámicos" SIZE 300, 20 OF oWnd
   
   // Imagen 1: El sol en naranja
   @ 60, 20 IMAGE oImg1 SYMBOL "sun.max.fill" SIZE 80, 80 OF oWnd
   oImg1:SetColor( CLR_YELLOW )
   
   // Imagen 2: La luna en azul
   @ 60, 120 IMAGE oImg2 SYMBOL "moon.stars.fill" SIZE 80, 80 OF oWnd
   oImg2:SetColor( CLR_BLUE )
   
   // Imagen 3: Un corazón que cambia
   @ 60, 220 IMAGE oImg3 SYMBOL "heart.fill" SIZE 80, 80 OF oWnd
   oImg3:SetColor( CLR_RED )
   
   @ 180, 20 BUTTON "CAMBIAR ICONOS" ;
             ACTION ( oImg1:SetSymbol( "cloud.rain.fill" ), ;
                      oImg1:SetColor( CLR_GRAY ), ;
                      oImg3:SetSymbol( "heart.slash.fill" ), ;
                      oImg3:SetColor( CLR_BLACK ), ;
                      MsgInfo( "Iconos actualizados mediante el Pipeline!" ) ) ;
             SIZE 200, 30 OF oWnd

   @ 240, 20 SAY "Prueba de Redimensionamiento (Anchors):" SIZE 300, 20 OF oWnd
   
   @ 280, 20 IMAGE SYMBOL "desktopcomputer" SIZE 100, 100 OF oWnd ;
            ANCHOR SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT

   ACTIVATE WINDOW oWnd CENTER
   
return nil
