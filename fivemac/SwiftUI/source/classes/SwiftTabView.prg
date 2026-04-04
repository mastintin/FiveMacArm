#include "FiveMac.ch"

// Modernized TSwiftTabView inheriting from TSwiftControl
// This control uses @Observable in Swift and supports dynamic tab adding.

CLASS TSwiftTabView FROM TSwiftControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, nAutoResize, cId )
    METHOD AddTab( cTitle, uControl, cIcon )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, nAutoResize, cId ) CLASS TSwiftTabView

    local x

    DEFAULT nWidth := 300, nHeight := 200, oWnd := GetWndDefault(), aItems := {}, nAutoResize := 0
    
    ::TSwiftControl:New( nTop, nLeft, nWidth, nHeight, cId )
    ::oWnd = oWnd

    // We must create the state in Swift before creating the view
    SD_TAB_CREATE_STATE( ::cId )

    // Call native creation via bridge
    ::hWnd = SD_SWIFT_TABVIEW_CREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, ::cId )

    if !Empty( aItems )
        for each x in aItems
            // x = { oControl/cID, cTitle, cIcon }
             ::AddTab( x[2], x[1], x[3] )
        next
    endif

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD AddTab( cTitle, uControl, cIcon ) CLASS TSwiftTabView
    local cTabId := ""

    DEFAULT cIcon := ""

    if ValType( uControl ) == "O" 
        if __ObjHasData( uControl, "cID" )
            cTabId := uControl:cID
        elseif __ObjHasData( uControl, "cId" ) 
            cTabId := uControl:cId
        endif
    elseif ValType( uControl ) == "C"
        cTabId := uControl
    endif

    if !Empty( cTabId )
        SD_TAB_ADD( ::cId, cTabId, cTitle, cIcon )
    endif

return nil

METHOD End() CLASS TSwiftTabView
    if !Empty( ::hWnd )
        SD_TAB_DESTROY( ::cId, ::hWnd )
        ::hWnd := 0
    endif
return ::TSwiftControl:End()
