#include "swfive.ch"
 
 //----------------------------------------------------------------------------//
  
 CLASS SwGet FROM TSwiftControl
  
    ACCESS cPicture         INLINE ::hState["picture"]
    ASSIGN cPicture( c )    INLINE ( ::hState["picture"] := c, SD:Apply( ::cId, { "picture" => c } ) )
  
    DATA bValid
    DATA lSecure    INIT .F.
  
    ACCESS Value      INLINE ::hState["text"]
    ASSIGN Value( u ) INLINE ( ::hState["text"] := hb_ValToStr( u ), SD:Apply( ::cId, { "text" => ::hState["text"] } ) )
 
    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
       SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
   
    ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
    ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
       SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, SD:Apply( ::cId, { "hasscroll" => l } ) )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, uValue, oWnd, bAction, cPicture, bValid, lSecure, cPlaceholder )
    METHOD SetText( cText )
    METHOD OnAction( cNewText )
    METHOD OnValid()
  
 ENDCLASS
  
 //----------------------------------------------------------------------------//
  
 METHOD New( nTop, nLeft, nWidth, nHeight, uValue, oWnd, bAction, cPicture, bValid, lSecure, cPlaceholder ) CLASS SwGet
  
    DEFAULT nWidth := 120, nHeight := 24
    DEFAULT uValue := "", lSecure := .F., cPlaceholder := ""
    
    ::Super:New( nTop, nLeft, nWidth, nHeight )
    
    ::oWnd     := oWnd
    ::bValid   := bValid
    ::cPicture := cPicture
    ::lSecure  := lSecure
  
    ::hState["text"]        := hb_ValToStr( uValue )
    ::hState["picture"]     := cPicture
    ::hState["issecure"]    := lSecure
    ::hState["placeholder"] := cPlaceholder
    ::hState["hasscroll"]   := .F.
    ::hState["interactive"] := .F.
    ::hState["type"]        := 14
   
    ::bAction  := bAction
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
  
    ::Create()
  
 return Self
  
 //----------------------------------------------------------------------------//
  
 METHOD SetText( cText ) CLASS SwGet
    ::Value := cText
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD OnAction( cNewText ) CLASS SwGet
    ::hState["text"] := cNewText
    SW_LOG( "🚢 [SwGet:OnAction] ID: " + ::cId + " Val: [" + hb_ValToStr( cNewText ) + "]" )
     
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, cNewText, Self )
    endif
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD OnValid() CLASS SwGet
    if ::bValid != nil
       return Eval( ::bValid, Self )
    endif
 return .T.
