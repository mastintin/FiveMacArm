#include "swfive.ch"

#define SW_TYPE_MENU 25

CLASS TSwMenu FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ( ::hState["caption"] := c, ::Apply( "caption", c ) )

    ACCESS cIcon        INLINE hb_HGetDef( ::hState, "icon", "" )
    ASSIGN cIcon( c )   INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, nAutoResize, cId )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, nAutoResize, cId ) CLASS TSwMenu

    DEFAULT nWidth := 100, nHeight := 30, cPrompt := "Menu", nAutoResize := 0
    
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::oWnd := oWnd
    
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif

    ::hState["caption"] := cPrompt
    ::hState["type"]    := SW_TYPE_MENU

    ::Create()
    
return Self
