#include "FiveMac.ch"

CLASS TSwWindow FROM TSwiftControl

    METHOD New( cTitle, nWidth, nHeight, cId )
    METHOD AddControl( oControl, nTop, nLeft )
    METHOD Activate()
    METHOD SetTitle( cTitle )
    METHOD Center()
    METHOD End()

ENDCLASS

METHOD New( cTitle, nWidth, nHeight, cId ) CLASS TSwWindow

    DEFAULT nWidth := 500, nHeight := 400
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( 0, 0, nWidth, nHeight, cId )

    ::hWnd = SW_CREATEWINDOW( cTitle, nWidth, nHeight, ::cId )
    
    ::hState["type"] := "window"
    
    // Register directly using our already-set ID
    // avoiding standard :Register() to not touch SW_GET_ID
    SwiftRegisterItem( ::cId, Self )

return Self

METHOD Activate( lCenter ) CLASS TSwWindow
    if !Empty( lCenter )
       ::Center()
    endif
    // Use our custom Swift-based loop starter to ensure 
    // it always fires even if wndMain is not set in Harbour.
    SW_APPRUN()
return nil

METHOD AddControl( oControl, nTop, nLeft ) CLASS TSwWindow
    
    // Ignore automatic calls from New() that don't specify coordinates
    if nTop == nil .and. nLeft == nil
       return nil
    endif

    SW_ADD_WINDOW_ITEM( ::cId, oControl:cId )

return nil


METHOD SetTitle( cTitle ) CLASS TSwWindow
    SD:Apply( ::cId, { "title" => cTitle } )
return nil

METHOD Center() CLASS TSwWindow
    SD:Apply( ::cId, { "center" => .t. } )
return nil

METHOD End() CLASS TSwWindow
    SD:Apply( ::cId, { "close" => .t. } )
return ::Super:End()
