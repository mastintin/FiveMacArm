#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftSlider FROM TSwiftControl

    DATA lShowValue
    DATA lGlass

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction )
    METHOD Set( nValue )
    METHOD Get()
    METHOD OnChange( nValue )
    METHOD SetAccentColor( nColor )
    METHOD SetColor( nFg, nBg )
    METHOD End()
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction, nAutoResize ) CLASS TSwiftSlider

    DEFAULT nWidth := 200, nHeight := 40, nValue := 50
    DEFAULT lShowValue := .T.
    DEFAULT lGlass := .F.
    DEFAULT oWnd := GetWndDefault()
    DEFAULT nAutoResize := 0

    ::Super:New( nTop, nLeft, nWidth, nHeight )

    ::oWnd    = oWnd
    ::bAction = bAction
    ::hState["Value"]  = nValue
    ::lShowValue = lShowValue
    ::lGlass = lGlass
   
    ::hWnd = SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::cId, ::lShowValue, ::lGlass )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD Set( nValue ) CLASS TSwiftSlider
    if ::Value != nValue
       ::hState["Value"] := nValue
       SD_SLD_SET_VALUE( ::cId, nValue )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD Get() CLASS TSwiftSlider
return ::Value

//----------------------------------------------------------------------------//

METHOD OnChange( nValue ) CLASS TSwiftSlider
    ::hState["Value"] := nValue
    if ::bAction != nil
        Eval( ::bAction, nValue, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD SetAccentColor( nColor ) CLASS TSwiftSlider
    SD_SLD_SET_ACCENT_COLOR( ::cId, nColor )
return nil

//----------------------------------------------------------------------------//

METHOD SetColor( nFg, nBg ) CLASS TSwiftSlider
    SD_SLD_SET_COLORS( ::cId, clrToHex( nFg ), clrToHex( nBg ) )
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftSlider
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()
