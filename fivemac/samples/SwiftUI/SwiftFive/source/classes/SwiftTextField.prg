#include "FiveMac.ch"

static aTextFields := {}

CLASS TSwiftTextField

    DATA hWnd
    DATA oWnd
    DATA nIndex
    DATA bOnChange
    DATA cId
    DATA nTop, nLeft, nWidth, nHeight
    DATA cText, cPlaceholder

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bOnChange, oBatch )
    METHOD SetText( cText )
    METHOD GetText()
    METHOD GetConfig()
    
    METHOD OnChange( cNewText )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bOnChange, nAutoResize, oBatch ) CLASS TSwiftTextField

    DEFAULT nWidth := 200, nHeight := 24, oWnd := GetWndDefault()
    DEFAULT cText := "", cPlaceholder := "Enter text...", nAutoResize := 0

    ::nTop      = nTop
    ::nLeft     = nLeft
    ::nWidth    = nWidth
    ::nHeight   = nHeight
    ::cText     = cText
    ::cPlaceholder = cPlaceholder
    ::oWnd      = oWnd
    ::bOnChange  = bOnChange
    
    ::nIndex = Len( aTextFields ) + 1
    ::cId       = "textfield_" + AllTrim( Str( ::nIndex ) )
    AAdd( aTextFields, Self )
    
    if oBatch == nil .and. oWnd != nil 
    oBatch := oWnd:oSwiftBatch
    endif

    if oBatch != nil
    oBatch:Add( Self )
    else
    ::hWnd = SWIFTTEXTFIELDCREATE( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd:hWnd, ::nIndex, ::cId )
    endif

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    // We do NOT call oWnd:AddControl( Self ) anymore because we want to avoid 
    // FiveMac managing this SwiftUI view as a standard Harbour control.

return Self

METHOD GetConfig() CLASS TSwiftTextField
    local hConfig := {=>}
    
    hConfig["type"]        := "textfield"
    hConfig["top"]         := ::nTop
    hConfig["left"]        := ::nLeft
    hConfig["width"]       := ::nWidth
    hConfig["height"]      := ::nHeight
    hConfig["text"]        := ::cText
    hConfig["placeholder"] := ::cPlaceholder
    hConfig["index"]       := ::nIndex
    hConfig["id"]          := ::cId
    
return hConfig

METHOD SetText( cText ) CLASS TSwiftTextField
    ::cText = cText
    if ! Empty( ::hWnd )
    SWIFTTEXTFIELDSETTEXT( ::nIndex, cText )
    endif
return nil

METHOD GetText() CLASS TSwiftTextField
    if ! Empty( ::hWnd )
    ::cText = SWIFTTEXTFIELDGETTEXT( ::nIndex )
    endif
return ::cText

METHOD OnChange( cNewText ) CLASS TSwiftTextField
    if ::bOnChange != nil
    Eval( ::bOnChange, cNewText, Self )
    endif
return nil

// Callback from C
function SWIFTTEXTFIELDONCHANGE( nIndex, cNewText )
    if nIndex > 0 .and. nIndex <= Len( aTextFields )
    aTextFields[ nIndex ]:OnChange( cNewText )
    endif
return nil
