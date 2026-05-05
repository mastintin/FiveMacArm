#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oCard
   local oHData, oVLabels, oHBtns
   local oGauge

   DEFINE WINDOW oWnd TITLE "Debug Layout Glass" SIZE 600, 500

   @ 40, 50 CARD oCard TITLE "Cálculo de Jubilación" SYMBOL "timer" OF oWnd SIZE 440, 360
      oCard:nSpacing := 30
      
      // BLOQUE 1: Gauge y Datos (HStack)
      @ 0, 0 HSTACK oHData OF oCard
         oHData:nSpacing := 15
         
         @ 0, 0 GAUGE oGauge VALUE 13631 RANGE 0, 25000 OF oHData SIZE 120, 120 ;
            STYLE 3 PROMPT "Cotizado" UNIT "días" SHOWVALUE COLOR ".cyan.glass"

         @ 0, 0 VSTACK oVLabels OF oHData
            oVLabels:nSpacing := 4
            @ 0, 0 SAY "Días Registrados:" OF oVLabels SIZE 200, 20
            @ 0, 0 GET "13631" OF oVLabels SIZE 200, 35
            @ 0, 0 SAY "Meta: 14,053 días" OF oVLabels SIZE 200, 20
            @ 0, 0 SAY "Estado: Próxima" OF oVLabels SIZE 200, 20

      // BLOQUE 2: Botones de Acción (HStack)
      @ 0, 0 HSTACK oHBtns OF oCard
         oHBtns:nSpacing := 20
         
         @ 0, 0 BUTTON "GRABAR" OF oHBtns SIZE 170, 45 ;
            STYLE ".blue.glass" ICON "square.and.arrow.down"

         @ 0, 0 BUTTON "SALIR" OF oHBtns SIZE 170, 45 ;
            STYLE ".red.glass" ICON "xmark.circle"

   ACTIVATE WINDOW oWnd CENTERED

return nil
