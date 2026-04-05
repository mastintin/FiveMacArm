#include "FiveMac.ch"

CLASS TSwiftToggle FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ::SetCaption( c )

    ACCESS Checked      INLINE ::hState["ison"]
    ASSIGN Checked( l ) INLINE ::SetValue( l )

    ACCESS Value        INLINE ::hState["ison"]
    ASSIGN Value( l )   INLINE ::SetValue( l )

    ACCESS IsSwitch      INLINE ::hState["isswitch"]
    ASSIGN IsSwitch( l ) INLINE ::hState["isswitch"] := l

    METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction, nAutoResize, cId )
    METHOD SetValue( lOn )
    METHOD GetValue()   INLINE ::Value
    METHOD SetCaption( cCaption ) 
    METHOD SetTextColor( nColor, nAlpha )
    METHOD SetAccentColor( nColor, nAlpha )
    METHOD OnChange( lOn )
    METHOD End() 
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction, nAutoResize, cId ) CLASS TSwiftToggle

    DEFAULT nWidth := 100, nHeight := 30
    DEFAULT lOn := .F.
    DEFAULT cCaption := ""
    DEFAULT lSwitch := .F.
    DEFAULT nAutoResize := 0

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::hState["caption"]     := cCaption
    ::hState["ison"]        := lOn
    ::hState["isswitch"]    := lSwitch
   
    ::bAction  := bAction
    ::oWnd     := oWnd
   
    ::Register( SD_SWIFT_TOGGLE_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetValue( lOn ) CLASS TSwiftToggle
    if ::Value != lOn
        ::hState["ison"] := lOn
        SD_TGL_SET_VALUE( ::cId, lOn )
        if ::bAction != nil
            Eval( ::bAction, lOn, Self )
        endif
    endif
return nil

METHOD SetCaption( cCaption ) CLASS TSwiftToggle
    ::hState["caption"] := cCaption
    SD_TGL_SET_CAPTION( ::cId, cCaption )
return nil

METHOD SetTextColor( nColor, nAlpha ) CLASS TSwiftToggle
    local cHex 
    if nColor != NIL 
        cHex := ::InitialColorToHex( nColor, nAlpha )
        ::hState["textcolor"] := cHex 
        SD_TGL_SET_FG( ::cId, cHex )
    endif
return self

METHOD SetAccentColor( nColor, nAlpha ) CLASS TSwiftToggle
    local cHex 
    if nColor != NIL 
        cHex := ::InitialColorToHex( nColor, nAlpha )
        ::hState["accentcolor"] := cHex 
        SD_TGL_SET_BG( ::cId, cHex )
    endif
return self

METHOD End() CLASS TSwiftToggle
    if !Empty( ::hWnd )
        SD_TGL_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()

METHOD OnChange( lOn ) CLASS TSwiftToggle
    ::hState["ison"] := lOn
    if ::bAction != nil
        Eval( ::bAction, lOn, Self )
    endif
return nil
