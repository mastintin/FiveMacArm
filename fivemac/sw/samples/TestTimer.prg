#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oTimer, oSay, nTicks := 0
   local oClock, oTimerClock

   DEFINE WINDOW oWnd TITLE "Timer y Reloj Autónomo HSW" SIZE 400, 300

   @ 180, 50 SAY oSay PROMPT "Ticks: 0" SIZE 300, 40 OF oWnd
   oSay:SetFontSize( 30 )

   // 1. Timer TRADICIONAL
   oTimer := TTimer():New( 1000, { || nTicks++, oSay:SetText( "Ticks: " + AllTrim(Str(nTicks)) ) } )
   oTimer:Activate() // AHORA ES NECESARIO ACTIVARLO

   // 2. Reloj AUTÓNOMO
   @ 100, 50 SAY oClock PROMPT "00:00:00" SIZE 300, 50 OF oWnd
   oClock:SetFontSize( 45 )
   
   oTimerClock := TTimer():New( 1000 )
   oTimerClock:aPipeline := { { "cmd" => "apply", "id" => oClock:cId, "text" => "ctx:now" } }
   oTimerClock:Activate()

   @ 20, 30 BUTTON "Detener Ticks" ACTION oTimer:DeActivate() SIZE 150, 30 OF oWnd
   @ 20, 200 BUTTON "Iniciar Ticks" ACTION oTimer:Activate() SIZE 150, 30 OF oWnd

   ACTIVATE WINDOW oWnd CENTERED

return nil

