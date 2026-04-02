#include "FiveMac.ch"

CLASS TSwiftToggle FROM TSwiftControl

    DATA cCaption
    DATA lSwitch
    DATA nColorAcc   AS NUMERIC
    DATA nColorText  AS NUMERIC

    METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction )
    METHOD Set( lOn )
    METHOD Get()
    METHOD SetColor( nAccent, nText )
    METHOD SetCaption(cCaption ) 
    METHOD End() 
    METHOD OnChange( lOn )
    
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bAction, nAutoResize ) CLASS TSwiftToggle

    DEFAULT nWidth := 100, nHeight := 30
    DEFAULT lOn := .F.
    DEFAULT cCaption := ""
    DEFAULT lSwitch := .F.
    DEFAULT nAutoResize := 0

    ::Super:New( nTop, nLeft, nWidth, nHeight )
    
    ::cCaption = cCaption
    ::hState["Value"] = lOn
    ::lSwitch  = lSwitch
   
    ::bAction  = bAction
    ::oWnd     = oWnd
   
    ::hWnd = SD_SWIFT_TOGGLE_CREATE( nTop, nLeft, nWidth, nHeight, cCaption, lOn, oWnd:hWnd, ::cId, ::lSwitch )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//------------------------------------------

METHOD Set( lOn ) CLASS TSwiftToggle
    
    if ::Value != lOn
        ::hState["Value"] := lOn
        SD_TGL_SET_VALUE( ::cId, lOn )
        if ::bAction != nil
            Eval( ::bAction, lOn, self )
        endif
    endif

return nil

//----------------------------------------

METHOD Get() CLASS TSwiftToggle
return ::Value

//-----------------------------------------

METHOD SetCaption( cCaption ) CLASS TSwiftToggle
    ::cCaption := cCaption
    SD_TGL_SET_CAPTION( ::cId, cCaption )
return nil

//------------------------------

METHOD SetColor( nAccent, nText, nAlpha ) CLASS TSwiftToggle
    LOCAL nAcc, nTxt
   
    DEFAULT nAlpha := 255 

    if !Empty( ::cId )
        if ValType( nAccent ) == "N"
            SD_TGL_SET_COLORS_RGBA( ::cId, nAccent, nText , nAlpha)  
        elseif ValType( nAccent ) == "C"
            SD_TGL_SET_COLORS_HEX( ::cId, nAccent, nText )
        endif
    endif
return self

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
