#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBtnCenter, oGauge1, oGauge2, oGauge3
   local nVal := 45

   DEFINE WINDOW oWnd TITLE "Modern Gauges Showcase" SIZE 600, 500
   
   @ 30, 40 GAUGE oGauge1 VALUE nVal RANGE 0, 100 PROMPT "Red Glass" ;
      SIZE 120, 120 COLOR ".red.glass" STYLE SW_GAUGE_PREMIUM OF oWnd UNIT "%"

   @ 30, 200 GAUGE oGauge2 VALUE 75 RANGE 0, 100 PROMPT "Orange Glass" ;
      SIZE 180, 150 COLOR ".orange.glass" STYLE SW_GAUGE_SPEEDOMETER OF oWnd UNIT "km/h"

   @ 200, 40 GAUGE oGauge3 VALUE 30 RANGE 0, 100 PROMPT "Linear System" ;
      SIZE 300, 50 COLOR ".green" STYLE SW_GAUGE_LINEAR OF oWnd

   @ 320, 60 BUTTON "" SIZE 60, 60 OF oWnd ;
      ACTION ( nVal += 10, ;
               If( nVal > 100, nVal := 0, ), ;
               oGauge1:Value := nVal, ;
               oGauge2:Value := nVal, ;
               oGauge3:Value := nVal ) ;
      STYLE ".blue.glass" ICON "plus" SHAPE ".circle"

   @ 327, 160 BUTTON "Auto Demo" SIZE 150, 45 OF oWnd ;
      ACTION TimerDemo( oGauge1, oGauge2, oGauge3 ) ;
      STYLE ".orange.gota" ICON "play.fill"

   ACTIVATE WINDOW oWnd

return nil

function TimerDemo( oG1, oG2, oG3 )
   static oTimer
   static nVal := 0
   
   if oTimer == nil
      oTimer := TTimer():New( 500, { || ;
         nVal += hb_RandomInt( 1, 15 ), ;
         if( nVal > 100, nVal := 0, ), ;
         oG1:Value := nVal, ;
         oG2:Value := nVal, ;
         oG3:Value := nVal } )
      oTimer:Activate()
   else
      oTimer:Deactivate()
      oTimer := nil
   endif
return nil
