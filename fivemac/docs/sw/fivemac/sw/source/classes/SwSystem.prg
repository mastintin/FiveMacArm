#include "swfive.ch"

// Funciones de Sistema y Notificaciones (Globales)
//----------------------------------------------------------------------------//

// Funciones de Refresco Globales
FUNCTION SysRefresh()      ; SW_PROCESSEVENTS() ; return SW_PROCESS_EVENTS()
FUNCTION DoEvents()        ; SW_PROCESSEVENTS() ; return SW_PROCESS_EVENTS()
FUNCTION SwProcessEvents() ; SW_PROCESSEVENTS() ; return SW_PROCESS_EVENTS()

// Funciones de Estado y Notificaciones (Nativas directas en SwMsgs.m)
// Se acceden directamente: MsgStatus(), MsgStatusClose(), MsgStatusUpdate(), MsgToast()

FUNCTION MsgGet( cMsg, cTitle, cDefault )      ; return SD:Query():MsgGet( cMsg, cTitle, cDefault )
FUNCTION MsgGetMultiline( cTitle, cDefault, nW, nH ) ; return SD:Query():MsgGetMulti( cTitle, cDefault, nW, nH )
FUNCTION MsgToast( cMsg, cTitle, nType, nSec ) ; return SD:Query():MsgToast( cMsg, cTitle, nType, nSec )
FUNCTION MsgStatus( cMsg, cTitle )             ; return SD:Query():MsgStatus( cMsg, cTitle )
FUNCTION MsgStatusClose()                      ; return SD:Query():MsgStatusCls()
FUNCTION MsgStatusUpdate( nVal )               ; return SD:Query():MsgStatusUpd( nVal )
FUNCTION MsgBeep()                             ; return SD:Beep()
FUNCTION MsgWait( cMsg, cTitle, nSec )         ; return SD:Query():MsgWait( cMsg, cTitle, nSec )

FUNCTION MsgRun( cMsg, cTitle, bAction )
   MsgStatus( cMsg, cTitle )
   if hb_isBlock( bAction )
      Eval( bAction )
   endif
   MsgStatusClose()
return nil

//----------------------------------------------------------------------------//
// REDIRECCIONES AL MOTOR SWIFTVIE (Dispatcher Síncrono)
//----------------------------------------------------------------------------//
// Usamos SD:Query() porque gestiona automáticamente el puente síncrono con Swift,
// incluyendo la codificación de parámetros y la decodificación de la respuesta.
// Esto garantiza que Harbour se detenga hasta que el usuario responda al diálogo.

FUNCTION MsgYesNo( cMsg, cTitle ) ; return SD:Query():MsgYesNo( cMsg, cTitle )
FUNCTION MsgInfo( cMsg, cTitle )  ; return SD:Query():Alert( cMsg, cTitle, 0 )
FUNCTION MsgAlert( cMsg, cTitle ) ; return SD:Query():Alert( cMsg, cTitle, 1 )
FUNCTION MsgStop( cMsg, cTitle )  ; return SD:Query():Alert( cMsg, cTitle, 2 )
FUNCTION MsgNoYes( cMsg, cTitle ) ; return SD:Query():MsgYesNo( cMsg, cTitle, .T. )
FUNCTION MsgDebug( cMsg )         ; return MsgInfo( cMsg, "Debug Info" )
FUNCTION MsgWaitNS( cMsg, cTitle ); return MsgStatus( cMsg, cTitle )
FUNCTION MsgWaitNSStop()          ; return MsgStatusClose()
FUNCTION MsgChoice( cMsg, cTitle, aItems ) ; return SD:Query():MsgChoice( cMsg, cTitle, aItems )
FUNCTION SwMsgList( cTitle, aItems )
return MsgList( aItems, cTitle )

FUNCTION MsgList( aItems, cTitle )
   local nResult := SD:Query():MsgList( aItems, cTitle )
   if hb_IsNumeric( nResult ) .and. nResult > 0 .and. nResult <= Len( aItems )
      return aItems[ nResult ]
   endif
return nil

// Selectores de Archivos
FUNCTION GetFile( cTitle, cTypes, cPrompt ) ; return SD:Query():GetFile( cTitle, cTypes, cPrompt )
FUNCTION GetDir( cTitle, cPrompt )          ; return SD:Query():GetDir( cTitle, cPrompt )
FUNCTION SaveFile( cName, cTitle, cPrompt ) ; return SD:Query():SaveFile( cTitle, cName, cPrompt )

// EOF
