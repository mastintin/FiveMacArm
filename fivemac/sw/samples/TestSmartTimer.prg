#include "swfive.ch"

static nSecs := 0

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oLbl1, oLbl2, nOp
   local oTimerAutopilot, oTimerDynamic

   DEFINE WINDOW oWnd TITLE "Test Smart Timer & Messages" ;
      SIZE 600, 500

   @ 20, 20 SAY oLbl1 PROMPT "Reloj Autopilot: --:--:--" OF oWnd SIZE 300, 30
   @ 50, 20 SAY oLbl2 PROMPT "Contador Harbour: 0" OF oWnd SIZE 300, 30

   // --- BOTONES DE MENSAJES ---
   
   @ 100, 20 BUTTON "MsgInfo" OF oWnd ;
      SIZE 120, 30 ;
      ACTION MsgInfo( "Esto es un MsgInfo nativo", "Información" )

   @ 100, 150 BUTTON "MsgStop" OF oWnd ;
      SIZE 120, 30 ;
      ACTION MsgStop( "Esto es un MsgStop nativo", "¡Error!" )

   @ 100, 280 BUTTON "MsgBeep" OF oWnd ;
      SIZE 120, 30 ;
      ACTION MsgBeep()

   @ 140, 20 BUTTON "MsgNoYes" OF oWnd ;
      SIZE 120, 30 ;
      ACTION ( if( MsgNoYes( "¿Quieres resetear el contador?", "Decisión" ), ;
      ( msginfo(1), nSecs := 0, oLbl2:SetPrompt( "Contador Harbour: 0" ) ), ;
      MsgInfo( "Operación cancelada" ) ) )

   @ 140, 150 BUTTON "MsgList" OF oWnd ;
      SIZE 120, 30 ;
      ACTION ( nOp := MsgList( { "Opción 1", "Opción 2", "Opción 3" }, "Selecciona una" ), ;
      MsgInfo( "Has elegido la opción: " + hb_ValToStr( nOp ) ) )

   // --- CONTROL DE TIMERS ---

   @ 200, 20 BUTTON "Activar Autopilot" OF oWnd ;
      SIZE 150, 30 ;
      ACTION ( oTimerAutopilot:Activate(), MsgInfo( "Autopilot Activado" ) )

   @ 200, 180 BUTTON "Desactivar Autopilot" OF oWnd ;
      SIZE 150, 30 ;
      ACTION oTimerAutopilot:DeActivate()

   @ 250, 20 BUTTON "Activar Dinámico" OF oWnd ;
      SIZE 150, 30 ;
      ACTION ( oTimerDynamic:Activate(), MsgInfo( "Dinámico Activado" ) )

   @ 250, 180 BUTTON "Desactivar Dinámico" OF oWnd ;
      SIZE 150, 30 ;
      ACTION oTimerDynamic:DeActivate()

   // --- DEFINICIÓN DE TIMERS ---

   // Timer 1: Autopilot (Modo 2)
   // Usamos una llamada nativa a Swift para que sea 100% autónomo
   // oTimerAutopilot := TTimer():New( 1000, {|| Sw_GetProxy():sw_set_time( oLbl1:cId ) } )
   // oTimerAutopilot:DeActivate()

   // Timer 2: Dinámico (Modo 3)
   // Usamos lógica de Harbour pura. El sistema detectará que NO hay captura visual 
   // y obligará a Swift a llamar a Harbour en cada tick.
   // oTimerDynamic := TTimer():New( 1000, {|| ActualizarContador( oLbl2 ) } )
   // oTimerDynamic:DeActivate()

   ACTIVATE WINDOW oWnd

return nil

//----------------------------------------------------------------------------//

function ActualizarContador( oLbl )
   nSecs++
   oLbl:SetText( "Contador Harbour: " + AllTrim( Str( nSecs ) ) )
return nil

//----------------------------------------------------------------------------//
