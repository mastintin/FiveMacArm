#include "swfive.ch"
 
 CLASS TSwiftControl
  
    DATA cId
    DATA oWnd
    DATA oParent
    DATA hState INIT {=>}
    DATA lSincro   INIT .F.
   
    ACCESS nTop          INLINE ::hState["top"]
    ASSIGN nTop( n )     INLINE ( ::hState["top"] := n, ::Apply( "top", n ) )
      
    ACCESS nLeft         INLINE ::hState["left"]
    ASSIGN nLeft( n )    INLINE ( ::hState["left"] := n, ::Apply( "left", n ) )
      
    ACCESS nWidth        INLINE ::hState["width"]
    ASSIGN nWidth( n )   INLINE ( ::hState["width"] := n, ::Apply( "width", n ) )
      
    ACCESS nHeight       INLINE ::hState["height"]
    ASSIGN nHeight( n )  INLINE ( ::hState["height"] := n, ::Apply( "height", n ) )
  
    ACCESS nAutoResize      INLINE ::hState["resizemask"]
    ASSIGN nAutoResize( n ) INLINE ( ::hState["resizemask"] := n, ::Apply( "resizemask", n ) )
 
    ACCESS text             INLINE ::hState["text"]
    ASSIGN text( c )        INLINE ( ::hState["text"] := c, ::Apply( "text", c ) )

    ACCESS isVisible        INLINE hb_HGetDef( ::hState, "visible", .t. )
    ACCESS isEnabled        INLINE hb_HGetDef( ::hState, "enabled", .t. )
    
    METHOD Show()           INLINE ::Apply( "visible", .t. )
    METHOD Hide()           INLINE ::Apply( "visible", .f. )
    METHOD Enable()         INLINE ::Apply( "enabled", .t. )
    METHOD Disable()        INLINE ::Apply( "enabled", .f. )
 
    METHOD Apply( cProp, uVal ) INLINE ::Send():Apply( cProp, uVal )
    
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
    METHOD Sync()          INLINE ::Send( .T. )
    METHOD Query()         INLINE TSwControlProxy():New( ::cId, .T., .T. )
    METHOD Refresh()
    METHOD SetFontSize( nSize ) INLINE ::Apply( "fontSize", nSize )
    METHOD SetColor( cHexColor ) INLINE ::Apply( "backgroundcolor", cHexColor )
    
 ENDCLASS
   
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize ) CLASS TSwiftControl
    if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif
    ::cId     := cId
       
    DEFAULT nWidth := 100, nHeight := 30, nAutoResize := 0
  
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
 
    if Empty( hb_HGetDef( ::hState, "parentid", "" ) )
       if !Empty( ::oParent )
          ::hState[ "parentid" ] := ::oParent:cId 
       elseif !Empty( ::oWnd )
          ::hState[ "parentid" ] := ::oWnd:cId 
       endif
    endif

    if !Empty( hb_HGetDef( ::hState, "parentid", "" ) )
       if !Empty( ::oParent )
          ::hState[ "parentwidth" ]  := ::oParent:nWidth
          ::hState[ "parentheight" ] := ::oParent:nHeight
       elseif !Empty( ::oWnd )
          ::hState[ "parentwidth" ]  := ::oWnd:nWidth
          ::hState[ "parentheight" ] := ::oWnd:nHeight
       endif
    endif
    
    SD:Create( ::hState )
  
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD SetPos( nTop, nLeft ) CLASS TSwiftControl
    ::nTop  := nTop
    ::nLeft := nLeft
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD SetSize( nWidth, nHeight ) CLASS TSwiftControl
    ::nWidth  := nWidth
    ::nHeight := nHeight
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD Update( hNewState ) CLASS TSwiftControl
    local cProp, uVal
      
    if ValType( hNewState ) == "H"
          
       for each cProp in hb_HKeys( hNewState )
          uVal := hNewState[ cProp ]
          if Lower( cProp ) == "event"
             if uVal == "click" .or. uVal == "select"
                ::OnAction()
             elseif uVal == "drop"
                ::OnDrop( hb_HGetDef( hNewState, "files", {} ) )
             endif
          else
             ::hState[ cProp ] := uVal
          endif
       next
  
    endif
  
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD Send( lSync ) CLASS TSwiftControl
 return TSwControlProxy():New( ::cId, hb_defaultValue( lSync, ::lSincro ) )
  
 //----------------------------------------------------------------------------//
  
 METHOD OnAction() CLASS TSwiftControl
 return nil
  
 METHOD SetText( cText ) CLASS TSwiftControl
    ::text := cText
 return nil
  
 //----------------------------------------------------------------------------//
 
 METHOD Refresh() CLASS TSwiftControl
 return nil
  
 //----------------------------------------------------------------------------//
 
 METHOD End() CLASS TSwiftControl
    ::Apply( "close", .t. )
 return nil
  
 //----------------------------------------------------------------------------//
 
 METHOD OnError( ... ) CLASS TSwiftControl
 return HB_ExecFromArray( ::Send(), __GetMessage(), hb_AParams() )
 

METHOD OnDrop( cFile ) CLASS TSwiftControl
return nil
