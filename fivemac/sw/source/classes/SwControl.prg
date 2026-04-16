#include "FiveMac.ch"

CLASS TSwiftControl

    DATA cId
    DATA oWnd
    DATA hWnd
    DATA hState INIT {=>}
 
    ACCESS nTop          INLINE ::hState["top"]
    ASSIGN nTop( n )     INLINE ( ::hState["top"] := n, SD:Apply( ::cId, { "top" => n } ) )
    
    ACCESS nLeft         INLINE ::hState["left"]
    ASSIGN nLeft( n )    INLINE ( ::hState["left"] := n, SD:Apply( ::cId, { "left" => n } ) )
    
    ACCESS nWidth        INLINE ::hState["width"]
    ASSIGN nWidth( n )   INLINE ( ::hState["width"] := n, SD:Apply( ::cId, { "width" => n } ) )
    
    ACCESS nHeight       INLINE ::hState["height"]
    ASSIGN nHeight( n )  INLINE ( ::hState["height"] := n, SD:Apply( ::cId, { "height" => n } ) )

    METHOD New( nTop, nLeft, nWidth, nHeight, cId )
    METHOD End()
    METHOD SetPos( nTop, nLeft )
    METHOD SetSize( nWidth, nHeight )
    METHOD Sync()
    METHOD Update( hNewState )
    METHOD Refresh()
    METHOD OnError( ... )
 
ENDCLASS
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cId ) CLASS TSwiftControl
     ::cId     := cId
     
     DEFAULT nWidth := 100, nHeight := 30

    // Inicialización común de Estado (Sin disparar SD:Apply todavía)
    ::hState["top"]    := nTop
    ::hState["left"]   := nLeft
    ::hState["width"]  := nWidth
    ::hState["height"] := nHeight

    SwiftRegisterItem( ::cId, Self )
 return Self

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
            ::hState[ Lower( cProp ) ] := uVal
        next
    endif
return nil

METHOD Refresh() CLASS TSwiftControl
return nil

METHOD End() CLASS TSwiftControl
    SwiftUnregisterItem( ::cId )
return nil

METHOD OnError( ... ) CLASS TSwiftControl
return HB_ExecFromArray( SD, __GetMessage(), hb_AParams() )
