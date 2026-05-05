#include "swfive.ch"

#define SW_TYPE_CARD 19

CLASS TSwCard FROM TSwVStack

    DATA cTitle
    DATA cSymbol
    DATA cAccentColor
    DATA cIconColor
    DATA cTitleColor
    DATA cBackColor

    METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cTitle, cSymbol, cBackColor )
    
    ACCESS cAccentColor      INLINE hb_HGetDef( ::hState, "accentcolor", "" )
    ASSIGN cAccentColor( c ) INLINE ( ::hState["accentcolor"] := c, ::Apply( "accentcolor", c ) )
    
    ACCESS cIconColor        INLINE hb_HGetDef( ::hState, "iconcolor", "" )
    ASSIGN cIconColor( c )   INLINE ( ::hState["iconcolor"]   := c, ::Apply( "iconcolor", c ) )
    
    ACCESS cTitleColor       INLINE hb_HGetDef( ::hState, "titlecolor", "" )
    ASSIGN cTitleColor( c )  INLINE ( ::hState["titlecolor"]  := c, ::Apply( "titlecolor", c ) )
    
    ACCESS cBackColor        INLINE hb_HGetDef( ::hState, "backcolor", "" )
    ASSIGN cBackColor( c )   INLINE ( ::hState["backcolor"]   := c, ::Apply( "backcolor", c ) )

    ACCESS nShadow           INLINE hb_HGetDef( ::hState, "shadow", 5 )
    ASSIGN nShadow( n )      INLINE ( ::hState["shadow"] := n, ::Apply( "shadow", n ) )
    
    ACCESS nCorner           INLINE hb_HGetDef( ::hState, "corner", 12 )
    ASSIGN nCorner( n )      INLINE ( ::hState["corner"] := n, ::Apply( "corner", n ) )

    ACCESS nAccentSide       INLINE hb_HGetDef( ::hState, "accentside", 1 )
    ASSIGN nAccentSide( n )  INLINE ( ::hState["accentside"] := n, ::Apply( "accentside", n ) )

    ACCESS nAccentWidth      INLINE hb_HGetDef( ::hState, "accentwidth", 4 )
    ASSIGN nAccentWidth( n ) INLINE ( ::hState["accentwidth"] := n, ::Apply( "accentwidth", n ) )
    
    ACCESS cBorderColor      INLINE hb_HGetDef( ::hState, "bordercolor", "" )
    ASSIGN cBorderColor( c ) INLINE ( ::hState["bordercolor"] := c, ::Apply( "bordercolor", c ) )
    
    ACCESS nBorderWidth      INLINE hb_HGetDef( ::hState, "borderwidth", 0 )
    ASSIGN nBorderWidth( n ) INLINE ( ::hState["borderwidth"] := n, ::Apply( "borderwidth", n ) )

    ACCESS lGlass            INLINE hb_HGetDef( ::hState, "isglass", .F. )
    ASSIGN lGlass( l )       INLINE ( ::hState["isglass"] := l, ::Apply( "isglass", l ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cTitle, cSymbol, cBackColor ) CLASS TSwCard

    DEFAULT nWidth := 200, nHeight := 150, nAutoResize := 0
    DEFAULT cTitle := "", cSymbol := ""

    if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif

    ::cId     := cId
    ::hState["id"]          := ::cId
    ::hState["top"]         := nTop
    ::hState["left"]        := nLeft
    ::hState["width"]       := nWidth
    ::hState["height"]      := nHeight
    ::hState["resizemask"]  := nAutoResize
    ::hState["type"]        := SW_TYPE_CARD
    
    if hb_IsObject( oParent )
       ::oWnd               := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
       ::hState["parentid"] := if( __ObjHasData( oParent, "cId"  ), oParent:cId , "NONE" )
    else 
       ::oWnd := oParent
    endif 
    
    ::oParent := oParent
    ::cTitle  := cTitle
    ::cSymbol := cSymbol
    
    ::hState["title"]  := cTitle
    ::hState["symbol"] := cSymbol
    if !Empty( cBackColor ) ; ::hState["backcolor"] := cBackColor ; endif
    
    SwiftRegisterItem( ::cId, Self )
    
    ::Create()

return Self
