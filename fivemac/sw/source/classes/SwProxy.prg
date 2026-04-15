#include "FiveMac.ch"
#include "FiveMac.ch"

// -------------------------------------------------------------------------- //
// Punto de entrada global: SD:Metodo()
// -------------------------------------------------------------------------- //

function Sw_GetProxy()
   static oProxy
   local cJson, hMap := {=>}
   
   if oProxy == nil
      // Consultamos a la aduana de Swift (ActionRunner)
      cJson := SW_GET_PROXY_MAP()
      hb_jsonDecode( cJson, @hMap )
      
      oProxy := TSwProxy():New( hMap )
   endif
return oProxy


// -------------------------------------------------------------------------- //

CLASS TSwProxy
   DATA lBuffering    INIT .F.
   DATA lSync         INIT .F.
   DATA oCurrentStack INIT nil
   DATA hMap

   METHOD New( hMap ) CONSTRUCTOR
   METHOD Pipeline( bAction )
   METHOD Sync()      INLINE ( ::lSync := .T., Self )
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

METHOD OnError( ... ) CLASS TSwProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local hParams := {=>}
   local n, uRet
   local lSync := ::lSync
   
   if Sw_IsSyncing() 
      return nil
   endif
   
   // Reseteamos el flag de sincronía para la siguiente llamada
   ::lSync := .F.
   
   SW_LOG( "TSwProxy:OnError -> " + cMsg )
   
   // Traducimos comando si existe en el mapa
   if hb_HHasKey( ::hMap, cMsg )
      cMsg := ::hMap[ cMsg ]
   endif
   
   // Empaquetamos argumentos posicionales para el Dispatcher de Swift
   for n := 1 to Len( aArgs )
      hParams[ "p" + AllTrim( Str( n ) ) ] := aArgs[ n ]
   next
   
   if ::lBuffering
      ::oCurrentStack:AddCall( cMsg, hParams )
   else
      // Ejecución inmediata
      if lSync
         hParams[ "cmd" ] := cMsg 
         SW_LOG( "TSwProxy:SYNC_EXEC -> " + cMsg )
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
   
   METHOD New( cId, lSync ) CONSTRUCTOR
   ERROR HANDLER OnError( ... )
ENDCLASS

METHOD New( cId, lSync ) CLASS TSwControlProxy
   ::cId   := cId
   ::lSync := lSync
return self

METHOD OnError( ... ) CLASS TSwControlProxy
   local cMsg    := __GetMessage() 
   local aArgs   := hb_AParams()   
   local oProxy  := Sw_GetProxy()
   local hParams := {=>}
   local n, uRet
   
   if Sw_IsSyncing() 
      return nil
   endif
   
   // 1. Traducimos el mensaje usando el mapa global (ej: SetText -> text)
   if hb_HHasKey( oProxy:hMap, cMsg )
      cMsg := oProxy:hMap[ cMsg ]
   endif
   
   // 2. Inyectamos el ID como p1 y desplazamos el resto
   hParams[ "id" ] := ::cId  // Por si el comando usa 'id' explícito
   hParams[ "p1" ] := ::cId
   for n := 1 to Len( aArgs )
      hParams[ "p" + AllTrim( Str( n + 1 ) ) ] := aArgs[ n ]
   next
   
   // 3. Respetamos el estado de Buffering global si existe
   if oProxy:lBuffering
      oProxy:oCurrentStack:AddCall( cMsg, hParams )
   else
      // 4. Ejecución inmediata (Sync o Async según nos pidieron)
      if ::lSync
         hParams[ "cmd" ] := cMsg 
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
