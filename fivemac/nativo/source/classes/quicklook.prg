#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TQuickLook FROM TControl

    DATA cUrl
    DATA nMagnification  INIT 1.0

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cFileName )

    METHOD SetFile( cFileName ) INLINE ( ::cUrl := cFileName, QLPreviewSetFile( ::hWnd, ::cUrl ) )

    METHOD ZoomIn()  INLINE ( ::nMagnification += 0.1, QLPreviewSetZoom( ::hWnd, ::nMagnification ) )
    METHOD ZoomOut() INLINE ( ::nMagnification -= 0.1, QLPreviewSetZoom( ::hWnd, ::nMagnification ) )
    METHOD SetZoom( nVal ) INLINE ( ::nMagnification := nVal, QLPreviewSetZoom( ::hWnd, ::nMagnification ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cFileName ) CLASS TQuickLook

    DEFAULT nWidth := 300, nHeight := 100, oWnd := GetWndDefault()
      
    ::hWnd = QLPreviewCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
    ::oWnd = oWnd
    ::_nAutoResize( 18 )
   
    if ! Empty( cFileName )
    ::SetFile( cFileName )
    endif
   
    oWnd:AddControl( Self ) 

return Self
