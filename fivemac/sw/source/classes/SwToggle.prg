#include "swfive.ch"
 
 #define SW_TYPE_TOGGLE 10
 
 CLASS TSwToggle FROM TSwiftControl
 
     ACCESS Value      INLINE ::hState["value"]
     ASSIGN Value( l ) INLINE ( ::hState["value"] := l, SD:Apply( ::cId, { "value" => l } ), ::OnAction() )
 
     ACCESS Prompt     INLINE ::hState["prompt"]
     ASSIGN Prompt( c ) INLINE ( ::hState["prompt"] := c, SD:Apply( ::cId, { "prompt" => c } ) )
 
     ACCESS Switch     INLINE ::hState["isswitch"]
     ASSIGN Switch( l ) INLINE ( ::hState["isswitch"] := l, SD:Apply( ::cId, { "isswitch" => l } ) )
 
     ACCESS Color      INLINE hb_HGetDef( ::hState, "color", "" )
     ASSIGN Color( c )  INLINE ( ::hState["color"] := c, SD:Apply( ::cId, { "color" => c } ) )
 
     ACCESS TextColor      INLINE hb_HGetDef( ::hState, "textcolor", "" )
     ASSIGN TextColor( c )  INLINE ( ::hState["textcolor"] := c, SD:Apply( ::cId, { "textcolor" => c } ) )
 
     METHOD SetColor( c ) INLINE ( ::Color := c )
     METHOD SetTextColor( c ) INLINE ( ::TextColor := c )
 
     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
   
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, lSwitch, nAutoResize, bAction ) CONSTRUCTOR
    METHOD SetValue( lValue, lSync )
    METHOD OnAction()
 
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, lSwitch, nAutoResize, bAction ) CLASS TSwToggle
     
     DEFAULT nWidth := 200, nHeight := 30, lValue := .F., cPrompt := "", lSwitch := .F.
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     ::hState["value"]       := lValue
     ::hState["prompt"]      := cPrompt
     ::hState["isswitch"]    := lSwitch
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
        SDS:Apply( ::cId, { "value" => lValue } )
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
