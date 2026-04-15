#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwForm FROM TSwControl

    DATA aControls INIT {}

    METHOD New( cTitle, nWidth, nHeight, cId )
    METHOD AddControl( oControl )
    METHOD Activate()
    METHOD End()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cTitle, nWidth, nHeight, cId ) CLASS TSwForm

    DEFAULT nWidth := 500, nHeight := 400
    
    if Empty( cId ) 
       cId := hb_uuid()
    endif

    ::Super:New( 0, 0, nWidth, nHeight, cId )

    ? "Harbour: Llamando a SD_SW_FORM_CREATE..."
    ::hWnd = SD_SW_FORM_CREATE( cTitle, nWidth, nHeight, ::cId )
    ? "Harbour: Vuelta de SD_SW_FORM_CREATE. hWnd:", ::hWnd

return Self

//----------------------------------------------------------------------------//

METHOD AddControl( oControl ) CLASS TSwForm

    if Empty( oControl ) ; return nil ; endif

    AAdd( ::aControls, oControl )
    oControl:oWnd = Self

    // SD_SW_FORM_ADD_CHILD( ::cId, oControl:cId )

return nil

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TSwForm
    
    SD_SW_FORM_SHOW( ::cId )
    
    // El bucle bloqueante vuelve aquí, al corazón de la ventana
    SD_SW_APP_RUN()

return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwForm
    local oCtrl

    if !Empty( ::aControls )
       for each oCtrl in ::aControls
           oCtrl:End()
       next
       ::aControls := {}
    endif

    // SD_SW_FORM_DESTROY( ::cId )

return ::Super:End()

//----------------------------------------------------------------------------//
