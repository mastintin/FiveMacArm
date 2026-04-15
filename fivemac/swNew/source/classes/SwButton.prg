#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS SwButton FROM TSwControl

    DATA bAction

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, cId )
    METHOD Click()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, cId ) CLASS SwButton

    DEFAULT nWidth := 100, nHeight := 30, cPrompt := "Ok", oWnd := GetWndDefault()
    
    if Empty( cId ) 
       cId := hb_uuid()
    endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction = bAction
    ::oWnd    = oWnd

    SD_SW_BTN_CREATE( nTop, nLeft, nWidth, nHeight, cPrompt, ::cId )
    
    if !Empty( oWnd ) .and. oWnd:IsKindOf( "TSWWINDOW" )
       oWnd:AddControl( Self )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD Click() CLASS SwButton
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif
return nil

//----------------------------------------------------------------------------//
