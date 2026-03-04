#include "FiveMac.ch"

CLASS TSwiftTextField

    DATA hWnd
    DATA oWnd
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
    
    ::cId       = SWIFT_UUID() // Generate a proper UUID
    SwiftRegisterItem( ::cId, Self )
    
    if oBatch == nil .and. oWnd != nil 
    oBatch := oWnd:oSwiftBatch
    endif

    if oBatch != nil
    oBatch:Add( Self )
    else
    ::hWnd = SWIFTTEXTFIELDCREATE( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd:hWnd, 0, ::cId )
    endif

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

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
    hConfig["id"]          := ::cId
    
return hConfig

METHOD SetText( cText ) CLASS TSwiftTextField
    ::cText = cText
    SWIFTTEXTFIELDSETTEXT( ::cId, cText )
return nil

METHOD GetText() CLASS TSwiftTextField
    ::cText = SWIFTTEXTFIELDGETTEXT( ::cId )
return ::cText

METHOD OnChange( cNewText ) CLASS TSwiftTextField
    if ::bOnChange != nil
    Eval( ::bOnChange, cNewText, Self )
    endif
return nil

// Callback from C using String ID
// Callback from C using String ID
function SWIFTTEXTFIELDONCHANGE( cId, cNewText )
    local oTxf := SwiftGetItem( cId )
    if oTxf != nil
    oTxf:OnChange( cNewText )
    endif
return nil

CLASS TSwiftTextEditor FROM TSwiftTextField
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd )
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd ) CLASS TSwiftTextEditor
    DEFAULT nWidth := 300, nHeight := 100, oWnd := GetWndDefault()
    DEFAULT cText := ""

    ::nTop      = nTop
    ::nLeft     = nLeft
    ::nWidth    = nWidth
    ::nHeight   = nHeight
    ::cText     = cText
    ::oWnd      = oWnd
    
    ::cId       = SWIFT_UUID()
    SwiftRegisterItem( ::cId, Self )
    
    ::hWnd = SWIFTTEXTEDITORCREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::cId )

return Self
