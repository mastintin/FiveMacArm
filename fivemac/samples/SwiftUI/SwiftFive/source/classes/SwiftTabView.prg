#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftTabView FROM TControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems ) CLASS TSwiftTabView

    local x

    DEFAULT nWidth := 300, nHeight := 200, oWnd := GetWndDefault(), aItems := {}

    ::oWnd = oWnd
    ::nId  = ::GetCtrlIndex()
    
    // Preparation: Clear and Fill Loader
    SWIFTTABCLEAR()
    
    for each x in aItems
    // x = { oControl, cTitle, cIcon }
    if Len(x) >= 3 .and. x[1] != nil
    SWIFTTABADD( x[1]:nIndex, x[2], x[3] )
    endif
    next
    
    ::hWnd = SWIFTTABVIEWCREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )

    oWnd:AddControl( Self )

return Self
