#include "FiveMac.ch"

CLASS TSwWindow FROM TSwiftControl

    METHOD New( cTitle, nWidth, nHeight, cId )
    METHOD AddControl( oControl, nTop, nLeft, nType )
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

METHOD AddControl( oControl, nTop, nLeft, nType ) CLASS TSwWindow
    local cCaption := ""
    
    // Ignore automatic calls from New() that don't specify coordinates
    if nTop == nil .and. nLeft == nil
       return nil
    endif

    // If type is not passed, try to infer it (legacy/fallback)
    if nType == nil
        nType := 0
        if oControl:IsKindOf( "TSWBUTTON" ) ; nType := 9 ; endif
        if oControl:IsKindOf( "TSWAICHAT" ) ; nType := 17 ; endif
        if oControl:IsKindOf( "TSWLABEL" )  ; nType := 0 ; endif
    endif
    
    cCaption := If( __ObjHasMsg( oControl, "CCAPTION" ), oControl:cCaption, "" )
    if Empty( cCaption ) .and. __ObjHasMsg( oControl, "CAPTION" )
       cCaption := oControl:Caption
    endif
    
    SW_ADD_WINDOW_ITEM( ::cId, oControl:cId, nTop, nLeft, oControl:nWidth, oControl:nHeight, nType, cCaption )

return nil


METHOD SetTitle( cTitle ) CLASS TSwWindow
    SD:WindowTitle( ::cId, cTitle )
return nil

METHOD Center() CLASS TSwWindow
    SD:WindowCenter( ::cId )
return nil

METHOD End() CLASS TSwWindow
    SD:WindowClose( ::cId )
return ::Super:End()
