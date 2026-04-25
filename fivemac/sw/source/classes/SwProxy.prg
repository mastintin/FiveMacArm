#include "FiveMac.ch"
#include "FiveMac.ch"

// -------------------------------------------------------------------------- //
// Punto de entrada global: SD:Metodo()
// -------------------------------------------------------------------------- //

function Sw_GetProxy( lRefresh )
   static oProxy
   local cJson, hMap := {=>}
   
   if oProxy == nil .or. lRefresh == .T.
      // Consultamos a la aduana de Swift (ActionRunner)
      cJson := SW_GET_PROXY_MAP()
      hb_jsonDecode( cJson, @hMap )
      
      if oProxy == nil
         oProxy := TSwProxy():New( hMap )
      else
         oProxy:hMap := hMap
      endif
   endif
return oProxy
 
 function Sw_GetQueryProxy()
    static oProxy
     if oProxy == nil
        oProxy := TSwProxy():New( Sw_GetProxy():hMap )
        oProxy:lQuery      := .T.
        oProxy:lPersistent := .T.
     endif
 return oProxy



// -------------------------------------------------------------------------- //

CLASS TSwProxy
   DATA lBuffering    INIT .F.
   DATA lSync         INIT .F.
   DATA lQuery        INIT .F.   
   DATA lPersistent   INIT .F.   
   DATA oCurrentStack INIT nil
   DATA lCaptured     INIT .F.
   DATA hMap
 
   METHOD New( hMap ) CONSTRUCTOR
   METHOD Pipeline( bAction )
   METHOD Cook( bAction )
   METHOD Sync()      INLINE ( ::lSync := .T., ::lQuery := .F., Self )
   METHOD Query()     INLINE ( ::lQuery := .T., ::lSync := .F., Self ) 
   ERROR HANDLER OnError( ... )
ENDCLASS

METHOD New( hMap ) CLASS TSwProxy
   ::hMap := hMap
return self

METHOD Pipeline( bAction ) CLASS TSwProxy
   local lOldBuffering := ::lBuffering
   local oOldStack     := ::oCurrentStack
   
   ::lBuffering    := .T.
   ::oCurrentStack := TSwActionStack():New()
   
   BEGIN SEQUENCE
      Eval( bAction )
      ::oCurrentStack:Execute()
   RECOVER
      // En caso de error, al menos limpiamos el stack para no acumular
      ::oCurrentStack:Clear()
   END SEQUENCE
   
   ::lBuffering    := lOldBuffering
   ::oCurrentStack := oOldStack
return nil

METHOD Cook( bAction ) CLASS TSwProxy
   local lOldBuffering := ::lBuffering
   local oOldStack     := ::oCurrentStack
   local lOldCaptured  := ::lCaptured
   local cJson         := ""
   local hResult       := {=>}
   
   ::lBuffering    := .T.
   ::lCaptured     := .F.
   ::oCurrentStack := TSwActionStack():New()
   
   BEGIN SEQUENCE
      Eval( bAction )
      cJson := ::oCurrentStack:GetJSON()
   RECOVER
      ::oCurrentStack:Clear()
   END SEQUENCE
   
   hResult["json"]     := cJson
   hResult["captured"] := ::lCaptured

   ::lBuffering    := lOldBuffering
   ::oCurrentStack := oOldStack
   ::lCaptured     := lOldCaptured

return hResult

