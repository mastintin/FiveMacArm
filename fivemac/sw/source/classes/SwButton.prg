#include "FiveMac.ch"

CLASS TSwButton FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ASSIGN OnClick( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId )
    METHOD OnAction()
    METHOD SetText( cText )
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId ) CLASS TSwButton

    DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction = bAction
    ::oWnd    = oWnd
    ::hState["Caption"] := cPrompt
   
    // Modern Mode: Only create state in Swift. No NSView handle.
    SD_SWIFT_BUTTON_CREATE_STATE( ::cId, cPrompt )
    
    // Official registration on Harbour side (even without hWnd)
    SwiftRegisterItem( ::cId, Self )
    
    if oWnd != nil .and. oWnd:IsKindOf( "TSWWINDOW" )
        oWnd:AddControl( Self, nTop, nLeft )
    endif

return Self

METHOD SetText( cText ) CLASS TSwButton
    ::hState["Caption"] := cText
    SD_BTN_SET_TEXT( ::cId, cText )
return nil

METHOD OnAction() CLASS TSwButton
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif
return nil

METHOD End() CLASS TSwButton
    // We don't have a native hWnd to destroy here, 
    // but we can clean the registry
    SD_BTN_DESTROY( ::cId, 0 )
    ::bAction := nil
return ::Super:End()
