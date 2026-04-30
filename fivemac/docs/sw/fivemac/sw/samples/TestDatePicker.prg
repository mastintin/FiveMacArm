#include "swfive.ch"

function main()
   HSW_START_SWIFT( "mainApp" )
return nil

function mainApp()

   local oWnd, oDate1, oDate2, oDate3, oDate4
   local dData := Date()

   DEFINE WINDOW oWnd TITLE "FiveMac Premium DatePickers (Indigo Edition)" ;
          SIZE 850, 800

   // TÍTULO DE LA VENTANA
   @ 20, 20 SAY "Premium Date Selection Components" OF oWnd SIZE 400, 40
   
   // --- SECCIÓN 1: COMPACT & FIELD ---
   @ 80, 20 SAY "Compact Selection" OF oWnd SIZE 200, 20
   @ 110, 20 DATEPICKER oDate1 DATE dData OF oWnd STYLE 0 SIZE 160, 45
   
   @ 80, 220 SAY "Field Input Style" OF oWnd SIZE 200, 20
   @ 110, 220 DATEPICKER oDate4 DATE dData OF oWnd STYLE 3 SIZE 160, 45

   // --- SECCIÓN 2: GRAPHICAL ---
   @ 180, 20 SAY "Auto-Scaling Interactive Calendar (Graphical)" OF oWnd SIZE 400, 20
   @ 210, 20 DATEPICKER oDate2 DATE dData OF oWnd STYLE 1 SIZE 350, 350
   
   // --- SECCIÓN 3: COMPACT (ALT) ---
   @ 650, 20 SAY "Compact Selection (Secondary)" OF oWnd SIZE 200, 20
   @ 680, 20 DATEPICKER oDate3 DATE dData OF oWnd STYLE 2 SIZE 160, 45
   @ 450, 400 SAY "(Wheel is iOS only)" OF oWnd SIZE 200, 20

   // EVENTOS
   oDate1:bOnChange := { | d | MsgInfo( "Selection updated: " + DToC( d ) ) }
   oDate2:bOnChange := { | d | MsgInfo( "Calendar updated: " + DToC( d ) ) }

   ACTIVATE WINDOW oWnd CENTER

return nil
