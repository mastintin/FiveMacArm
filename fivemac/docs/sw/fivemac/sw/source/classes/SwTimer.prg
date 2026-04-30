#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Clase TTimer - Motor Unificado HSW
// -------------------------------------------------------------------------- //

CLASS TTimer
   DATA cId
   DATA nInterval
   DATA bAction      // Codeblock de Harbour
   DATA aPipeline    // Opcional: Array de comandos para ejecutar en Swift (Autopilot)
   DATA lRepeat
   DATA lActive

   METHOD New( nInterval, bAction, lRepeat ) CONSTRUCTOR
   
   METHOD Activate()
   METHOD DeActivate()
   METHOD End()      INLINE ::DeActivate()
   
   // Métodos internos
   METHOD Update( hEvent )
   METHOD OnAction()
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nInterval, bAction, lRepeat ) CLASS TTimer
   DEFAULT nInterval := 1000
   DEFAULT bAction   := { || nil }
   DEFAULT lRepeat   := .T. 
   
   ::cId       := lower( hb_uuid() )
   ::nInterval := nInterval
   ::bAction   := bAction
   ::lRepeat   := lRepeat
   ::lActive   := .F.
   
   SwiftRegisterItem( ::cId, Self )
   
return Self

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TTimer
   local cJson

   if !::lActive
      ::lActive := .T.
      
      cJson := hb_jsonEncode( { { ;
         "cmd"     => "timer", ;
         "id"      => ::cId, ;
         "ms"      => ::nInterval, ;
         "repeats" => ::lRepeat, ;
         "pipeline"=> ::aPipeline ; // Enviamos la estructura directamente
      } } )
      
      SW_HB_SEND_SW( cJson )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD DeActivate() CLASS TTimer
   if ::lActive
      ::lActive := .F.
      SW_HB_SEND_SW( hb_jsonEncode( { { "cmd" => "timercancel", "id" => ::cId } } ) )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD Update( hEvent ) CLASS TTimer
   if hb_HHasKey( hEvent, "event" ) .and. hEvent["event"] == "timer"
      ::OnAction()
   endif
return nil

//----------------------------------------------------------------------------//

METHOD OnAction() CLASS TTimer
   if !Empty( ::bAction )
      Eval( ::bAction, Self )
   endif
   
   if !::lRepeat
      ::lActive := .F.
      SwiftUnregisterItem( ::cId )
   endif
return nil
