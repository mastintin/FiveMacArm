#include "swfive.ch"
 
// -------------------------------------------------------------------------- //
// Proxy Principal (SD / SDS / SDQ)
// -------------------------------------------------------------------------- //
 
CLASS TSwProxy
   DATA hMap
   DATA lBuffering   INIT .F.
   DATA lCaptured    INIT .F.
   DATA oCurrentStack
   DATA lSync        INIT .F.
   DATA lQuery       INIT .F.
 
   METHOD New() CONSTRUCTOR
   METHOD Sync()     INLINE ( ::lSync := .T., self )
   METHOD Async()    INLINE ( ::lSync := .F., self )
   METHOD Query()    INLINE ( ::lQuery := .T., self )
   METHOD SetQuery( l )
   METHOD Pipeline( bCode )
    
   ERROR HANDLER OnError( ... )
ENDCLASS
 
//----------------------------------------------------------------------------//
 
METHOD New() CLASS TSwProxy
   ::hMap := { ;
      "ALERT"     => "alert", ;
      "BEEP"      => "beep", ;
      "GETFILE"   => "getfile", ;
      "GETDIR"    => "getdir", ;
      "SAVEFILE"  => "savefile" ;
      }
return self
 
//----------------------------------------------------------------------------//
 
METHOD SetQuery( l ) CLASS TSwProxy
   ::lQuery := hb_defaultValue( l, .T. )
return self
 
//----------------------------------------------------------------------------//
 
METHOD Pipeline( bCode ) CLASS TSwProxy
   local oStack := TSwActionStack():New()
   oStack:Begin()
   Eval( bCode, self )
   oStack:End()
   oStack:Execute()
return self
 
//----------------------------------------------------------------------------//
 
METHOD OnError( ... ) CLASS TSwProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local hParams := {=>}
   local n, uRet, hRet
   local oActive := TSwActionStack():oActive
    
   // 1. Intercepción para ActionStack (Buffering)
   if oActive != nil
      if Upper( cMsg ) == "APPLY"
         oActive:AddCall( "apply", hb_HMerge( { "id" => aArgs[1] }, aArgs[2] ) )
      else
         hParams[ "cmd" ] := Lower( cMsg )
         for n := 1 to Len( aArgs )
            hParams[ "p" + AllTrim( Str( n ) ) ] := aArgs[ n ]
         next
         oActive:AddCall( cMsg, hParams )
      endif
      return self
   endif
    
   // 2. Preparación de parámetros
   if Upper( cMsg ) == "APPLY"
      if ValType( aArgs[2] ) == "H"
         hParams := aArgs[2]
      endif
      hParams[ "id" ] := aArgs[1]
      cMsg := "apply"
   else
      if hb_HHasKey( ::hMap, cMsg )
         cMsg := ::hMap[ cMsg ]
      endif
      for n := 1 to Len( aArgs )
         hParams[ "p" + AllTrim( Str( n ) ) ] := aArgs[ n ]
      next
   endif
    
   if ::lBuffering
      ::lCaptured := .T.
      ::oCurrentStack:AddCall( cMsg, hParams )
   else
      hParams[ "cmd" ] := cMsg 
 
      // CASO A: CONSULTA (Espera retorno de valor)
      if ::lQuery
         uRet := SW_HB_QUERY_SW( hb_jsonEncode( { hParams } ) )
         if ValType( uRet ) == "C" .and. !Empty( uRet )
            hRet := {=>}
            hb_jsonDecode( uRet, @hRet )
            if hb_HHasKey( hRet, "result" ) ; return hRet["result"] ; endif
               return hRet
            endif
            return uRet
 
            // CASO B: SÍNCRONO (Espera confirmación de ejecución)
         elseif ::lSync
            uRet := SW_HB_SEND_SYNC( hb_jsonEncode( { hParams } ) )
            ::lSync := .F. // Reset tras ejecución
            return uRet
 
            // CASO C: ASÍNCRONO (Dispara y olvida)
         else
            with object TSwActionStack():New()
            :AddCall( cMsg, hParams )
            :Execute()
         end
      endif
   endif
 
return self
 
// -------------------------------------------------------------------------- //
// Proxy Contextual para Controles (oControl:SD:Metodo)
// -------------------------------------------------------------------------- //
 
