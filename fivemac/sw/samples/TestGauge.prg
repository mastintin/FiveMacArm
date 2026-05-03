#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oGauge1, oGauge2, oGauge3, oGauge4, oSld, oSay
   local nVal := 75

   DEFINE WINDOW oWnd TITLE "Test TSwGauge" SIZE 600, 500

   @ 30, 40 GAUGE oGauge1 VALUE nVal RANGE 0, 100 PROMPT "Circular" ;
      SIZE 90, 90 COLOR ".blue" OF oWnd

   @ 40, 160 GAUGE oGauge2 VALUE 45 RANGE 0, 100 PROMPT "Linear" ;
      SIZE 200, 50 COLOR ".green" STYLE SW_GAUGE_LINEAR OF oWnd

   @ 30, 400 GAUGE oGauge3 VALUE 88 RANGE 0, 100 PROMPT "CPU" SUBTITLE "Usage" ;
      SIZE 100, 100 COLOR ".red" ICON "cpu" UNIT "%" OF oWnd

   @ 170, 40 GAUGE oGauge4 VALUE 60 RANGE 0, 200 PROMPT "Temperature" ;
      SIZE 90, 90 COLOR ".orange" UNIT "°C" OF oWnd

   @ 180, 180 BUTTON "Increment" SIZE 140, 40 OF oWnd ;
      ACTION ( nVal := Min( nVal + 10, 100 ), ;
      MsgInfo( "nVal: " + AllTrim(Str(nVal)) ), ;
      oGauge1:Value := nVal, ;
      oGauge4:Value := (nVal * 2 ), ;
      oSld:Value := nVal )

   @ 180, 340 BUTTON "Reset" SIZE 140, 40 OF oWnd ;
      ACTION ( nVal := 10, ;
      oGauge1:Value := nVal, ;
      oGauge2:Value := nVal, ;
      oGauge3:Value := nVal, ;
      oGauge4:Value := 4, ;
      oSld:Value := nVal, ;
      oSay:SetText( "Current: 50" ) )

   @ 300, 40 SAY oSay PROMPT "Current: 75" SIZE 200, 30 OF oWnd

   @ 330, 40 SAY "Sync all gauges:" SIZE 150, 30 OF oWnd
   @ 330, 200 SLIDER oSld VALUE nVal RANGE 0, 100 SIZE 250, 40 OF oWnd 

   oSld:bAction := { | n | oSay:SetText( "Current: " + AllTrim(Str(n)) ), ;
      oGauge1:Value := n, ;
      oGauge2:Value := n, ;
      oGauge3:Value := n  }

     
   ACTIVATE WINDOW oWnd CENTERED
return nil
