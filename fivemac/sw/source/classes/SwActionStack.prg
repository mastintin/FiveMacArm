#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Clase para gestionar lotes (batches) de acciones para Swift
// -------------------------------------------------------------------------- //

CLASS TSwActionStack

   CLASSDATA oActive
   DATA aActions   INIT {}

   METHOD New() CONSTRUCTOR
   
   // Control de Grabación Global (Universal)
   METHOD Begin()
   METHOD End()
   
   // Métodos de UI (Compatibles con SwApplyable en Swift)
   METHOD AddUpdate( oControl, cText )
   METHOD AddMove( oControl, nTop, nLeft )
   METHOD AddSize( oControl, nWidth, nHeight )
   METHOD AddColor( oControl, nR, nG, nB, nA )
   
   // Métodos de Workflow (Autónomos)
   METHOD AddHttpGet( cUrl, cContextKey )
   METHOD AddFileWrite( cPath, cContextKey )
   METHOD AddAlert( cText )
   
   // Invocación Genérica Dinámica
   METHOD AddCall( cCmd, hParams )
   METHOD AddControlCall( oControl, cMsg, aArgs )
   
   METHOD Execute()
   METHOD GetJSON()
   METHOD Clear()  INLINE ::aActions := {}

ENDCLASS

// -------------------------------------------------------------------------- //

METHOD New() CLASS TSwActionStack
return Self

// -------------------------------------------------------------------------- //

METHOD Begin() CLASS TSwActionStack
   ::oActive := Self
return Self

METHOD End() CLASS TSwActionStack
   ::oActive := nil
return nil

// -------------------------------------------------------------------------- //

METHOD AddUpdate( oControl, cText ) CLASS TSwActionStack
   // Cambiamos "id" por el parámetro esperado y usamos "value" para generalizar
   AAdd( ::aActions, { "cmd" => "text", "id" => oControl:cId, "value" => cText } )
return nil

METHOD AddMove( oControl, nTop, nLeft ) CLASS TSwActionStack
   // El Dispatcher de Swift espera x, y o p2, p3
   AAdd( ::aActions, { "cmd" => "pos", "id" => oControl:cId, "x" => nLeft, "y" => nTop } )
return nil

METHOD AddSize( oControl, nWidth, nHeight ) CLASS TSwActionStack
   AAdd( ::aActions, { "cmd" => "size", "id" => oControl:cId, "width" => nWidth, "height" => nHeight } )
return nil

METHOD AddColor( oControl, nR, nG, nB, nA ) CLASS TSwActionStack
   hb_default( @nA, 255 )
   // Pasamos el color como un Hash que el Dispatcher/State sepa digerir
   AAdd( ::aActions, { "cmd" => "color", "id" => oControl:cId, "r" => nR, "g" => nG, "b" => nB, "a" => nA } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddHttpGet( cUrl, cContextKey ) CLASS TSwActionStack
   // El comando en Swift es "httpget" (sin guion bajo) según nuestro Dispatcher
   AAdd( ::aActions, { "cmd" => "httpget", "url" => cUrl, "contextKey" => hb_defaultValue( cContextKey, "last_response" ) } )
return nil

METHOD AddFileWrite( cPath, cContextKey ) CLASS TSwActionStack
   AAdd( ::aActions, { "cmd" => "filewrite", "path" => cPath, "contextKey" => hb_defaultValue( cContextKey, "last_response" ) } )
return nil

METHOD AddAlert( cText ) CLASS TSwActionStack
   AAdd( ::aActions, { "cmd" => "alert", "text" => cText } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddCall( cCmd, hParams ) CLASS TSwActionStack
   local hAction := {=>}
   
   if ValType( hParams ) == "H"
      hAction := hb_HClone( hParams )
   endif
   
   hAction[ "cmd" ] := Lower( cCmd ) // Forzamos minúsculas para el Dispatcher
   AAdd( ::aActions, hAction )
return nil

METHOD AddControlCall( oControl, cMsg, aArgs ) CLASS TSwActionStack
   local hParams := {=>}
   local cProp, n
   
   cMsg := Lower( cMsg )
   
   // Si es un SetXXXX, lo tratamos como APPLY para mayor universalidad
   if Left( cMsg, 3 ) == "set"
      cProp := SubStr( cMsg, 4 )
      hParams[ "cmd" ] := "apply"
      hParams[ "id" ]  := oControl:cId
      hParams[ cProp ] := aArgs[1]
   else
      hParams[ "cmd" ] := cMsg
      hParams[ "id" ]  := oControl:cId
      // Empaquetamos argumentos p1, p2...
      for n := 1 to Len( aArgs )
         hParams[ "p" + AllTrim( Str( n ) ) ] := aArgs[ n ]
      next
   endif
   
   AAdd( ::aActions, hParams )
return nil

// -------------------------------------------------------------------------- //

METHOD Execute() CLASS TSwActionStack
   local cJson 

   if !Empty( ::aActions )
      cJson := ::GetJSON()
      SW_LOG( "TSwActionStack:Execute -> " + cJson )
      // Importante: Llamamos a la función que definimos en SwActionRunner.swift
      SW_HB_SEND_SW( cJson )
      ::aActions := {}
   endif
return nil

METHOD GetJSON() CLASS TSwActionStack
   local cJson := ""
   if !Empty( ::aActions )
      cJson := hb_jsonEncode( ::aActions )
   endif
return cJson
