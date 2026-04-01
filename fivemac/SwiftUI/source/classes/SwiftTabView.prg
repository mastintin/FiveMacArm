#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftTabView FROM TControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, nAutoResize ) CLASS TSwiftTabView

    local x, cTabId

    DEFAULT nWidth := 300, nHeight := 200, oWnd := GetWndDefault(), aItems := {}, nAutoResize := 0

    ::oWnd = oWnd
    
    // Preparation: Clear and Fill Loader
    SD_TAB_CLEAR()
    
    for each x in aItems
        // x = { oControl/cID, cTitle, cIcon }
        cTabId := ""
        if ValType( x[1] ) == "O" 
            if __ObjHasData( x[1], "cID" )
                cTabId := x[1]:cID
            elseif __ObjHasData( x[1], "cId" ) 
                cTabId := x[1]:cId
            endif
        elseif ValType( x[1] ) == "C"
            cTabId := x[1]
        endif

        if !Empty( cTabId ) .and. Len(x) >= 3
            SD_TAB_ADD( cTabId, x[2], x[3] )
        endif
    next
    
    ::hWnd = SD_SWIFT_TABVIEW_CREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD End() CLASS TSwiftTabView
    if !Empty( ::hWnd )
        SD_TAB_DESTROY( ::hWnd )
    endif
return ::Super:End()
