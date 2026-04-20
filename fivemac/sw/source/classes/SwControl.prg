#include "swfive.ch"
 
CLASS TSwiftControl
 
   DATA cId
   DATA oWnd
   DATA oParent
   DATA hState INIT {=>}
   DATA lSincro   INIT .F.
  
   ACCESS nTop          INLINE ::hState["top"]
   ASSIGN nTop( n )     INLINE ( ::hState["top"] := n, SD:Apply( ::cId, { "top" => n } ) )
     
   ACCESS nLeft         INLINE ::hState["left"]
   ASSIGN nLeft( n )    INLINE ( ::hState["left"] := n, SD:Apply( ::cId, { "left" => n } ) )
     
   ACCESS nWidth        INLINE ::hState["width"]
   ASSIGN nWidth( n )   INLINE ( ::hState["width"] := n, SD:Apply( ::cId, { "width" => n } ) )
     
   ACCESS nHeight       INLINE ::hState["height"]
   ASSIGN nHeight( n )  INLINE ( ::hState["height"] := n, SD:Apply( ::cId, { "height" => n } ) )
 
   ACCESS nAutoResize      INLINE ::hState["resizemask"]
   ASSIGN nAutoResize( n ) INLINE ( ::hState["resizemask"] := n, SD:Apply( ::cId, { "resizemask" => n } ) )

   ACCESS text             INLINE ::hState["text"]
   ASSIGN text( c )        INLINE ( ::hState["text"] := c, SD:Apply( ::cId, { "text" => c } ) )
 
   
   METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   METHOD Create()
   METHOD SetText( cText )
   METHOD Update( hNewState )
   METHOD Send( lSync )
   METHOD OnAction()
   METHOD OnError( ... )
   METHOD End()
   METHOD SetPos( nTop, nLeft )
   METHOD SetSize( nWidth, nHeight )
   METHOD Sync() VIRTUAL
   METHOD Refresh()
  
ENDCLASS
  
//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize ) CLASS TSwiftControl
   if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif
   ::cId     := cId
      
   DEFAULT nWidth := 100, nHeight := 30, nAutoResize := 0
 
   // Inicialización de Estado Mínima y Pura
   ::hState["id"]          := ::cId
   ::hState["top"]         := nTop
   ::hState["left"]        := nLeft
   ::hState["width"]       := nWidth
   ::hState["height"]      := nHeight
   ::hState["resizemask"]  := nAutoResize
   ::hState["type"]        := 0
 
   SwiftRegisterItem( ::cId, Self )
return Self
 
//----------------------------------------------------------------------------//
 
METHOD Create() CLASS TSwiftControl
   local hLow := {=>}, cKey

   for each cKey in hb_HKeys( ::hState )
      hLow[ Lower( cKey ) ] := ::hState[ cKey ]
   next
   ::hState := hLow

      
   if Empty( hb_HGetDef( ::hState, "parentid", "" ) )
      if !Empty( ::oParent )
         ::hState[ "parentid" ] := ::oParent:cId 
      elseif !Empty( ::oWnd )
         ::hState[ "parentid" ] := ::oWnd:cId 
      endif
   endif
   
   SW_LOG( "🚢 Harbour: Create Component Type " + hb_ValToStr( ::hState["type"] ) + ;
      " ID: " + ::cId + " Parent: " + hb_HGetDef( ::hState, "parentid", "NONE" ) )
   
   SD:Create( ::hState )
 
return nil
 
//----------------------------------------------------------------------------//
 
METHOD SetPos( nTop, nLeft ) CLASS TSwiftControl
   ::nTop  := nTop
   ::nLeft := nLeft
return nil
 
METHOD SetSize( nWidth, nHeight ) CLASS TSwiftControl
   ::nWidth  := nWidth
   ::nHeight := nHeight
return nil
 
METHOD Update( hNewState ) CLASS TSwiftControl
   local cProp, uVal
     
   if ValType( hNewState ) == "H"
         
      for each cProp in hb_HKeys( hNewState )
         uVal := hNewState[ cProp ]
         SW_LOG( "TSwiftControl:Update [" + ::cId + "] -> " + cProp + " = " + hb_valToStr( uVal ) )
         if Lower( cProp ) == "event" .and. ( uVal == "click" .or. uVal == "select" )
            ::OnAction()
         else
            ::hState[ Lower( cProp ) ] := uVal
         endif
      next
 
   endif
 
return nil
 
//----------------------------------------------------------------------------//
 
METHOD Send( lSync ) CLASS TSwiftControl
return TSwControlProxy():New( ::cId, hb_defaultValue( lSync, ::lSincro ) )
 
//----------------------------------------------------------------------------//
 
METHOD OnAction() CLASS TSwiftControl
   // Método virtual para ser sobreescrito por clases interactivas
return nil
 
METHOD SetText( cText ) CLASS TSwiftControl
   ::text := cText
return nil
 
METHOD Refresh() CLASS TSwiftControl
return nil
 
METHOD End() CLASS TSwiftControl
   SDS:Apply( ::cId, { "close" => .t. } )
   // SwiftUnregisterItem( ::cId )
return nil
 
METHOD OnError( ... ) CLASS TSwiftControl
return HB_ExecFromArray( ::Send(), __GetMessage(), hb_AParams() )
