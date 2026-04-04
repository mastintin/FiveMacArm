#include "FiveMac.ch"

CLASS TSwiftButton FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ACCESS IsGlass     INLINE ::hState["IsGlass"]
    ASSIGN IsGlass( l ) INLINE ::SetGlass( l )
    
    ASSIGN OnClick( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b
    
    ACCESS lProminent    INLINE ::hState["isProminent"]
    ASSIGN lProminent( l ) INLINE ::hState["isProminent"] := l, ::SetProminent( l )

    METHOD New( nTop, nCol, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass, lProminent )
    METHOD OnAction()
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )
    METHOD SetGlass( lGlass )
    METHOD SetProminent( lProminent )
    METHOD SetText( cText )
    METHOD SetImage( cImage ) 
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass, lProminent ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn", nAutoResize := 0, lGlass := .F., lProminent := .F.

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction = bAction
    ::oWnd    = oWnd
    
    ::hState["caption"]      := cPrompt
    ::hState["isGlass"]      := lGlass
    ::hState["isProminent"]  := lProminent
    ::hState["cornerRadius"] := 8
    ::hState["padding"]      := 0
    ::hState["imageName"]    := ""
   
    ::Register( SD_SWIFT_BUTTON_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )

    if lGlass
        ::SetGlass( lGlass )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetProminent( lProminent ) CLASS TSwiftButton
    ::hState["isProminent"] := lProminent
    if lProminent
        sd_set_accent_color( ::cId, -2, 100 )
    else
        sd_set_accent_color( ::cId, -1, 100 )
    endif
return nil

METHOD SetText( cText ) CLASS TSwiftButton
    ::hState["Caption"] := cText
    SD_BTN_SET_TEXT( ::cId, cText )
return nil

METHOD OnAction() CLASS TSwiftButton
   
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif

return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    SD_BTN_SET_RADIUS( ::cId, nRadius )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    SD_BTN_SET_PADDING( ::cId, nPadding )
return nil

METHOD SetGlass( lGlass ) CLASS TSwiftButton
    DEFAULT lGlass := .T.
    ::hState["IsGlass"] := lGlass
    SD_BTN_SET_GLASS( ::cId, lGlass )
return nil

METHOD SetImage( cImage ) CLASS TSwiftButton
    if cImage != nil
        SD_BTN_SET_IMAGE( ::cId, cImage )
    endif
return nil

METHOD End() CLASS TSwiftButton
    if !Empty( ::hWnd )
        SD_BTN_DESTROY( ::cId, ::hWnd )
        ::bAction := nil
    endif
return ::Super:End()
