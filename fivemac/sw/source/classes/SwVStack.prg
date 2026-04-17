#include "FiveMac.ch"

#define SW_TYPE_VSTACK 1

CLASS TSwVStack FROM TSwiftControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize ) CLASS TSwVStack

    DEFAULT nWidth := 100, nHeight := 100, oParent := GetWndDefault(), nAutoResize := 0
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    ::oWnd    := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
    ::oParent := oParent
    
    ::Create( SW_TYPE_VSTACK )

return Self
