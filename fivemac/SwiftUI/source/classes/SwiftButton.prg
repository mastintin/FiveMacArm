#include "FiveMac.ch"

CLASS TSwiftButton FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ACCESS IsGlass     INLINE ::hState["IsGlass"]
    ASSIGN IsGlass( l ) INLINE ::SetGlass( l )
    
    ASSIGN OnClick( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b

    METHOD New( nTop, nCol, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass )
    METHOD OnAction()
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )
    METHOD SetGlass( lGlass )
    METHOD SetText( cText )
    METHOD SetImage( cImage ) 
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn", nAutoResize := 0, lGlass := .F.

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction = bAction
    ::oWnd    = oWnd
    ::hState["Caption"]   := cPrompt
    ::hState["IsGlass"] := lGlass
   
    ::Register( SD_SWIFT_BUTTON_CREATE( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd:hWnd, ::cId ) )
    
    if lGlass
        ::SetGlass( lGlass )
    endif

    oWnd:AddControl( Self )

return Self

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
