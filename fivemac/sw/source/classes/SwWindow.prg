#include "FiveMac.ch"

CLASS TSwWindow FROM TSwiftControl

    METHOD New( cTitle, nWidth, nHeight, cId )
    METHOD AddControl( oControl, nTop, nLeft )
    METHOD Activate()
    METHOD End()

ENDCLASS

METHOD New( cTitle, nWidth, nHeight, cId ) CLASS TSwWindow

    DEFAULT nWidth := 500, nHeight := 400
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( 0, 0, nWidth, nHeight, cId )

    ::hWnd = SW_CREATEWINDOW( cTitle, nWidth, nHeight, ::cId )
    
    // Register directly using our already-set ID
    // avoiding standard :Register() to not touch SW_GET_ID
    SwiftRegisterItem( ::cId, Self )

return Self

METHOD Activate() CLASS TSwWindow
    // Use our custom Swift-based loop starter to ensure 
    // it always fires even if wndMain is not set in Harbour.
    SW_APPRUN()
return nil

METHOD AddControl( oControl, nTop, nLeft ) CLASS TSwWindow
    local nType := 0
    local cCaption := ""
    
    // Ignore automatic calls from New() that don't specify coordinates
    if nTop == nil .and. nLeft == nil
       return nil
    endif

    // Simple Mapping
    if oControl:IsKindOf( "TSWBUTTON" ) ; nType := 9 ; endif
    if oControl:IsKindOf( "TSWIFTLABEL" ) ; nType := 0 ; endif
    // etc.
    
    cCaption := If( __ObjHasMsg( oControl, "CAPTION" ), oControl:Caption, "" )
    
    SW_ADD_WINDOW_ITEM( ::cId, nType, cCaption, nTop, nLeft, oControl:nWidth, oControl:nHeight, oControl:cId )

return nil

METHOD End() CLASS TSwWindow
    // Clean up
return ::Super:End()
