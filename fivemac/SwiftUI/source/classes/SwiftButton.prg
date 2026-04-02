#include "FiveMac.ch"

static aSwiftButtons := {}

CLASS TSwiftButton FROM TControl

    DATA bAction
    DATA cID
    DATA cText, cPrompt
    DATA lGlass

    ACCESS Text       INLINE ::cText
    ASSIGN Text( c )  INLINE ::SetText( c )
    
    // Alias for Text
    ACCESS Prompt     INLINE ::cText
    ASSIGN Prompt( c ) INLINE ::SetText( c )
    
    ASSIGN OnClick( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction )
    METHOD OnAction()
    METHOD SetColor( nFgColor, nBgColor )
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )
    METHOD SetGlass( lGlass )
    METHOD SetText( cText )
    METHOD SetImage( cImage ) 
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn", nAutoResize := 0

    ::bAction = bAction
    ::oWnd    = oWnd
    ::cText   = cPrompt
    ::cPrompt = cPrompt
    ::cID := ""
   
    AAdd( aSwiftButtons, Self )

    ::hWnd = SD_SWIFT_BUTTON_CREATE( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd:hWnd, ::cID )
    ::cID := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cID, Self )
    
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftButton
    ::cText   := cText
    ::cPrompt := cText
    SD_BTN_SET_TEXT( ::cID, cText )
return nil

METHOD OnAction() CLASS TSwiftButton
   
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif

return nil

METHOD SetColor( nFgColor, nBgColor ) CLASS TSwiftButton
    if nBgColor != nil
        SD_BTN_SET_BG( ::cID, clrToHex( nBgColor ) )
    endif
    if nFgColor != nil
        SD_BTN_SET_FG( ::cID, clrToHex( nFgColor ) )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    SD_BTN_SET_RADIUS( ::cID, nRadius )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    SD_BTN_SET_PADDING( ::cID, nPadding )
return nil

METHOD SetGlass( lGlass ) CLASS TSwiftButton
    DEFAULT lGlass := .T.
    ::lGlass := lGlass
    SD_BTN_SET_GLASS( ::cID, lGlass )
return nil

METHOD SetImage( cImage ) CLASS TSwiftButton
    if cImage != nil
        SD_BTN_SET_IMAGE( ::cID, cImage )
    endif
return nil

METHOD End() CLASS TSwiftButton
    local nPos 
    if !Empty( ::hWnd )
        SD_BTN_DESTROY( ::cID, ::hWnd )
        SwiftUnregisterItem( ::cID )
        ::bAction := nil
        nPos := AScan( aSwiftButtons, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftButtons[ nPos ] := nil
        endif
        ::cID := ""
    endif
return ::Super:End()
