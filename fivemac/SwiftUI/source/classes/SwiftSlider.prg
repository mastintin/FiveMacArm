#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftSliders := {}

CLASS TSwiftSlider FROM TControl

    DATA bAction
    DATA cID
    DATA lShowValue
    DATA lGlass

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction )
    METHOD SetValue( nValue )
    METHOD GetValue()
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

    ::oWnd    = oWnd
    ::bAction = bAction
    ::lShowValue = lShowValue
    ::lGlass = lGlass
   
    AAdd( aSwiftSliders, Self )
    ::cID = hb_UUID()

    ::hWnd = SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::cID, ::lShowValue, ::lGlass )
    
    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetValue( nValue ) CLASS TSwiftSlider
    SD_SLD_SET_VALUE( ::cID, nValue )
return nil

METHOD GetValue() CLASS TSwiftSlider
return SD_SLD_GET_VALUE( ::cID )

METHOD SetAccentColor( nColor ) CLASS TSwiftSlider
    SD_SLD_SET_ACCENT_COLOR( ::cID, clrToHex( nColor ) )
return nil

METHOD SetColor( nFg, nBg ) CLASS TSwiftSlider
    SD_SLD_SET_COLORS( ::cID, clrToHex( nFg ), clrToHex( nBg ) )
return nil

METHOD End() CLASS TSwiftSlider
    local nPos 
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cID, ::hWnd )
        nPos := AScan( aSwiftSliders, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftSliders[ nPos ] := nil
        endif
        ::hWnd := 0
        ::cID := ""
    endif
return ::Super:End()

// The C callback calls this function
function SwiftSliderOnChange( cId, nValue )
    local nPos, oSlider

    nPos := AScan( aSwiftSliders, { |o| o != nil .and. o:cID == cId } )

    if nPos > 0
        oSlider := aSwiftSliders[ nPos ]
        if oSlider:bAction != nil
            Eval( oSlider:bAction, nValue, oSlider )
        endif
    endif

return nil
