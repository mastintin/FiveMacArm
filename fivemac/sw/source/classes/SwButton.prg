#include "swfive.ch"
 
 CLASS TSwButton FROM TSwiftControl
 
     ACCESS Caption      INLINE ::hState["caption"]
     ASSIGN Caption( c ) INLINE ( ::hState["caption"] := c, ::Apply( "caption", c ) )
 
     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := iif( !Empty( u ) .or. !Empty( ::bPipeline ), 1, 0 ),;
                                      ::Apply( "interactive", ::hState["interactive"] ) )
  
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["pipeline_json"] := if( !Empty(u), Sw_GetProxy():Cook( u )["json"], nil ),;
                                      ::hState["interactive"] := iif( !Empty( u ) .or. !Empty( ::bAction ), 1, 0 ),;
                                      ::Apply( { "interactive" => ::hState["interactive"], "pipeline_json" => ::hState["pipeline_json"] } ) )
 
     ACCESS cColor           INLINE hb_HGetDef( ::hState, "color", "" )
     ASSIGN cColor( c )      INLINE ( ::hState["color"] := c, ::Apply( "color", c ) )
 
     ACCESS cBackColor       INLINE hb_HGetDef( ::hState, "backcolor", "" )
     ASSIGN cBackColor( c )  INLINE ( ::hState["backcolor"] := c, ::Apply( "backcolor", c ) )
 
     ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
     ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )
 
     ACCESS uFontSize        INLINE hb_HGetDef( ::hState, "fontsize", 13 )
     ASSIGN uFontSize( u )   INLINE ( ::hState["fontsize"] := u, ::Apply( "fontsize", u ) )
 
     ACCESS cStyle           INLINE hb_HGetDef( ::hState, "style", "" )
     ASSIGN cStyle( c )      INLINE ( ::hState["style"] := c, ::Apply( "style", c ) )
 
     ACCESS cGlassEffect     INLINE hb_HGetDef( ::hState, "glass", "" )
     ASSIGN cGlassEffect( c ) INLINE ( ::hState["glass"] := c, ::Apply( "glass", c ) )
 
     ACCESS cBorderShape     INLINE hb_HGetDef( ::hState, "bordershape", ".rounded" )
     ASSIGN cBorderShape( c ) INLINE ( ::hState["bordershape"] := c, ::Apply( "bordershape", c ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, cStyle, cIcon, cShape, cColor )
     METHOD SetText( cText )
     METHOD OnAction()
     METHOD End()
       
 ENDCLASS
 
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, cStyle, cIcon, cShape, cColor ) CLASS TSwButton
 
     DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
     
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     ::oWnd     := oWnd
     
     if hb_IsObject( oWnd )
        ::hState["parentid"] := oWnd:cId
     endif
 
     ::hState["caption"] := cPrompt
     ::hState["type"]    := 9
     if !Empty( cStyle ); ::hState["style"] := cStyle; endif 
     if !Empty( cIcon );  ::hState["icon"]  := cIcon;  endif
     if !Empty( cShape ); ::hState["bordershape"] := cShape; endif
     if !Empty( cColor ); ::hState["color"] := cColor; endif

     ::bAction  := bAction
    
     ::Create()
     
  return Self
 
 //----------------------------------------------------------------------------//
 
 METHOD OnAction() CLASS TSwButton
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, Self )
    endif
 return nil
 
 //----------------------------------------------------------------------------//
 
 METHOD SetText( cText ) CLASS TSwButton
    ::Caption := cText
 return nil
  
 //----------------------------------------------------------------------------//
 
 METHOD End() CLASS TSwButton
     SwiftUnregisterItem( ::cId )
 return ::Super:End()
