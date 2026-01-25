#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftTabView FROM TControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, nAutoResize ) CLASS TSwiftTabView

    local x

    DEFAULT nWidth := 300, nHeight := 200, oWnd := GetWndDefault(), aItems := {}, nAutoResize := 0

    ::oWnd = oWnd
    ::nId  = ::GetCtrlIndex()
    
    // Preparation: Clear and Fill Loader
    SWIFTTABCLEAR()
    
    for each x in aItems
    // x = { oControl/nID, cTitle, cIcon }
    if Len(x) >= 3 
        if ValType( x[1] ) == "O" .and. __ObjHasData( x[1], "nIndex" )
            SWIFTTABADD( x[1]:nIndex, x[2], x[3] )
        elseif ValType( x[1] ) == "N"
            SWIFTTABADD( x[1], x[2], x[3] )
        endif
    endif
    next
    
    ::hWnd = SWIFTTABVIEWCREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self
