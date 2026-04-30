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

     ACCESS cVibrance        INLINE hb_HGetDef( ::hState, "vibrance", "" )
     ASSIGN cVibrance( c )   INLINE ( ::hState["vibrance"] := c, ::Apply( "vibrance", c ) )

     ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
     ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )
 
     ACCESS cIconColor       INLINE hb_HGetDef( ::hState, "iconcolor", "" )
     ASSIGN cIconColor( c )  INLINE ( ::hState["iconcolor"] := c, ::Apply( "iconcolor", c ) )

     ACCESS nShadow          INLINE hb_HGetDef( ::hState, "shadow", 0 )
     ASSIGN nShadow( n )     INLINE ( ::hState["shadow"] := n, ::Apply( "shadow", n ) )

     ACCESS uFontSize        INLINE hb_HGetDef( ::hState, "fontsize", 13 )
     ASSIGN uFontSize( u )   INLINE ( ::hState["fontsize"] := u, ::Apply( "fontsize", u ) )

     ACCESS cFontStyle       INLINE hb_HGetDef( ::hState, "fontstyle", "" )
     ASSIGN cFontStyle( c )  INLINE ( ::hState["fontstyle"] := c, ::Apply( "fontstyle", c ) )
 
     ACCESS nRole            INLINE hb_HGetDef( ::hState, "role", 0 )
     ASSIGN nRole( n )       INLINE ( ::hState["role"] := n, ::Apply( "role", n ) )
 
     ACCESS lRepeat          INLINE hb_HGetDef( ::hState, "repeat", .f. )
     ASSIGN lRepeat( l )     INLINE ( ::hState["repeat"] := l, ::Apply( "repeat", l ) )
 
     ACCESS cBorderShape     INLINE hb_HGetDef( ::hState, "bordershape", ".rounded" )
     ASSIGN cBorderShape( c ) INLINE ( ::hState["bordershape"] := c, ::Apply( "bordershape", c ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId )
     METHOD SetText( cText )
     METHOD OnAction()
     METHOD End()
       
 ENDCLASS
 
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId ) CLASS TSwButton
 
     DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
     
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     ::oWnd     := oWnd
     
     if hb_IsObject( oWnd )
        ::hState["parentid"] := oWnd:cId
     endif
 
     ::hState["caption"] := cPrompt
     ::hState["type"]    := 9
     ::hState["interactive"] := 0
 
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
