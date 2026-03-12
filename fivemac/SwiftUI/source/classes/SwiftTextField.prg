#include "FiveMac.ch"

static aSwiftTextFields := {}

CLASS TSwiftTextField FROM TControl

    DATA bOnChange
    DATA cId
    DATA nIndex
    DATA cText, cPlaceholder

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bOnChange, oBatch )
    METHOD SetText( cText )
    METHOD GetText()
    METHOD GetConfig()
    METHOD SetColor( nFg, nBg )
    METHOD SetFontSize( nSize )
    METHOD End()
    
    METHOD OnChange( cNewText )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bOnChange, nAutoResize, oBatch ) CLASS TSwiftTextField

    DEFAULT nWidth := 200, nHeight := 24, oWnd := GetWndDefault()
    DEFAULT cText := "", cPlaceholder := "Enter text...", nAutoResize := 0

    ::oWnd       = oWnd
    ::bOnChange  = bOnChange
    ::cText      = cText
    ::cPlaceholder = cPlaceholder
    
    ::cId        = SWIFT_UUID()
   
    AAdd( aSwiftTextFields, Self )
    ::nIndex     = Len( aSwiftTextFields )
    
    if oBatch == nil .and. oWnd != nil 
        oBatch := oWnd:oSwiftBatch
    endif

    if oBatch != nil
        oBatch:Add( Self )
    else
        ::hWnd = SD_SWIFT_TEXTFIELD_CREATE( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd:hWnd, ::nIndex, ::cId )
    endif

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

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
    SD_TF_SET_TEXT( ::cId, cText )
return nil

METHOD GetText() CLASS TSwiftTextField
    ::cText = SD_TF_GET_TEXT( ::cId )
return ::cText

METHOD SetColor( nFg, nBg ) CLASS TSwiftTextField
    SD_TF_SET_COLORS( ::cId, clrToHex( nFg ), clrToHex( nBg ) )
return nil

METHOD SetFontSize( nSize ) CLASS TSwiftTextField
    SD_TF_SET_FONT_SIZE( ::cId, nSize )
return nil

METHOD End() CLASS TSwiftTextField
    if !Empty( ::hWnd )
        SD_TF_DESTROY( ::cId, ::nIndex, ::hWnd )
        if ::nIndex > 0 .and. ::nIndex <= Len( aSwiftTextFields )
            aSwiftTextFields[ ::nIndex ] := nil
        endif
        ::hWnd := 0
        ::cId := ""
    endif
return ::Super:End()

METHOD OnChange( cNewText ) CLASS TSwiftTextField
    if ::bOnChange != nil
        Eval( ::bOnChange, cNewText, Self )
    endif
return nil

// Callback from C using nIndex
function SWIFTTEXTFIELDONCHANGE( nIndex, cNewText )
    local oTxf
    
    if nIndex > 0 .and. nIndex <= Len( aSwiftTextFields )
        oTxf := aSwiftTextFields[ nIndex ]
        if oTxf != nil
            oTxf:OnChange( cNewText )
        endif
    endif
return nil

CLASS TSwiftTextEditor FROM TSwiftTextField
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd )
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd ) CLASS TSwiftTextEditor
    DEFAULT nWidth := 300, nHeight := 100, oWnd := GetWndDefault()
    DEFAULT cText := ""

    ::oWnd      = oWnd
    ::cText     = cText
    
    ::cId       = SWIFT_UUID()
    
    AAdd( aSwiftTextFields, Self )
    ::nIndex     = Len( aSwiftTextFields )
    
    ::hWnd = SD_SWIFT_TEXTEDITOR_CREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::nIndex, ::cId )

    oWnd:AddControl( Self )

return Self
