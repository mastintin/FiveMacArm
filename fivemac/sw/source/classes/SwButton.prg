#include "FiveMac.ch"
 
CLASS TSwButton FROM TSwiftControl
 
    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId )
    METHOD SetText( cText )
    METHOD End()
      
ENDCLASS
 
METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId ) CLASS TSwButton
 
    DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
    
    if Empty( cId ) ; cId := hb_UUID() ; endif
 
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::bAction  := bAction
    ::oWnd     := oWnd
    ::hState["caption"] := cPrompt
    ::hState["type"]    := 9
   
    ::Create()
    
    // 2. Registrar en Harbour
    SwiftRegisterItem( ::cId, Self )
    
 return Self
 
METHOD SetText( cText ) CLASS TSwButton
    SD:Text( ::cId, cText )
return nil
 
METHOD End() CLASS TSwButton
    SwiftUnregisterItem( ::cId )
return ::Super:End()