CLASS TSwControlProxy
   DATA cId
   DATA lSync
   DATA lQuery 
    
   METHOD New( cId, lSync, lQuery ) CONSTRUCTOR
   METHOD Sync() INLINE ( ::lSync := .T., self )
   ERROR HANDLER OnError( ... )
ENDCLASS
 
//----------------------------------------------------------------------------//
 
METHOD New( cId, lSync, lQuery ) CLASS TSwControlProxy
   ::cId    := cId
   ::lSync  := if( lSync == nil, .F., lSync )
   ::lQuery := if( lQuery == nil, .F., lQuery )
return self
 
//----------------------------------------------------------------------------//
 
METHOD OnError( ... ) CLASS TSwControlProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local oProxy  := Sw_GetProxy()
   local hParams := {=>}
   local n, uRet, cProp, hRet
   local oActive := TSwActionStack():oActive
    
   if oActive != nil
      oActive:AddControlCall( self, cMsg, aArgs )
      return self
   endif
 
   if Upper( cMsg ) == "APPLY"
      if ValType( aArgs[1] ) == "H"
         hParams := aArgs[1]
      else
         hParams[ aArgs[1] ] := aArgs[2]
      endif
      cMsg := "apply"
   else
      if hb_HHasKey( oProxy:hMap, cMsg )
         cMsg := oProxy:hMap[ cMsg ]
         hParams[ "p1" ] := ::cId
         for n := 1 to Len( aArgs )
            hParams[ "p" + AllTrim( Str( n + 1 ) ) ] := aArgs[ n ]
         next
      else
         cProp := Lower( __GetMessage() )
         if Left( cProp, 3 ) == "set" 
            cProp := SubStr( cProp, 4 ) 
            cMsg  := "apply"
            hParams[ cProp ] := aArgs[1]
         elseif Empty( aArgs )
            cMsg := "get"
            hParams[ "property" ] := cProp
         else
            cMsg := "apply"
            hParams[ cProp ] := aArgs[1]
         endif
      endif
   endif
 
   hParams[ "id" ] := ::cId
 
   if oProxy:lBuffering
      oProxy:lCaptured := .T.
      oProxy:oCurrentStack:AddCall( cMsg, hParams )
   else
      hParams[ "cmd" ] := cMsg 
 
      if ::lQuery 
         uRet := SW_HB_QUERY_SW( hb_jsonEncode( { hParams } ) )
         if ValType( uRet ) == "C" .and. !Empty( uRet )
            hRet := {=>}
            hb_jsonDecode( uRet, @hRet )
            if hb_HHasKey( hRet, "result" ) ; return hRet["result"] ; endif
               return hRet
            endif
            return uRet
 
         elseif ::lSync
            uRet := SW_HB_SEND_SYNC( hb_jsonEncode( { hParams } ) )
            ::lSync := .f. 
            return uRet
         else
            with object TSwActionStack():New()
            :AddCall( cMsg, hParams )
            :Execute()
         end
      endif
   endif
return self
 
// -------------------------------------------------------------------------- //
// Funciones de conveniencia (Puentes con el sistema de macros)
// -------------------------------------------------------------------------- //
 
function SWProxy( cType )
   
   static oAsyncProxy
   static oSyncProxy
   static oQueryProxy
 
   DEFAULT cType := "a"
   cType := Lower( cType )
    
   SW_LOG( "🚢 [SWProxy] Requesting type: " + cType )
   
   do case
      case cType == "a"
         if oAsyncProxy == nil
            oAsyncProxy := TSwProxy():New()
         endif
         return oAsyncProxy:Async()
 
      case cType == "s"
         if oSyncProxy == nil
            oSyncProxy := TSwProxy():New():Sync()
         endif
         return oSyncProxy:Sync()
 
      case cType == "q"
         if oQueryProxy == nil
            oQueryProxy := TSwProxy():New():SetQuery( .T. )
         endif
         return oQueryProxy:SetQuery( .T. )
 
         otherwise
         if oAsyncProxy == nil
            oAsyncProxy := TSwProxy():New()
         endif
         return oAsyncProxy:Async()
   endcase
 
return nil
 
//----------------------------------------------------------------------------//
 
FUNCTION Sw_GetProxy()
return SWProxy( "a" )
 
//----------------------------------------------------------------------------//
