#include "FiveMac.ch"

static aSwiftTextFields := {}

CLASS TSwiftTextField FROM TControl

    DATA bOnChange
    DATA cId
    DATA cText, cPlaceholder

    ACCESS Value      INLINE ::cText
    ASSIGN Value( c ) INLINE ::SetText( c )
    
    ACCESS Text       INLINE ::cText
    ASSIGN Text( c )  INLINE ::SetText( c )
    
    ASSIGN OnChange( b ) INLINE ::bOnChange := b

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
    
    ::cId := ""
   
    AAdd( aSwiftTextFields, Self )
    
    if oBatch == nil .and. oWnd != nil 
        oBatch := oWnd:oSwiftBatch
    endif

    if oBatch != nil
        oBatch:Add( Self )
        // Note: Batch mode needs care if we want Swift to generate IDs, 
        // as we only get them when the batch is created.
        // For now, we can pre-generate if empty or keep it as is.
    else
        ::hWnd = SD_SWIFT_TEXTFIELD_CREATE( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd:hWnd, ::cId )
        ::cId := SW_GET_ID( ::hWnd )
        SwiftRegisterItem( ::cId, Self )
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
    local nPos 
    if !Empty( ::hWnd )
        SD_TF_DESTROY( ::cId, ::hWnd )
        SwiftUnregisterItem( ::cId )
        nPos := AScan( aSwiftTextFields, { |o| o != nil .and. o:cId == ::cId } )
        if nPos > 0
            aSwiftTextFields[ nPos ] := nil
        endif
        ::cId := ""
    endif
return ::Super:End()

METHOD OnChange( cNewText ) CLASS TSwiftTextField
    ::cText := cNewText
    if ::bOnChange != nil
        Eval( ::bOnChange, cNewText, Self )
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
    
    ::cId       := ""
    
    AAdd( aSwiftTextFields, Self )
    
    ::hWnd = SD_SWIFT_TEXTEDITOR_CREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::cId )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )

    oWnd:AddControl( Self )

return Self
