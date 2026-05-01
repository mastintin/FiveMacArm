#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oCard, oL1, oL2, oHS1
   
   DEFINE WINDOW oWnd TITLE "Dashboard Premium - Simulación" SIZE 450, 550
   
   @ 40, 40 CARD oCard TITLE "Método Normal" SYMBOL "chart.bar.fill" ;
      OF oWnd SIZE 370, 450
      
   // Configuración estética
   oCard:cAccentColor := ".blue"      // Color del acento
   oCard:nAccentSide  := SW_ACCENT_LEFT // Lado del acento (Izquierda)
   oCard:nAccentWidth := 6            // Grosor del acento (NUEVO)
   oCard:cBorderColor := ".gray"      // Borde exterior
   oCard:nBorderWidth := 1            // Ancho del borde exterior
   oCard:nShadow      := 20           // Sombra profunda
   oCard:nCorner      := 18           // Bordes redondeados
   oCard:cBackColor   := ".gradient(#f8faff, #ffffff)"     // Fondo blanco
   oCard:cIconColor   := ".gray"      // Icono grisáceo
      
   // Contenido interno
   @ 10, 0 SAY "Base Reguladora:" SIZE 200, 25 OF oCard
      
   @ 40, 0 SAY oL1 PROMPT "0.00 €" OF oCard SIZE 300, 45
      oL1:uFontSize  := 34
      oL1:cFontStyle := "bold"
      
   @ 95, 0 HSTACK oHS1 OF oCard SIZE 320, 25
      @ 0, 0 SAY "Coef. Reductor:" OF oHS1
      @ 0, 0 SPACER OF oHS1
      @ 0, 0 SAY oL2 PROMPT "0.00 %" OF oHS1
         oL2:cFontStyle := "bold"
         
   @ 135, 0 SAY "Suma Bases Reval.:" OF oCard
   @ 160, 0 SAY "0.00 €" OF oCard
      
   @ 200, 0 SAY "Meses Computados:" OF oCard
   @ 225, 0 SAY "-" OF oCard

   @ 265, 0 SAY "Divisor:" OF oCard
   @ 290, 0 SAY "-" OF oCard
      
   ACTIVATE WINDOW oWnd CENTER
   
return nil
