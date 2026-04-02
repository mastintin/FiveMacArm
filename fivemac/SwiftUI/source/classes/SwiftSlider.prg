#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftSliders := {}

CLASS TSwiftSlider FROM TControl

    DATA bAction
    DATA cID
    DATA nValue
    DATA lShowValue
    DATA lGlass

    ACCESS Value      INLINE ::nValue
    ASSIGN Value( n ) INLINE ::SetValue( n )
    
    ASSIGN OnChange( b ) INLINE ::bAction := b

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction )
    METHOD SetValue( nValue )
    METHOD GetValue()
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

    ::oWnd    = oWnd
    ::bAction = bAction
    ::nValue  = nValue
    ::lShowValue = lShowValue
    ::lGlass = lGlass
   
    ::cID := ""
    
    AAdd( aSwiftSliders, Self )

    ::hWnd = SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::cID, ::lShowValue, ::lGlass )
    ::cID := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cID, Self )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetValue( nValue ) CLASS TSwiftSlider
    ::nValue := nValue
    SD_SLD_SET_VALUE( ::cID, nValue )
return nil

//----------------------------------------------------------------------------//

METHOD GetValue() CLASS TSwiftSlider
    ::nValue := SD_SLD_GET_VALUE( ::cID )
return ::nValue

//----------------------------------------------------------------------------//

METHOD OnChange( nValue ) CLASS TSwiftSlider
    ::nValue := nValue
    if ::bAction != nil
        Eval( ::bAction, nValue, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD SetAccentColor( nColor ) CLASS TSwiftSlider
    SD_SLD_SET_ACCENT_COLOR( ::cID, nColor )
return nil

//----------------------------------------------------------------------------//

METHOD SetColor( nFg, nBg ) CLASS TSwiftSlider
    SD_SLD_SET_COLORS( ::cID, clrToHex( nFg ), clrToHex( nBg ) )
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftSlider
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cId, ::hWnd )
        SwiftUnregisterItem( ::cId )
        AScan( aSwiftSliders, { |o, i| If( o != nil .and. o:cID == ::cId, aSwiftSliders[ i ] := nil, ) } )
        ::cId := ""
    endif
return ::Super:End()