METHOD OnError( ... ) CLASS TSwProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local hParams := {=>}
   local n, uRet, hRet
    local lSync   := ::lSync
    local lQuery  := ::lQuery 
    local oActive := TSwActionStack():oActive
    
    if !::lPersistent
       ::lSync  := .F.
       ::lQuery := .F.
    endif

   // 1. Prioridad: Intercepción Universal (ActionStack Global)
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
      return nil
   endif
   
   // Caso especial para comando universal
   if Upper( cMsg ) == "APPLY"
      if ValType( aArgs[2] ) == "H"
         hParams := aArgs[2]
      endif
      hParams[ "id" ] := aArgs[1]
      cMsg := "apply"
   else
      // Traducimos comando si existe en el mapa
      if hb_HHasKey( ::hMap, cMsg )
         cMsg := ::hMap[ cMsg ]
      endif
            // Empaquetamos argumentos posicionales para el Dispatcher de Swift
      for n := 1 to Len( aArgs )
         hParams[ "p" + AllTrim( Str( n ) ) ] := aArgs[ n ]
      next
   endif
   
   if ::lBuffering
      ::lCaptured := .T.
      ::oCurrentStack:AddCall( cMsg, hParams )
   else
      hParams[ "cmd" ] := cMsg 
      if lQuery 
         hRet := { "status" => "error", "message" => "Internal Proxy Fail" }
         uRet := SW_PIPELINE_QUERY( hb_jsonEncode( { hParams } ) )
         
         if ValType( uRet ) == "C" .and. !Empty( uRet )
            hRet := {=>}
            hb_jsonDecode( uRet, @hRet )
         endif

         if hRet == nil ; hRet := {=>} ; endif 
         
         if hb_HHasKey( hRet, "result" ) 
            return hRet["result"] 
         endif

         return hRet
      elseif lSync
         uRet := SW_PIPELINE_EXEC_SYNC( hb_jsonEncode( { hParams } ) )
         return uRet
      else
         with object TSwActionStack():New()
            :AddCall( cMsg, hParams )
            :Execute()
         end
      endif
   endif
return nil

// -------------------------------------------------------------------------- //
// Proxy Contextual para Controles (oControl:SD:Metodo)
// -------------------------------------------------------------------------- //

CLASS TSwControlProxy
   DATA cId
   DATA lSync
   DATA lQuery 
   
   METHOD New( cId, lSync, lQuery ) CONSTRUCTOR
   ERROR HANDLER OnError( ... )
ENDCLASS

METHOD New( cId, lSync, lQuery ) CLASS TSwControlProxy
   ::cId    := cId
   ::lSync  := if( lSync == nil, .F., lSync )
   ::lQuery := if( lQuery == nil, .F., lQuery )
return self

METHOD OnError( ... ) CLASS TSwControlProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local oProxy  := Sw_GetProxy()
   local hParams := {=>}
   local n, uRet, cProp, hRet
   local oActive := TSwActionStack():oActive
   
   // 1. Intercepción Universal (ActionStack Global)
   if oActive != nil
      oActive:AddControlCall( self, cMsg, aArgs )
      return nil
   endif

   // Si el comando no es APPLY, lo mandamos como propiedad directa ('apply')
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
         // Aquí mandamos argumentos tradicionales p1, p2...
         hParams[ "p1" ] := ::cId
         for n := 1 to Len( aArgs )
            hParams[ "p" + AllTrim( Str( n + 1 ) ) ] := aArgs[ n ]
         next
      else
         cProp := Lower( __GetMessage() )
         if Left( cProp, 3 ) == "set" ; cProp := SubStr( cProp, 4 ) ; endif
         cMsg := "apply"
         hParams[ cProp ] := aArgs[1]
      endif
   endif

   hParams[ "id" ] := ::cId

   
   if oProxy:lBuffering
      oProxy:lCaptured := .T.
      oProxy:oCurrentStack:AddCall( cMsg, hParams )
   else
      hParams[ "cmd" ] := cMsg 
      if ::lQuery 
         hRet := { "status" => "error", "message" => "Internal Control Proxy Fail" }
         uRet := SW_PIPELINE_QUERY( hb_jsonEncode( { hParams } ) )
         
         if ValType( uRet ) == "C" .and. !Empty( uRet )
            hRet := {=>}
            hb_jsonDecode( uRet, @hRet )
         endif

         if hRet == nil ; hRet := {=>} ; endif 
         
         if hb_HHasKey( hRet, "result" ) ; return hRet["result"] ; endif
 
         return hRet
      elseif ::lSync
         uRet := SW_PIPELINE_EXEC_SYNC( hb_jsonEncode( { hParams } ) )
         return uRet
      else
         oProxy:oCurrentStack := TSwActionStack():New()
         oProxy:oCurrentStack:AddCall( cMsg, hParams )
         oProxy:oCurrentStack:Execute()
         oProxy:oCurrentStack := nil
      endif
   endif
return nil
