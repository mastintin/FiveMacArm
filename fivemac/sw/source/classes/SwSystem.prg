#include "swfive.ch"

static oSystem 
static nLastStatusId := 0

//----------------------------------------------------------------------------//

CLASS TSwSystem FROM TSwiftControl
   
   METHOD New() 
   
   DATA hTimerBlocks INIT {=>}
   
   // Diálogos de Información Clásicos (Síncronos)
   METHOD Alert( cText, cTitle )    INLINE SDS:Alert( cText, hb_defaultValue( cTitle, "Atención" ) )
   METHOD MsgInfo( cText, cTitle )  INLINE SDS:MsgInfo( cText, hb_defaultValue( cTitle, "Información" ) )
   METHOD MsgStop( cText, cTitle )  INLINE SDS:MsgStop( cText, hb_defaultValue( cTitle, "Error" ) )
   
   // --- NOTIFICACIONES ASÍNCRONAS (Fire & Forget) ---
   METHOD AlertAsync( cText, cTitle, nType, nSeconds ) ;
      INLINE SD:AlertAsync( cText, hb_defaultValue( cTitle, "Aviso" ), hb_defaultValue( nType, 1 ), hb_defaultValue( nSeconds, 5 ) )

   // --- MENSAJES DE ESTADO (Lifecycle Manual) ---
   METHOD Status( cText, cTitle, nType )
   METHOD StatusClose( cId ) INLINE SD:StatusClose( cId )

   // --- REFRESCO DE EVENTOS ---
   METHOD ProcessEvents()    INLINE SDS:DoEvents()

   // --- MSGRUN MODERNO (Síncrono para Harbour) ---
   METHOD MsgRun( cText, cTitle, bAction, nType )

   // Diálogos de Decisión Clásicos
   METHOD MsgGet( cText, cTitle, aButtons )
   METHOD MsgGetMulti( cText, cTitle )
   METHOD MsgYesNo( cText, cTitle )  INLINE ::MsgGet( cText, cTitle, { "Yes", "No" } )
   METHOD MsgNoYes( cText, cTitle )  INLINE ::MsgGet( cText, cTitle, { "No", "Yes" } )

   // Diálogos de Selección y Archivos
   METHOD MsgList( aItems, cTitle )    INLINE SDS:MsgList( aItems, hb_defaultValue( cTitle, "Seleccionar" ) )
   METHOD MsgSelect( aItems, cTitle )  INLINE ::MsgList( aItems, cTitle )
   METHOD GetFile( cTitle, cTypes )    INLINE SDS:GetFile( hb_defaultValue( cTitle, "Seleccionar Archivo" ), hb_defaultValue( cTypes, "" ) )
   METHOD GetDir( cTitle )             INLINE SDS:GetDir( hb_defaultValue( cTitle, "Seleccionar Carpeta" ) )
   METHOD SaveFile( cTitle, cName )    INLINE SDS:SaveFile( hb_defaultValue( cTitle, "Guardar como" ), hb_defaultValue( cName, "" ) )
   METHOD MsgBeep()                   INLINE SD:Beep()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TSwSystem
   ::Super:New()
return self

//----------------------------------------------------------------------------//

METHOD Status( cText, cTitle, nType ) CLASS TSwSystem
   local cId 
   nLastStatusId++
   cId := "ST_" + AllTrim( Str( nLastStatusId ) )
   SD:StatusShow( cId, cText, hb_defaultValue( cTitle, "Procesando" ), hb_defaultValue( nType, 1 ) )
return cId 

//----------------------------------------------------------------------------//

METHOD MsgGet( cText, cTitle, aButtons ) CLASS TSwSystem
   local hParams := { "text" => cText, "title" => hb_defaultValue( cTitle, "Confirmación" ) }
   if !Empty( aButtons ) ; hParams["buttons"] := aButtons ; endif
return SDS:MsgGet( hParams )

//----------------------------------------------------------------------------//

