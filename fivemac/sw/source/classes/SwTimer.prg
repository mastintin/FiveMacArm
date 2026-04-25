#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Clase TTimer (Compatible con sintaxis Native pero con motor Swift Proxy)
// -------------------------------------------------------------------------- //

CLASS TTimer
   DATA cId
   DATA nInterval
   DATA bPipeline
   DATA cPipeline
   DATA lRepeat
   DATA lActive
   DATA oWnd       // Owner (opcional)

   METHOD New( nInterval, bAction, oWnd, lRepeat, lDeActivate ) CONSTRUCTOR
   
   METHOD Activate()
   METHOD DeActivate()
   METHOD End() INLINE ::DeActivate()
   METHOD Fire() INLINE ::OnAction()
   
   // Métodos del framework invisible
   METHOD Update( hNewState )
   METHOD OnAction()
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nInterval, bAction, oWnd, lRepeat, lDeActivate ) CLASS TTimer
   DEFAULT nInterval := 1000
   DEFAULT bAction := { || nil }
   DEFAULT lRepeat := .T. 
   DEFAULT lDeActivate := .F.
   
   ::cId       := lower( hb_uuid() )
   ::nInterval := nInterval
   ::bPipeline := bAction
   ::lRepeat   := lRepeat
   ::lActive   := .F.
   ::oWnd      := oWnd
   
   if hb_IsObject( oWnd )
      oWnd:bOnTimer := bAction // Compatibilidad legacy
   endif
   
   SwiftRegisterItem( ::cId, Self )
   
   ::Activate()
   
   if lDeActivate
      ::DeActivate()
   endif
return Self

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TTimer
   local hCooked
   if !::lActive
      ::lActive := .T.
      
      // Smart Detection: Intentamos "cocinar" el pipeline para ver si es apto para Autopilot
      if ValType( ::bPipeline ) == "B"
         hCooked := Sw_GetProxy():Cook( ::bPipeline )
         
         if hCooked["captured"]
            // MODO AUTOPILOT: Swift ejecutará las acciones localmente
            ::cPipeline := hCooked["json"]
         else
            // MODO DINÁMICO: No hay acciones visuales capturadas, 
            // Swift nos avisará en cada tick para ejecutar la lógica de Harbour
            ::cPipeline := nil
         endif
      endif

      // Parámetros: p1=ms, p2=tag(cId), p3=lRepeat, p4=cPipeline (JSON precocinado)
      SW_PIPELINE_EXEC( hb_jsonEncode( { { "cmd" => "timer", "p1" => ::nInterval, "p2" => ::cId, "p3" => ::lRepeat, "p4" => ::cPipeline } } ) )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD DeActivate() CLASS TTimer
   if ::lActive
      ::lActive := .F.
      SW_PIPELINE_EXEC( hb_jsonEncode( { { "cmd" => "timercancel", "p1" => ::cId } } ) )
   endif
return nil

//----------------------------------------------------------------------------//

// Método de recepción interno desde Swift (disparado vía "event": "click")
METHOD Update( hNewState ) CLASS TTimer
   local cProp, uVal
   for each cProp in hb_HKeys( hNewState )
      uVal := hNewState[ cProp ]
      if Lower( cProp ) == "event" .and. ( uVal == "click" .or. uVal == "timer" )
         ::OnAction()
      endif
   next
return nil

//----------------------------------------------------------------------------//

METHOD OnAction() CLASS TTimer
   if !Empty( ::bPipeline )
      WITH OBJECT Sw_GetProxy()
         // Ejecuta la "aspiradora" de lote para agrupar las sentencias
         :Pipeline( ::bPipeline )
      END
   endif
   
   // Si no era repetitivo, el timer en Swift ya murió, así que nos auto-destruimos en Harbour
   if !::lRepeat
      ::lActive := .F.
      SwiftUnregisterItem( ::cId )
   endif
return nil
