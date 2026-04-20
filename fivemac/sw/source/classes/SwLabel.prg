#include "swfive.ch"
 
 #define SW_TYPE_TEXT 0
 
 CLASS TSwLabel FROM TSwiftControl
 
    ACCESS Caption    INLINE ::hState["text"]
    ASSIGN Caption(c) INLINE ( ::hState["text"] := c, SD:Apply( ::cId, { "text" => c } ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, SD:Apply( ::cId, { "hasscroll" => l } ) )
  
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize )
    METHOD SetText( cText, lSync )
  
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize ) CLASS TSwLabel
 
    DEFAULT nWidth := 100, nHeight := 20
     
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
  
    ::hState["text"]        := cText
    ::hState["type"]        := SW_TYPE_TEXT
    ::hState["hasscroll"]   := .F.
  
    ::oWnd     := oWnd
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
 
    ::Create()
  
 return self
  
 // -------------------------------------------------------------------------------- //
  
 METHOD SetText( cText, lSync ) CLASS TSwLabel
    if hb_DefaultValue( lSync, .F. )
       ::hState["text"] := cText
       SDS:Apply( ::cId, { "text" => cText } )
    else
       ::Caption := cText
    endif
 return nil
