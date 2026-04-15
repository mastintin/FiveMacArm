#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS SwToggle FROM TSwControl

    DATA bAction
    DATA lOn

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, cId, lOn )
    METHOD OnChange( lOn )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, cId, lOn ) CLASS SwToggle

    DEFAULT nWidth := 150, nHeight := 30, cPrompt := "Check", oWnd := GetWndDefault(), lOn := .f.
    
    if Empty( cId ) 
       cId := hb_uuid()
    endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction = bAction
    ::oWnd    = oWnd
    ::lOn     = lOn

    SD_SW_TOG_CREATE( nTop, nLeft, nWidth, nHeight, cPrompt, ::cId, lOn )
    
    if !Empty( oWnd ) .and. oWnd:IsKindOf( "TSWWINDOW" )
       oWnd:AddControl( Self )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD OnChange( lOn ) CLASS SwToggle
    ::lOn := lOn
    if ::bAction != nil
        Eval( ::bAction, lOn, Self )
    endif
return nil

//----------------------------------------------------------------------------//
