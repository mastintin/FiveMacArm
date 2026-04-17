#include "FiveMac.ch"
 
 CLASS TSwiftControl
 
     DATA cId
     DATA oWnd
     DATA oParent
     DATA hState INIT {=>}
     DATA lScroll
     DATA lSincro   INIT .F.
  
     ACCESS bAction          INLINE ::hState["action"]
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
  
     ACCESS bPipeline        INLINE ::hState["pipeline"]
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
  
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
 
     ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
     ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, SD:Apply( ::cId, { "hasscroll" => l } ) )
 
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
  
  METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize ) CLASS TSwiftControl
      ::cId     := cId
      
      DEFAULT nWidth := 100, nHeight := 30, nAutoResize := 0
 
     // Inicialización de Estado
     ::hState["id"]          := ::cId
     ::hState["top"]         := nTop
     ::hState["left"]        := nLeft
     ::hState["width"]       := nWidth
     ::hState["height"]      := nHeight
     ::hState["resizemask"]  := nAutoResize
     ::hState["hasscroll"]   := .F.
     ::hState["type"]        := 0
     ::hState["action"]      := nil
     ::hState["pipeline"]    := nil
     ::hState["interactive"] := .F.
 
     SwiftRegisterItem( ::cId, Self )
  return Self
 
 //----------------------------------------------------------------------------//
 
 METHOD Create( nType ) CLASS TSwiftControl
    local cParentId := ""
 
    if nType != nil
       ::hState["type"] := nType
    endif
    
    if !Empty( ::oParent )
       cParentId := ::oParent:cId
    elseif !Empty( ::oWnd )
       cParentId := ::oWnd:cId
    endif
 
    SW_COMPONENT_CREATE( ::cId, ::hState["type"], hb_jsonEncode( ::hState ), cParentId )
    
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
                SW_LOG( "TSwiftControl:Update -> Triggering OnAction for " + ::cId )
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
     if hb_HHasKey( ::hState, "pipeline" ) .and. ::hState["pipeline"] != nil
        WITH OBJECT Sw_GetProxy()
           :Pipeline( ::hState["pipeline"] )
        END
     elseif hb_HHasKey( ::hState, "action" ) .and. ::hState["action"] != nil
        Eval( ::hState["action"], Self )
     endif
 return nil
 
 METHOD SetText( cText ) CLASS TSwiftControl
     ::Send():Text( cText )
 return nil
 
 //----------------------------------------------------------------------------//
 
 
 METHOD Refresh() CLASS TSwiftControl
 return nil
 
 METHOD End() CLASS TSwiftControl
    SD:Apply( ::cId, { "close" => .t. } )
    SwiftUnregisterItem( ::cId )
 return nil
 
 METHOD OnError( ... ) CLASS TSwiftControl
 return HB_ExecFromArray( ::Send(), __GetMessage(), hb_AParams() )
