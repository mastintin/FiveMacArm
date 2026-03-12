#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftSliders := {}

CLASS TSwiftSlider FROM TControl

    DATA bChange
    DATA nIndex
    DATA cID
    DATA lShowValue
    DATA lGlass

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bChange )
    METHOD SetValue( nValue )
    METHOD GetValue()
    METHOD SetAccentColor( nColor )
    METHOD SetColor( nFg, nBg )
    METHOD End()
   
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bChange, nAutoResize ) CLASS TSwiftSlider

    DEFAULT nWidth := 200, nHeight := 40, nValue := 50
    DEFAULT lShowValue := .T.
    DEFAULT lGlass := .F.
    DEFAULT oWnd := GetWndDefault()
    DEFAULT nAutoResize := 0

    ::oWnd    = oWnd
    ::bChange = bChange
    ::lShowValue = lShowValue
    ::lGlass = lGlass
   
    AAdd( aSwiftSliders, Self )
    ::nIndex = Len( aSwiftSliders )
    ::cID = AllTrim( SWIFT_UUID() )

    ::hWnd = SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::nIndex, ::cID, ::lShowValue, ::lGlass )
    
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
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cID, ::nIndex, ::hWnd )
        if ::nIndex > 0 .and. ::nIndex <= Len( aSwiftSliders )
            aSwiftSliders[ ::nIndex ] := nil
        endif
        ::hWnd := 0
        ::cID := ""
    endif
return ::Super:End()

// The C callback calls this function
function SwiftSliderOnChange( nIndex, nValue )
    local oSlider
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftSliders )
    oSlider = aSwiftSliders[ nIndex ]
    if oSlider:bChange != nil
    Eval( oSlider:bChange, nValue, oSlider )
    endif
    endif
return nil
