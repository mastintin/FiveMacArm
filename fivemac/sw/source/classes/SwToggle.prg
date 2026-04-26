#include "swfive.ch"
 
 #define SW_TYPE_TOGGLE 10
 
 CLASS TSwToggle FROM TSwiftControl
 
     ACCESS Value      INLINE ::hState["value"]
     ASSIGN Value( l ) INLINE ( ::hState["value"] := l, ::Apply( { "value" => l } ), ::OnAction() )
 
     ACCESS Prompt     INLINE ::hState["prompt"]
     ASSIGN Prompt( c ) INLINE ( ::hState["prompt"] := c, ::Apply( { "prompt" => c } ) )
 
     ACCESS Subtitle   INLINE hb_HGetDef( ::hState, "subtitle", "" )
     ASSIGN Subtitle( c ) INLINE ( ::hState["subtitle"] := c, ::Apply( { "subtitle" => c } ) )
 
     ACCESS Icon       INLINE hb_HGetDef( ::hState, "icon", "" )
     ASSIGN Icon( c )   INLINE ( ::hState["icon"] := c, ::Apply( { "icon" => c } ) )
 
     ACCESS Style      INLINE hb_HGetDef( ::hState, "style", 1 )
     ASSIGN Style( n )  INLINE ( ::hState["style"] := n, ::Apply( { "style" => n } ) )
 
     ACCESS Switch     INLINE ::hState["isswitch"]
     ASSIGN Switch( l ) INLINE ( ::Style := if( l, 1, 0 ) )
 
     ACCESS Color      INLINE hb_HGetDef( ::hState, "color", "" )
     ASSIGN Color( c )  INLINE ( ::hState["color"] := c, ::Apply( { "color" => c } ) )
 
     ACCESS TextColor      INLINE hb_HGetDef( ::hState, "textcolor", "" )
     ASSIGN TextColor( c )  INLINE ( ::hState["textcolor"] := c, ::Apply( { "textcolor" => c } ) )
 
     METHOD SetColor( c ) INLINE ( ::Color := c )
     METHOD SetTextColor( c ) INLINE ( ::TextColor := c )
 
     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      ::Apply( { "interactive" => ::hState["interactive"] } ) )
   
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      ::Apply( { "interactive" => ::hState["interactive"] } ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, nStyle, nAutoResize, bAction, cSubtitle, cIcon ) CONSTRUCTOR
     METHOD SetValue( lValue, lSync )
     METHOD OnAction()
 
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, nStyle, nAutoResize, bAction, cSubtitle, cIcon ) CLASS TSwToggle
     
     DEFAULT nWidth := 200, nHeight := 45, lValue := .F., cPrompt := "", nStyle := 1
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     ::hState["value"]       := lValue
     ::hState["prompt"]      := cPrompt
     ::hState["style"]       := nStyle
     ::hState["subtitle"]    := hb_DefaultValue( cSubtitle, "" )
     ::hState["icon"]        := hb_DefaultValue( cIcon, "" )
     ::hState["type"]        := SW_TYPE_TOGGLE
     ::hState["interactive"] := .F.
 
     ::oWnd    := oWnd
     ::bAction := bAction
 
     ::Create()
 
 return self
  
 // -------------------------------------------------------------------------------- //
 
 METHOD SetValue( lValue, lSync ) CLASS TSwToggle
     if hb_DefaultValue( lSync, .F. )
        ::hState["value"] := lValue
        ::Apply( { "value" => lValue } ):Sync()
        ::OnAction()
     else
        ::Value := lValue
     endif
 return nil
  
 // -------------------------------------------------------------------------------- //
 
 METHOD OnAction() CLASS TSwToggle
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, ::Value, Self )
    endif
 return nil
