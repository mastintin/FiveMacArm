#include "swfive.ch"

#define SW_TYPE_VSTACK 1

CLASS TSwVStack FROM TSwiftControl

    ACCESS nSpacing          INLINE ::hState["spacing"]
    ASSIGN nSpacing( n )     INLINE ( ::hState["spacing"] := n, ::Apply( "spacing", n ) )
    
    ACCESS nAlignment        INLINE ::hState["alignment"]
    ASSIGN nAlignment( n )   INLINE ( ::hState["alignment"] := n, ::Apply( "alignment", n ) )

    METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize ) CLASS TSwVStack

    DEFAULT nWidth := 100, nHeight := 100, nAutoResize := 0
    
    if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    if hb_IsObject( oParent )
       ::oWnd               := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
       ::hState["parentid"] := if( __ObjHasData( oParent, "cId"  ), oParent:cId , "NONE" )
    else 
       ::oWnd := oParent
    endif 
    
    ::oParent := oParent
    
    ::hState["type"] := SW_TYPE_VSTACK
    ::Create()

return Self
