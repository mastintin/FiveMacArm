#include "FiveMac.ch"

CLASS TSwiftToggle FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetCaption( c )

    ACCESS Checked      INLINE ::hState["Value"]
    ASSIGN Checked( l ) INLINE ::SetValue( l )

    ACCESS Value        INLINE ::hState["Value"]
    ASSIGN Value( l )   INLINE ::SetValue( l )

    ACCESS IsSwitch      INLINE ::hState["IsSwitch"]
    ASSIGN IsSwitch( l ) INLINE ::hState["IsSwitch"] := l

    METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction, nAutoResize, cId )
    METHOD SetValue( lOn )
    METHOD GetValue()
    METHOD SetCaption(cCaption ) 
    METHOD End() 
    METHOD OnChange( lOn )
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction, nAutoResize, cId ) CLASS TSwiftToggle

    DEFAULT nWidth := 100, nHeight := 30
    DEFAULT lOn := .F.
    DEFAULT cCaption := ""
    DEFAULT lSwitch := .F.
    DEFAULT nAutoResize := 0

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::hState["Caption"]     = cCaption
    ::hState["Value"]       = lOn
    ::hState["IsSwitch"]    = lSwitch
   
    ::bAction  = bAction
    ::oWnd     = oWnd
   
    ::Register( SD_SWIFT_TOGGLE_CREATE( nTop, nLeft, nWidth, nHeight, cCaption, lOn, oWnd:hWnd, ::cId, lSwitch ) )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//------------------------------------------

METHOD SetValue( lOn ) CLASS TSwiftToggle
    
    if ::Value != lOn
        ::hState["Value"] := lOn
        SD_TGL_SET_VALUE( ::cId, lOn )
        if ::bAction != nil
            Eval( ::bAction, lOn, self )
        endif
    endif

return nil

//----------------------------------------

METHOD GetValue() CLASS TSwiftToggle
return ::Value

//-----------------------------------------

METHOD SetCaption( cCaption ) CLASS TSwiftToggle
    ::hState["Caption"] := cCaption
    SD_TGL_SET_CAPTION( ::cId, cCaption )
return nil

// ---------------------------------------------------------------------------

METHOD End() CLASS TSwiftToggle
    if !Empty( ::hWnd )
        SD_TGL_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()

METHOD OnChange( lOn ) CLASS TSwiftToggle
    ::hState["Value"] := lOn
    if ::bAction != nil
        Eval( ::bAction, lOn, Self )
    endif
return nil