METHOD MsgGetMulti( cText, cTitle ) CLASS TSwSystem
return SDS:MsgGetMulti( cText, hb_defaultValue( cTitle, "Instrucciones" ) )

//----------------------------------------------------------------------------//

METHOD MsgRun( cText, cTitle, bAction, nType ) CLASS TSwSystem
   local hStatus := SDS:StatusShow( "", cText, hb_defaultValue( cTitle, "Procesando" ), hb_defaultValue( nType, 1 ) )
   if bAction != nil ; Eval( bAction ) ; endif
   SDS:StatusClose( hStatus )
return nil

//----------------------------------------------------------------------------//

static function GetSystem()
   if oSystem == nil ; oSystem := TSwSystem():New() ; endif
return oSystem

FUNCTION MsgBeep() ; return GetSystem():MsgBeep()
FUNCTION Sw_MsgInfo_Bridge( cMsg, cTitle ) ; return GetSystem():MsgInfo( cMsg, cTitle )
FUNCTION SwMsgStop( cMsg, cTitle ) ; return GetSystem():MsgStop( cMsg, cTitle )
FUNCTION SwMsgYesNo( cMsg, cTitle ) ; return GetSystem():MsgYesNo( cMsg, cTitle )
FUNCTION SwMsgNoYes( cMsg, cTitle ) ; return GetSystem():MsgNoYes( cMsg, cTitle )
FUNCTION SwMsgList( aItems, cTitle ) ; return GetSystem():MsgList( aItems, cTitle )
FUNCTION SwMsgSelect( aItems, cTitle ) ; return GetSystem():MsgSelect( aItems, cTitle )
FUNCTION SwMsgGet( cMsg, cTitle, aButtons ) ; return GetSystem():MsgGet( cMsg, cTitle, aButtons )
FUNCTION SwMsgNoob( cMsg, cTitle ) ; return GetSystem():AlertAsync( cMsg, cTitle, 1, 5 )
FUNCTION SwMsgGetMulti( cText, cTitle ) ; return GetSystem():MsgGetMulti( cText, cTitle )
FUNCTION SwNotify( cMsg, cTitle ) ; return GetSystem():Alert( cMsg, cTitle )
FUNCTION SwGetFile( cTitle, cTypes ) ; return GetSystem():GetFile( cTitle, cTypes )
FUNCTION SwGetDir( cTitle ) ; return GetSystem():GetDir( cTitle )
FUNCTION SwSaveFile( cTitle, cName ) ; return GetSystem():SaveFile( cTitle, cName )

// Funciones de Refresco
FUNCTION SwProcessEvents() ; return GetSystem():ProcessEvents()

// Funciones Notificaciones Modernas
FUNCTION SwAlertAsync( cMsg, cTitle, nType, nSec ) ; return GetSystem():AlertAsync( cMsg, cTitle, nType, nSec )
FUNCTION SwStatus( cMsg, cTitle, nType ) ; return GetSystem():Status( cMsg, cTitle, nType )
FUNCTION SwStatusClose( cId ) ; return GetSystem():StatusClose( cId )
FUNCTION SwMsgRun( cMsg, cTitle, bAction, nType ) ; return GetSystem():MsgRun( cMsg, cTitle, bAction, nType )

// --- Gestión de Temporizadores ---
FUNCTION SwTimer( nMs, bAction )
   local cId := hb_uuid()
   GetSystem():hTimerBlocks[ cId ] := bAction
   SD:Timer( nMs, cId )
return cId

// Receptor de avisos desde Swift
FUNCTION SwTimerDone( hParams )
   local cId := hParams[ "p1" ] // El ID que enviamos
   local oSys := GetSystem()
   if hb_HHasKey( oSys:hTimerBlocks, cId )
      Eval( oSys:hTimerBlocks[ cId ] )
      hb_HDel( oSys:hTimerBlocks, cId )
   endif
return nil
