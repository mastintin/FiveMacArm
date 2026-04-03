#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftSlider FROM TSwiftControl

    ACCESS ShowValue      INLINE ::hState["ShowValue"]
    ASSIGN ShowValue( l ) INLINE ::hState["ShowValue"] := l

    ACCESS Glass      INLINE ::hState["Glass"]
    ASSIGN Glass( l ) INLINE ::hState["Glass"] := l

    ACCESS Value      INLINE ::hState["Value"]
    ASSIGN Value( n ) INLINE ::SetValue( n )

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction, nAutoResize, cId )
    METHOD SetValue( nValue )
    METHOD GetValue()
    METHOD OnChange( nValue )
    METHOD End()
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, lShowValue, lGlass, oWnd, bAction, nAutoResize, cId ) CLASS TSwiftSlider

    DEFAULT nWidth := 200, nHeight := 40, nValue := 50
    DEFAULT lShowValue := .T.
    DEFAULT lGlass := .F.
    DEFAULT oWnd := GetWndDefault()
    DEFAULT nAutoResize := 0

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd    = oWnd
    ::bAction = bAction
    ::hState["Value"]     = nValue
    ::hState["ShowValue"] = lShowValue
    ::hState["Glass"]     = lGlass
   
    ::Register( SD_SWIFT_SLIDER_CREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::cId, lShowValue, lGlass ) )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetValue( nValue ) CLASS TSwiftSlider
    if ::Value != nValue
       ::hState["Value"] := nValue
       SD_SLD_SET_VALUE( ::cId, nValue )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD GetValue() CLASS TSwiftSlider
return ::Value

//----------------------------------------------------------------------------//

METHOD OnChange( nValue ) CLASS TSwiftSlider
    ::hState["Value"] := nValue
    if ::bAction != nil
        Eval( ::bAction, nValue, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftSlider
    if !Empty( ::hWnd )
        SD_SLD_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()
