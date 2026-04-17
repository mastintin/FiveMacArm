#include "FiveMac.ch"

CLASS TSwWindow FROM TSwiftControl

    METHOD New( cTitle, nWidth, nHeight, cId, oParent )
    METHOD Activate()
    METHOD SetTitle( cTitle )
    METHOD Center()
    METHOD End()

ENDCLASS

METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CLASS TSwWindow

    DEFAULT nWidth := 500, nHeight := 400
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( 0, 0, nWidth, nHeight, cId )
    
    ::oWnd    := oParent
    ::oParent := oParent

    SW_CREATEWINDOW( cTitle, nWidth, nHeight, ::cId )
    
    ::hState["type"] := "window"
    
    SwiftRegisterItem( ::cId, Self )

return Self

METHOD Activate( lCenter ) CLASS TSwWindow
    if !Empty( lCenter )
       ::Center()
    endif
    
    // Solo arrancamos el bucle si somos la ventana principal (sin padre)
    if ::oParent == nil
       SwApp():Activate()
    endif
    
return nil

return nil



METHOD SetTitle( cTitle ) CLASS TSwWindow
    SD:Apply( ::cId, { "title" => cTitle } )
return nil

METHOD Center() CLASS TSwWindow
    SD:Apply( ::cId, { "center" => .t. } )
return nil

METHOD End() CLASS TSwWindow
return ::Super:End()
