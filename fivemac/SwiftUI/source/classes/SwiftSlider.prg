#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftSlider FROM TSwiftControl

    ACCESS ShowValue      INLINE ::hState["showvalue"]
    ASSIGN ShowValue( l ) INLINE ( ::hState["showvalue"] := l, ::Update() )

    ACCESS Glass          INLINE ::hState["isglass"]
    ASSIGN Glass( l )     INLINE ( ::hState["isglass"] := l, ::Update() )

    ACCESS Value          INLINE ::hState["value"]
    ASSIGN Value( n )     INLINE ::SetValue( n )

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction, nAutoResize, cId )
    METHOD SetValue( nValue )
    METHOD GetValue()
    METHOD OnChange( nValue )
    METHOD SetAccentColor( cHex )
    METHOD SetTextColor( cHex )
    METHOD End()
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction, nAutoResize, cId ) CLASS TSwiftSlider

    DEFAULT nWidth := 200, nHeight := 40, nValue := 50
    DEFAULT lShowValue := .T.
    DEFAULT lGlass := .F.
    DEFAULT oWnd := GetWndDefault()
    DEFAULT nAutoResize := 0
    DEFAULT cId := "sld_" + hb_NumToHex( hb_Random() )

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd    = oWnd
    ::bAction = bAction
    
    ::hState["value"]     = nValue
    ::hState["showvalue"] = lShowValue
    ::hState["isglass"]   = lGlass
    ::hState["min"]       = 0
    ::hState["max"]       = 100
   
    ::Register( SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetValue( nValue ) CLASS TSwiftSlider
    if ::Value != nValue
       ::hState["value"] := nValue
       SD_SLD_SET_VALUE( ::cId, nValue )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD GetValue() CLASS TSwiftSlider
return ::Value

//----------------------------------------------------------------------------//

METHOD OnChange( nValue ) CLASS TSwiftSlider
    ::hState["value"] := nValue
    if ::bAction != nil
        Eval( ::bAction, nValue, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD SetAccentColor( cHex ) CLASS TSwiftSlider
    ::hState["accentcolor"] := cHex
    SD_SLD_SET_ACCENT_COLOR( ::cId, cHex )
return nil

//----------------------------------------------------------------------------//

METHOD SetTextColor( cHex ) CLASS TSwiftSlider
    ::hState["textcolor"] := cHex
    SD_SLD_SET_TEXT_COLOR( ::cId, cHex )
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftSlider
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()
