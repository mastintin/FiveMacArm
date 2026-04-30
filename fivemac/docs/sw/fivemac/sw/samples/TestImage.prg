#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oImg1, oImg2, oImg3
   local oBtn
   
   DEFINE WINDOW oWnd TITLE "La Isla HSW: SF Symbols" SIZE 500, 400
   
   @ 20, 20 SAY "Galería de SF Symbols Dinámicos" SIZE 300, 20 OF oWnd
   
   // Imagen 1: El sol en naranja
   @ 60, 20 IMAGE oImg1 PROMPT "sun.max.fill" SIZE 80, 80 OF oWnd
   oImg1:SetColor( CLR_YELLOW )
   
   // Imagen 2: La luna en azul
   @ 60, 120 IMAGE oImg2 PROMPT "moon.stars.fill" SIZE 80, 80 OF oWnd
   oImg2:SetColor( CLR_BLUE )
   
   // Imagen 3: Un corazón que cambia
   @ 60, 220 IMAGE oImg3 PROMPT "heart.fill" SIZE 80, 80 OF oWnd
   oImg3:SetColor( CLR_RED )
   
   oBtn := TSwButton():New( 180, 20, 200, 30, "CAMBIAR ICONOS", oWnd, ;
             {|v| ( oImg1:SetSymbol( "cloud.rain.fill" ), ;
                       oImg1:SetColor( CLR_GRAY ), ;
                       oImg3:SetSymbol( "heart.slash.fill" ), ;
                       oImg3:SetColor( CLR_BLACK ), ;
                       MsgInfo( "Iconos actualizados mediante el Pipeline!" ) ) } )

   @ 240, 20 SAY "Prueba de Redimensionamiento (Anchors):" SIZE 300, 20 OF oWnd
   
   // Imagen 4 sin objeto, acceso directo
   @ 280, 20 IMAGE "desktopcomputer" SIZE 100, 100 OF oWnd

   ACTIVATE WINDOW oWnd CENTER
   
return nil
