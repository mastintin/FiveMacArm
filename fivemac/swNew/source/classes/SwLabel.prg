#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS SwLabel FROM TSwControl

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, cId )
    METHOD SetText( cText )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, cId ) CLASS SwLabel

    DEFAULT nWidth := 100, nHeight := 20, cPrompt := "Label", oWnd := GetWndDefault()
    
    if Empty( cId ) 
       cId := hb_uuid()
    endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    ::oWnd := oWnd

    SD_SW_LBL_CREATE( nTop, nLeft, nWidth, nHeight, cPrompt, ::cId )
    
    if !Empty( oWnd ) .and. oWnd:IsKindOf( "TSWWINDOW" )
       oWnd:AddControl( Self )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD SetText( cText ) CLASS SwLabel
   // En este PoC, podemos implementar SD_SW_LBL_SETTEXT luego
return nil

//----------------------------------------------------------------------------//
