#include "FiveMac.ch"
 
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
 
     METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     METHOD Create( nType )
     METHOD SetText( cText )
     METHOD Update( hNewState )
     METHOD Send( lSync )
     METHOD OnAction()
     METHOD OnError( ... )
     METHOD End()
     METHOD SetPos( nTop, nLeft )
     METHOD SetSize( nWidth, nHeight )
     METHOD Sync()
     METHOD Refresh()
  
 ENDCLASS
  
 //----------------------------------------------------------------------------//

  METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize ) CLASS TSwiftControl
      if Empty( cId ) ; cId := hb_UUID() ; endif
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
 
  METHOD Create( nType ) CLASS TSwiftControl
     local hInit := hb_HClone( ::hState )
     local cParentId := ""
 
     if !Empty( ::oParent )
        cParentId := ::oParent:cId 
     elseif !Empty( ::oWnd )
        cParentId := ::oWnd:cId 
     endif
 
     hInit[ "typeid" ]   := nType
     hInit[ "parentid" ] := cParentId
     hInit[ "id" ]       := ::cId
 
     // Enviamos el mensaje de creación al Pipeline asíncrono
     SD:Create( hInit )
 
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
 
 METHOD Sync() CLASS TSwiftControl
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
     ::Send():Text( cText )
 return nil
 
 METHOD Refresh() CLASS TSwiftControl
 return nil
 
 METHOD End() CLASS TSwiftControl
    SD:Apply( ::cId, { "close" => .t. } )
    SwiftUnregisterItem( ::cId )
 return nil
 
 METHOD OnError( ... ) CLASS TSwiftControl
 return HB_ExecFromArray( ::Send(), __GetMessage(), hb_AParams() )
